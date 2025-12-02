// notifications/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import '../models/notification.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<NotificationDataModel> _notificationController =
  StreamController<NotificationDataModel>.broadcast();
  bool _isConnected = false;
  int? _currentUserId;
  List<int> _userCourseIds = [];
  int _connectionAttempts = 0;

  Stream<NotificationDataModel> get notificationStream => _notificationController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    _connectionAttempts++;
    debugPrint('🔗 [WebSocketService] Intento de conexión #$_connectionAttempts');

    try {
      final token = await TokenService.getToken();
      final userId = await TokenService.getUserId();
      final userRole = await TokenService.getUserRole();

      _currentUserId = userId;

      debugPrint('🔑 [WebSocketService] Token: ${token != null ? "✅" : "❌"}');
      debugPrint('👤 [WebSocketService] UserID: $userId');
      debugPrint('🎯 [WebSocketService] UserRole: $userRole');

      if (userId == null) {
        debugPrint('❌ [WebSocketService] No user ID found');
        return;
      }

      if (userRole != 'ROLE_STUDENT') {
        debugPrint('🎓 [WebSocketService] Usuario es $userRole - No se conecta WebSocket');
        return;
      }

      if (_isConnected && _channel != null) {
        debugPrint('⚠️ [WebSocketService] Ya conectado, ignorando...');
        return;
      }

      await disconnect();

      _channel = WebSocketChannel.connect(
        Uri.parse('wss://backend-web-services-1.onrender.com/ws-notifications?token=$token&userId=$userId'),
      );

      _isConnected = true;
      debugPrint('✅ [WebSocketService] WebSocket CONECTADO para estudiante $userId');

      _channel!.stream.listen(
            (message) {
          debugPrint('📩 [WebSocketService] Mensaje recibido del servidor');
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('❌ [WebSocketService] Error en WebSocket: $error');
          _isConnected = false;
          _reconnect();
        },
        onDone: () {
          debugPrint('🔌 [WebSocketService] WebSocket desconectado por servidor');
          _isConnected = false;
          _reconnect();
        },
      );

    } catch (e) {
      debugPrint('❌ [WebSocketService] Error en conexión: $e');
      _isConnected = false;
      _reconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      debugPrint('📩 [WebSocketService] Mensaje RAW: $message');
      final jsonData = jsonDecode(message);
      final notification = NotificationDataModel.fromJson(jsonData);

      debugPrint('👤 [WebSocketService] Notificación para userId: ${notification.userId}');
      debugPrint('🎯 [WebSocketService] Current userId: $_currentUserId');
      debugPrint('📊 [WebSocketService] Notificación ID: ${notification.id}');
      debugPrint('📝 [WebSocketService] Título: ${notification.title}');
      debugPrint('📚 [WebSocketService] CourseId: ${notification.sourceCourseId}');

      // ✅ FILTRADO MEJORADO
      final isForCurrentUser = notification.userId == _currentUserId;
      final isGlobalNotification = notification.sourceCourseId == 0 ||
          notification.sourceCourseId == null;
      final userIsInCourse = _userCourseIds.contains(notification.sourceCourseId);

      debugPrint('🔍 [WebSocketService] Filtros:');
      debugPrint('   - Para usuario actual: $isForCurrentUser');
      debugPrint('   - Notificación global: $isGlobalNotification');
      debugPrint('   - Usuario en curso: $userIsInCourse');
      debugPrint('   - Cursos del usuario: $_userCourseIds');

      if (isForCurrentUser && (isGlobalNotification || userIsInCourse)) {
        _notificationController.add(notification);
        debugPrint('📨 [WebSocketService] NOTIFICACIÓN ENVIADA AL STREAM (ID: ${notification.id})');
      } else {
        if (!isForCurrentUser) {
          debugPrint('🚫 [WebSocketService] Usuario NO coincide (${notification.userId} vs $_currentUserId)');
        } else if (!isGlobalNotification && !userIsInCourse) {
          debugPrint('🚫 [WebSocketService] Usuario NO está en el curso ${notification.sourceCourseId}');
        }
      }
    } catch (e) {
      debugPrint('❌ [WebSocketService] Error procesando mensaje: $e');
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        debugPrint('🔄 [WebSocketService] Reconectando...');
        connect();
      }
    });
  }

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      debugPrint('🔌 [WebSocketService] Canal WebSocket cerrado');
    }
    _isConnected = false;
  }

  void dispose() {
    debugPrint('🧹 [WebSocketService] Dispose llamado');
    disconnect();
    _notificationController.close();
  }

  // ✅ Método para actualizar los cursos del usuario
  void updateUserCourses(List<int> courseIds) {
    _userCourseIds = courseIds;
    debugPrint('📚 [WebSocketService] Cursos actualizados: $_userCourseIds');
  }
}