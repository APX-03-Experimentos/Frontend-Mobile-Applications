import 'dart:convert';

import 'package:learnhive_mobile/shared/services/base_service.dart';

import '../model/user.dart';
import 'package:http/http.dart' as http;

class AuthService extends BaseService {

  AuthService() : super("authentication");

  Future<User> signIn(String username, String password) async {
    final res = await http.post(
        Uri.parse('${fullPath()}/sign-in'),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'userName': username,
          'password': password,
        })
    );

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 500) {
      throw Exception('Usuario o contraseña incorrectos.');
    }
    else {
      throw Exception('Error al iniciar sesión: ${res.body}');
    }
  }

  Future<User> signUp(String username, String password, String role) async {
    final res = await http.post(
        Uri.parse('${fullPath()}/sign-up'),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'userName': username,
          'password': password,
          'roles': [
            role
          ]
        })
    );

    if (res.statusCode == 201) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error al registrar usuario: ${res.body}');
    }
  }
}