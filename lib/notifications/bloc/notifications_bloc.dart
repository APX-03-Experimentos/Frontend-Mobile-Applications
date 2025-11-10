import 'package:bloc/bloc.dart';
import 'package:learnhive_mobile/notifications/services/notification_service.dart';

import '../models/notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  final NotificationService _notificationService;

  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadAllNotificationsEvent>(_onLoadAllNotificationsEvent);
    on<LoadNotificationByIdEvent>(_onLoadNotificationByIdEvent);
    on<LoadNotificationsByUserIdEvent>(_onLoadNotificationsByUserIdEvent);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsReadEvent);
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
    emit(const NotificationsLoading());

    try {
      final notification = await _notificationService.getNotificationById(event.notificationId);

      emit(NotificationsLoaded(notifications: [notification]));
    } catch (e) {
      emit(NotificationsError(errorMessage: e.toString()));
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

}
