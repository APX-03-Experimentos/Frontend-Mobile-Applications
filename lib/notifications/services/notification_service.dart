import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/notifications/models/notification.dart';
import 'package:learnhive_mobile/shared/services/base_service.dart';

class NotificationService extends BaseService{

  NotificationService() : super('notifications');

  //Get all notifications
  Future<List<Notification>> getAllNotifications() async{
    final token = await TokenService.getToken();
    
    final response = await http.get(
      Uri.parse('${fullPath()}'),
      headers:{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(response.statusCode==200){
      final data = jsonDecode(response.body);
      return (data as List).map((item)=>Notification.fromJson(item)).toList();
    } else {
      throw Exception( 'Error fetching notifications: ${response.statusCode} - ${response.body}');
    }
  }

  //Get notification by ID
  Future<Notification> getNotificationById(int notificationId) async{
    final token = await TokenService.getToken();

    final response = await http.get(
      Uri.parse('${fullPath()}/$notificationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(response.statusCode==200){
      final data = jsonDecode(response.body);
      return Notification.fromJson(data);
    } else{
      throw Exception('Error fetching notification: ${response.statusCode} - ${response.body}');
    }
  }

  //Get notifications by user ID
  Future<List<Notification>> getNotificationsByUserId(int userId) async{
    final token = await TokenService.getToken();

    final response = await http.get(
      Uri.parse('${fullPath()}/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(response.statusCode==200){
      final data = jsonDecode(response.body);
      return (data as List).map((item)=>Notification.fromJson(item)).toList();
    } else{
      throw Exception('Error fetching notifications: ${response.statusCode} - ${response.body}');
    }

  }

  //Mark notification as read
  Future<Notification> markNotificationAsRead(int notificationId) async{
    final token = await TokenService.getToken();

    final response = await http.put(
      Uri.parse('${fullPath()}/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(response.statusCode==200){
      final data = jsonDecode(response.body);
      return Notification.fromJson(data);
    } else{
      throw Exception('Error marking notification as read: ${response.statusCode} - ${response.body}');
    }
  }

}