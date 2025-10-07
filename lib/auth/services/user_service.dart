import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/auth/model/user.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/shared/services/base_service.dart';

class UserService extends BaseService{
  UserService() : super('users');

  Future<User> updateUser(String userName, String password) async{
    final token = await TokenService.getToken();

    final res = await http.put(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'userName': userName,
          'password': password
        }),
    );
    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    } else{
      throw Exception('Error updating user: ${res.statusCode} - ${res.body}');
    }

  }

  Future<User?> deleteUser(int userId) async{
    final token = await TokenService.getToken();

    final res = await http.delete(
      Uri.parse('${fullPath()}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    } else{
      throw Exception('Error deleting user: ${res.statusCode} - ${res.body}');
    }

  }

  Future<User> getUserById(int userId) async{
    final token = await TokenService.getToken();

    final res = await http.get(
      Uri.parse('${fullPath()}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    } else{
      throw Exception('Error getting user: ${res.statusCode} - ${res.body}');
    }

  }

  Future<List<User>> getAllUsers() async{
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else{
      throw Exception('Error getting users: ${res.statusCode} - ${res.body}');
    }
  }

  Future<User> getUserByuserName(String userName) async{
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/email/$userName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    } else{
      throw Exception('Error getting user by username: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> leaveGroup(int courseId) async{
    final token = await TokenService.getToken();

    final res = await http.delete(
        Uri.parse('${fullPath()}/leave/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(res.statusCode==204){
      return;
    } else{
      throw Exception('Error leaving group: ${res.statusCode} - ${res.body}');
    }

  }

  Future<List<User>> getUsersByCourseId(int courseId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/group/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else if (res.statusCode == 404) {
      // ✅ 404 significa "lista vacía" en tu backend, no un error
      return []; // Retornar lista vacía en lugar de lanzar excepción
    } else {
      throw Exception('Error getting users by courseId: ${res.statusCode} - ${res.body}');
    }
  }

  Future<User> getCurrentUser() async{
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return User.fromJson(data);
    } else{
      throw Exception('Error getting current user: ${res.statusCode} - ${res.body}');
    }

  }

}