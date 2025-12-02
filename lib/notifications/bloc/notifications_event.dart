part of 'notifications_bloc.dart';

abstract class NotificationsEvent {}

// 📖 EVENTOS DE LECTURA (Queries)
class LoadAllNotificationsEvent extends NotificationsEvent {}
class LoadNotificationByIdEvent extends NotificationsEvent {
  final int notificationId;
  LoadNotificationByIdEvent(this.notificationId);
}
class LoadNotificationsByUserIdEvent extends NotificationsEvent {
  final int userId;
  LoadNotificationsByUserIdEvent(this.userId);
}

// ✏️ EVENTOS DE ESCRITURA (Commands)
class MarkNotificationAsReadEvent extends NotificationsEvent {
  final int notificationId;
  MarkNotificationAsReadEvent(this.notificationId);
}

// 🔗 EVENTOS DE WEBSOCKET
class ConnectWebSocketEvent extends NotificationsEvent {}
class DisconnectWebSocketEvent extends NotificationsEvent {}
class NewNotificationReceivedEvent extends NotificationsEvent {
  final NotificationDataModel notification;
  NewNotificationReceivedEvent(this.notification);
}

// ✅ NUEVO EVENTO: Cuando el usuario inicia sesión
class UserLoggedInEvent extends NotificationsEvent {
  final int userId;
  UserLoggedInEvent(this.userId);
}