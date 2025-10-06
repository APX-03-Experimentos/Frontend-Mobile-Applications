import 'package:flutter/cupertino.dart';
import 'package:learnhive_mobile/auth/services/auth_service.dart';

import '../model/user.dart';
import '../services/token_service.dart';

class AuthViewModel extends ChangeNotifier {

  final _authService = AuthService();

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
        await TokenService.saveToken(_user!.token!);
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    await TokenService.clearToken();
    notifyListeners();
  }
}