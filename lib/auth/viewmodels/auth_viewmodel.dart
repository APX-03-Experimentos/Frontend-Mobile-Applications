import 'package:flutter/cupertino.dart';
import 'package:learnhive_mobile/auth/services/auth_service.dart';

import '../../main.dart';
import '../model/user.dart';
import '../services/token_service.dart';
import '../services/user_service.dart';

class AuthViewModel extends ChangeNotifier {

  final _authService = AuthService();
  final _user_service = UserService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> signUp(String username, String password, String role) async {
    _setLoading(true);
    try {
      _user = await _authService.signUp(username, password, role);
      _error = null;

    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signIn(String username, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.signIn(username, password);
      _error = null;

      if (_user?.token != null) {
        // ✅ CORREGIDO: Usar saveUserInfo en lugar de saveToken
        await TokenService.saveUserInfo(
          token: _user!.token!,
          userId: _user!.id,
          username: _user!.username,
          role: _user!.role, // ← Esto es lo más importante
        );

        debugPrint('✅ Usuario logueado correctamente:');
        debugPrint('   - ID: ${_user!.id}');
        debugPrint('   - Username: ${_user!.username}');
        debugPrint('   - Rol: ${_user!.role}');
        debugPrint('   - Token: ${_user!.token!.substring(0, 20)}...');

        _navigateToCourses();
      } else {
        _error = "Error: No se recibió token del servidor";
      }

    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error en signIn: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    // ✅ CORREGIDO: Usar clearUserInfo en lugar de clearToken
    await TokenService.clearUserInfo();
    notifyListeners();
  }



  void _navigateToCourses() {
    if (_user != null) {
      // Usar postFrameCallback para evitar errores de contexto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MyApp.navigatorKey.currentState?.pushReplacementNamed('/courses');
      });
    }
  }

  Future<User> updateUser(String userName, String password) async{
    _setLoading(true);
    try {
      final updatedUser = await _user_service.updateUser(userName, password);
      if (_user != null && updatedUser.id == _user!.id) {
        // Si el usuario actualizado es el usuario actual, actualizar la información local
        _user = updatedUser;
      }
      _error = null;
      return updatedUser;
    } catch (e) {
      _error = e.toString();
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> deleteUser(int userId) async{
    _setLoading(true);
    try {
      final deletedUser = await _user_service.deleteUser(userId);
      if (deletedUser != null && _user != null && deletedUser.id == _user!.id) {
        // Si el usuario eliminado es el usuario actual, cerrar sesión
        await signOut();
      }
      _error = null;
      return deletedUser;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }

  }

  Future<User> getUserById(int userId) async{
    _setLoading(true);
    try {
      final user = await _user_service.getUserById(userId);
      _error = null;
      return user;
    } catch (e) {
      _error = e.toString();
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    } finally {
      _setLoading(false);
    }


  }

  Future<List<User>> getAllUsers() async{
    _setLoading(true);
    try {
      final users = await _user_service.getAllUsers();
      _error = null;
      return users;
    } catch (e) {
      _error = e.toString();
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    } finally {
      _setLoading(false);
    }

  }

  Future<User> getUserByuserName(String userName) async{
    _setLoading(true);
    try {
      final user = await _user_service.getUserByuserName(userName);
      _error = null;
      return user;
    } catch (e) {
      _error = e.toString();
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    } finally {
      _setLoading(false);
    }

  }

  Future<void> leaveGroup(int courseId) async{
    _setLoading(true);
    try {
      await _user_service.leaveGroup(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }


  }

  Future<List<User>> getUsersByCourseId(int courseId) async{
    _setLoading(true);
    try {
      final users = await _user_service.getUsersByCourseId(courseId);
      _error = null;
      return users;
    } catch (e) {
      _error = e.toString();
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    } finally {
      _setLoading(false);
    }


  }

  Future<User> getCurrentUser() async{
    _setLoading(true);
    try {
      final userId = await TokenService.getUserId();
      if (userId != null) {
        _user = await _user_service.getUserById(userId);
        _error = null;
        return _user!;
      } else {
        throw Exception('No user ID found in token');
      }
    } catch (e) {
      _error = e.toString();
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    } finally {
      _setLoading(false);
    }


  }


}