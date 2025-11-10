// notifications/views/notification_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notifications_bloc.dart';
import '../models/notification.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsBloc>().add(LoadAllNotificationsEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsEmpty) {
            return const Center(
              child: Text('No hay notificaciones'),
            );
          }

          if (state is NotificationsLoaded) {
            return _buildNotificationsList(context, state.notifications);
          }



          // Estado inicial - cargar automáticamente
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Cargando notificaciones...'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(LoadAllNotificationsEvent());
                  },
                  child: const Text('Cargar Notificaciones'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<NotificationDataModel> notifications) {
    // Invertir la lista - más nuevos primero
    final reversedNotifications = notifications.reversed.toList();

    return ListView.builder(
      itemCount: reversedNotifications.length,
      itemBuilder: (context, index) {
        final notification = reversedNotifications[index];
        return _buildNotificationItem(context, notification);
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationDataModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.read ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: Icon(
          notification.read ? Icons.notifications_none : Icons.notifications,
          color: notification.read ? Colors.grey : Colors.blue,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.message),
        trailing: Text(_formatDate(notification.ocurredAt)),
        onTap: () {
          _markAsReadAndUpdate(context, notification);
        },
      ),
    );
  }

  // Marcar como leída y actualizar automáticamente
  void _markAsReadAndUpdate(BuildContext context, NotificationDataModel notification) {
    if (!notification.read) {
      // Enviar evento para marcar como leída
      context.read<NotificationsBloc>().add(
        MarkNotificationAsReadEvent(notification.id),
      );

      // NO necesitamos recargar manualmente porque el BLoC ya actualiza el estado
      // El BlocBuilder se actualizará automáticamente cuando cambie el estado
      _showNotificationDialog(context, notification);
    }
  }


  void _showNotificationDialog(BuildContext context, NotificationDataModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con ícono
                Row(
                  children: [
                    Icon(
                      notification.read ? Icons.notifications_none : Icons.notifications,
                      color: notification.read ? Colors.grey : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mensaje
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Información detallada
                _buildDetailRow('Tipo', notification.type),
                _buildDetailRow('Fecha', _formatDetailedDate(notification.ocurredAt)),
                _buildDetailRow('Estado', notification.read ? 'Leída' : 'No leída'),

                const SizedBox(height: 20),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDetailedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}