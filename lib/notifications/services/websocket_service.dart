// notifications/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import '../models/notification.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<NotificationDataModel> _notificationController =
  StreamController<NotificationDataModel>.broadcast();
  bool _isConnected = false;

  Stream<NotificationDataModel> get notificationStream => _notificationController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      final token = await TokenService.getToken();
      final userId = await TokenService.getUserId();
      final userRole = await TokenService.getUserRole();

      print('🔑 Token: ${token != null ? "✅" : "❌"}');
      print('👤 UserID: $userId');
      print('🎯 UserRole: $userRole');

      // ✅ SOLUCIÓN: Solo conectar si es ESTUDIANTE
      if (userId == null) {
        print('❌ No user ID found');
        return;
      }

      if (userRole != 'ROLE_STUDENT') {
        print('🎓 Usuario es $userRole - No se conecta WebSocket (solo para estudiantes)');
        return;
      }

      // Cerrar conexión anterior si existe
      await disconnect();

      // Conectar al WebSocket SOLO para estudiantes
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://10.0.2.2:8080/ws-notifications?token=$token'),
      );

      _isConnected = true;
      print('✅ WebSocket connected for STUDENT $userId');

      // Escuchar mensajes
      _channel!.stream.listen(
            (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
          _reconnect();
        },
        onDone: () {
          print('🔌 WebSocket disconnected');
          _isConnected = false;
          _reconnect();
        },
      );

    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _isConnected = false;
      _reconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final jsonData = jsonDecode(message);
      final notification = NotificationDataModel.fromJson(jsonData);

      // Emitir notificación al stream
      _notificationController.add(notification);

      print('📨 Nueva notificación para estudiante: ${notification.title}');
    } catch (e) {
      print('❌ Error procesando mensaje: $e');
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        print('🔄 Reconnecting WebSocket...');
        connect();
      }
    });
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
    print('🔌 WebSocket disconnected');
  }

  void dispose() {
    disconnect();
    _notificationController.close();
  }
}