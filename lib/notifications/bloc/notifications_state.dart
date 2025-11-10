part of 'notifications_bloc.dart';

abstract class NotificationsState{
  const NotificationsState();
}

// ESTADO INICIAL - Cuando se abre la pantalla por primera vez
class NotificationsInitial extends NotificationsState{
  const NotificationsInitial();
}

// ESTADO DE CARGA - Cuando se están cargando las notificaciones
class NotificationLoading extends NotificationsState {
  const NotificationLoading();
}

class NotificationsLoading extends NotificationsState{
  const NotificationsLoading();
}

// ESTADO DE ERROR - Cuando ocurre un error al cargar las notificaciones
class NotificationsError extends NotificationsState{
  final String errorMessage;
  const NotificationsError({required this.errorMessage});
}

class NotificationError extends NotificationsState {
  final String errorMessage;
  const NotificationError({required this.errorMessage});
}

// ESTADO DE CARGA EXITOSA - Cuando las notificaciones se cargan correctamente
class NotificationLoaded extends NotificationsState {
  final NotificationDataModel notification;
  const NotificationLoaded({required this.notification});
}

class NotificationsLoaded extends NotificationsState{
  final List<NotificationDataModel> notifications;
  const NotificationsLoaded({required this.notifications});
}

// ESTADO DE LISTA VACÍA - Cuando no hay notificaciones para mostrar
class NotificationsEmpty extends NotificationsState {
  const NotificationsEmpty();
}

// ✏️ ESTADOS ESPECIFICOS PARA ACCIONES DE ESCRITURA
class MarkAsReadInProgress extends NotificationsState {
  final int notificationId;

  const MarkAsReadInProgress({required this.notificationId});
}

class MarkAsReadSuccess extends NotificationsState {
  final int notificationId;

  const MarkAsReadSuccess({required this.notificationId});
}

class MarkAsReadFailure extends NotificationsState {
  final String error;
  final int notificationId;

  const MarkAsReadFailure({required this.error,required  this.notificationId});
}

