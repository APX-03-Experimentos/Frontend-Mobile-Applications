import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:learnhive_mobile/notifications/services/notification_service.dart';

import '../models/notification.dart';
import '../services/websocket_service.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  final NotificationService _notificationService;
  // WebSocket service
  final WebSocketService _webSocketService;
  StreamSubscription? _webSocketSubscription;

  NotificationsBloc(this._notificationService, this._webSocketService ) : super(const NotificationsInitial()) {
    on<LoadAllNotificationsEvent>(_onLoadAllNotificationsEvent);
    on<LoadNotificationByIdEvent>(_onLoadNotificationByIdEvent);
    on<LoadNotificationsByUserIdEvent>(_onLoadNotificationsByUserIdEvent);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsReadEvent);
    //WebSocket
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<DisconnectWebSocketEvent>(_onDisconnectWebSocket);
    on<NewNotificationReceivedEvent>(_onNewNotificationReceived);

    add(ConnectWebSocketEvent());
  }
  Future<void> _onLoadAllNotificationsEvent(
      LoadAllNotificationsEvent event,
      Emitter<NotificationsState> emit
      ) async {
    // Emitimos el estado de carga
    emit(const NotificationsLoading());

    try{
      final notifications = await _notificationService.getAllNotifications();

      // Verificamos si la lista está vacía
      if(notifications.isEmpty){
        emit(const NotificationsEmpty());
      } else {
        emit(NotificationsLoaded(notifications: notifications));
      }
    } catch (e){
      emit(NotificationsError(errorMessage: e.toString()));
    }

  }

  Future<void> _onLoadNotificationByIdEvent(
      LoadNotificationByIdEvent event,
      Emitter<NotificationsState> emit
      ) async {
    emit(const NotificationLoading());

    try {
      final notification = await _notificationService.getNotificationById(event.notificationId);

      emit(NotificationLoaded(notification: notification));
    } catch (e) {
      emit(NotificationError(errorMessage: e.toString()));
    }

  }

  Future<void> _onLoadNotificationsByUserIdEvent(
      LoadNotificationsByUserIdEvent event,
      Emitter<NotificationsState> emit
      ) async {
    emit(const NotificationsLoading());

    try {
      final notifications = await _notificationService.getNotificationsByUserId(event.userId);

      if(notifications.isEmpty){
        emit(const NotificationsEmpty());
      } else {
        emit(NotificationsLoaded(notifications: notifications));
      }
    } catch (e) {
      emit(NotificationsError(errorMessage: e.toString()));
    }

  }

  Future<void> _onMarkNotificationAsReadEvent(
      MarkNotificationAsReadEvent event,
      Emitter<NotificationsState> emit
      ) async {

    try {
      // Actualizar UI inmediatamente (optimistic update)
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(read: true); // Actualizar a leída localmente
          }
          return n;
        }).toList();

        emit(NotificationsLoaded(notifications: updatedNotifications)); // ✅ Actualización inmediata
      }

      // Llamar al servicio en segundo plano
      await _notificationService.markNotificationAsRead(event.notificationId);


    } catch (e) {
      // Si hay error, revertir el cambio
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final revertedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(read: false); // Revertir a no leída
          }
          return n;
        }).toList();

        emit(NotificationsLoaded(notifications: revertedNotifications));
      }

    }
  }

  Future<void> _onConnectWebSocket(
      ConnectWebSocketEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    try {
      await _webSocketService.connect();

      // Escuchar notificaciones en tiempo real
      _webSocketSubscription = _webSocketService.notificationStream.listen(
            (notification) {
          add(NewNotificationReceivedEvent(notification));
        },
      );

      print('✅ WebSocket listener connected');
    } catch (e) {
      print('❌ WebSocket connection failed in BLoC: $e');
    }
  }

  Future<void> _onDisconnectWebSocket(
      DisconnectWebSocketEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    await _webSocketSubscription?.cancel();
    await _webSocketService.disconnect();
  }

  Future<void> _onNewNotificationReceived(
      NewNotificationReceivedEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    // Si estamos en estado loaded, agregar la nueva notificación al inicio
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = [event.notification, ...currentState.notifications];

      emit(NotificationsLoaded(notifications: updatedNotifications));
    }

    print('🎯 Nueva notificación en tiempo real: ${event.notification.title}');
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    _webSocketService.dispose();
    return super.close();
  }

}
