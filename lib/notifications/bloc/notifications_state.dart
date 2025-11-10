part of 'notifications_bloc.dart';

abstract class NotificationsState{
  const NotificationsState();
}

// ESTADO INICIAL - Cuando se abre la pantalla por primera vez
class NotificationsInitial extends NotificationsState{
  const NotificationsInitial();
}

// ESTADO DE CARGA - Cuando se están cargando las notificaciones
class NotificationsLoading extends NotificationsState{
  const NotificationsLoading();
}

// ESTADO DE ERROR - Cuando ocurre un error al cargar las notificaciones
class NotificationsError extends NotificationsState{
  final String errorMessage;
  const NotificationsError({required this.errorMessage});
}

// ESTADO DE CARGA EXITOSA - Cuando las notificaciones se cargan correctamente
class NotificationsLoaded extends NotificationsState{
  final List<Notification> notifications;
  const NotificationsLoaded({required this.notifications});
}

// ESTADO DE LISTA VACÍA - Cuando no hay notificaciones para mostrar
class NotificationsEmpty extends NotificationsState {
  const NotificationsEmpty();
}

