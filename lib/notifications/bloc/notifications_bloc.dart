import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:learnhive_mobile/notifications/services/notification_service.dart';

import '../models/notification.dart';
import '../services/websocket_service.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationService _notificationService;
  final WebSocketService _webSocketService;
  StreamSubscription? _webSocketSubscription;
  bool _isWebSocketConnected = false;
  final Set<int> _receivedNotificationIds = {};
  bool _isConnecting = false;
  bool _shouldConnect = false; // ✅ Nueva bandera para controlar conexión

  NotificationsBloc(this._notificationService, this._webSocketService)
      : super(const NotificationsInitial()) {
    debugPrint('🏗️ [NotificationsBloc] Constructor llamado - HashCode: ${hashCode}');

    on<LoadAllNotificationsEvent>(_onLoadAllNotificationsEvent);
    on<LoadNotificationByIdEvent>(_onLoadNotificationByIdEvent);
    on<LoadNotificationsByUserIdEvent>(_onLoadNotificationsByUserIdEvent);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsReadEvent);
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<DisconnectWebSocketEvent>(_onDisconnectWebSocket);
    on<NewNotificationReceivedEvent>(_onNewNotificationReceived);
    on<UserLoggedInEvent>(_onUserLoggedIn); // ✅ Nuevo evento

    // ❌ ELIMINAR la conexión automática aquí
    // En su lugar, esperaremos a que el usuario inicie sesión
  }

  Future<void> _onLoadAllNotificationsEvent(
      LoadAllNotificationsEvent event,
      Emitter<NotificationsState> emit
      ) async {
    // Emitimos el estado de carga
    emit(const NotificationsLoading());

    try {
      final notifications = await _notificationService.getAllNotifications();

      // ✅ Limpiar IDs recibidos y agregar los nuevos
      _receivedNotificationIds.clear();
      for (final notification in notifications) {
        _receivedNotificationIds.add(notification.id);
      }

      // Verificamos si la lista está vacía
      if (notifications.isEmpty) {
        emit(const NotificationsEmpty());
      } else {
        emit(NotificationsLoaded(notifications: notifications));
      }
    } catch (e) {
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

      // ✅ Limpiar IDs recibidos y agregar los nuevos
      _receivedNotificationIds.clear();
      for (final notification in notifications) {
        _receivedNotificationIds.add(notification.id);
      }

      if (notifications.isEmpty) {
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
            return n.copyWith(read: true);
          }
          return n;
        }).toList();

        emit(NotificationsLoaded(notifications: updatedNotifications));
      }

      // Llamar al servicio en segundo plano
      await _notificationService.markNotificationAsRead(event.notificationId);
    } catch (e) {
      // Si hay error, revertir el cambio
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final revertedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(read: false);
          }
          return n;
        }).toList();
        emit(NotificationsLoaded(notifications: revertedNotifications));
      }
    }
  }

  Future<void> _onUserLoggedIn(
      UserLoggedInEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    debugPrint('👤 [NotificationsBloc] Usuario ha iniciado sesión, conectando WebSocket...');
    _shouldConnect = true;
    if (!_isWebSocketConnected && !_isConnecting) {
      add(ConnectWebSocketEvent());
    }
  }

  Future<void> _onConnectWebSocket(
      ConnectWebSocketEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    debugPrint('🔗 [NotificationsBloc] _onConnectWebSocket llamado');

    if (_isWebSocketConnected) {
      debugPrint('⚠️ [NotificationsBloc] WebSocket YA CONECTADO');
      return;
    }

    if (_isConnecting) {
      debugPrint('⚠️ [NotificationsBloc] Ya se está conectando...');
      return;
    }

    // ✅ Verificar si se debe conectar (usuario logueado)
    if (!_shouldConnect) {
      debugPrint('⏸️ [NotificationsBloc] Aún no es momento de conectar (esperando login)');
      return;
    }

    _isConnecting = true;
    debugPrint('🔄 [NotificationsBloc] Iniciando conexión...');

    try {
      await _webSocketSubscription?.cancel();
      _webSocketSubscription = null;

      debugPrint('🔌 [NotificationsBloc] Llamando a webSocketService.connect()');
      await _webSocketService.connect();

      _isWebSocketConnected = true;
      _isConnecting = false;

      debugPrint('✅ [NotificationsBloc] WebSocket conectado exitosamente');

      _webSocketSubscription = _webSocketService.notificationStream.listen(
            (notification) {
          debugPrint('📨 [NotificationsBloc] Stream recibió notificación ID: ${notification.id}');
          add(NewNotificationReceivedEvent(notification));
        },
        onError: (error) {
          debugPrint('❌ [NotificationsBloc] Error en stream: $error');
          _isWebSocketConnected = false;
          _isConnecting = false;
          Future.delayed(const Duration(seconds: 5), () {
            add(ConnectWebSocketEvent());
          });
        },
        onDone: () {
          debugPrint('🔌 [NotificationsBloc] Stream cerrado');
          _isWebSocketConnected = false;
          _isConnecting = false;
          Future.delayed(const Duration(seconds: 5), () {
            add(ConnectWebSocketEvent());
          });
        },
      );

    } catch (e) {
      debugPrint('❌ [NotificationsBloc] Error conectando WebSocket: $e');
      _isWebSocketConnected = false;
      _isConnecting = false;
    }
  }

  Future<void> _onDisconnectWebSocket(
      DisconnectWebSocketEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    _isWebSocketConnected = false;
    await _webSocketSubscription?.cancel();
    await _webSocketService.disconnect();
    print('🔌 WebSocket desconectado manualmente');
  }

  Future<void> _onNewNotificationReceived(
      NewNotificationReceivedEvent event,
      Emitter<NotificationsState> emit,
      ) async {
    debugPrint('🎯 [NotificationsBloc] _onNewNotificationReceived - ID: ${event.notification.id}');
    debugPrint('📝 [NotificationsBloc] Título: ${event.notification.title}');
    debugPrint('👤 [NotificationsBloc] Para userId: ${event.notification.userId}');
    debugPrint('📚 [NotificationsBloc] CourseId: ${event.notification.sourceCourseId}');

    // ✅ VERIFICACIÓN MEJORADA DE DUPLICADOS
    // Usar ID + timestamp para evitar duplicados
    final notificationKey = '${event.notification.id}_${event.notification.ocurredAt.millisecondsSinceEpoch}';

    if (_receivedNotificationIds.contains(event.notification.id)) {
      debugPrint('⚠️ [NotificationsBloc] DUPLICADO IGNORADO (mismo ID) - ID: ${event.notification.id}');
      return;
    }

    // Verificar si es una notificación muy reciente (podría ser duplicada del backend)
    final now = DateTime.now();
    final notificationTime = event.notification.ocurredAt;
    final timeDifference = now.difference(notificationTime).inSeconds;

    if (timeDifference < 2) {
      // Es una notificación muy reciente, verificar si ya tenemos una similar
      debugPrint('⏱️ [NotificationsBloc] Notificación muy reciente (hace $timeDifference segundos)');
    }

    _receivedNotificationIds.add(event.notification.id);
    debugPrint('📝 [NotificationsBloc] IDs únicos: ${_receivedNotificationIds.length}');

    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = [event.notification, ...currentState.notifications];
      emit(NotificationsLoaded(notifications: updatedNotifications));
      debugPrint('✅ [NotificationsBloc] Estado actualizado - Total: ${updatedNotifications.length}');
    } else {
      debugPrint('🔄 [NotificationsBloc] Cargando todas las notificaciones...');
      add(LoadAllNotificationsEvent());
    }
  }



  @override
  Future<void> close() {
    debugPrint('🧹 [NotificationsBloc] Cerrando...');
    _isWebSocketConnected = false;
    _isConnecting = false;
    _shouldConnect = false;
    _webSocketSubscription?.cancel();
    _webSocketService.dispose();
    return super.close();
  }
}