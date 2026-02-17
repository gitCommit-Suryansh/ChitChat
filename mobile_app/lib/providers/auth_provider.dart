import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password, String pic) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signup(name, email, password, pic);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userInfo')) return;

    final extractedUserData = json.decode(prefs.getString('userInfo')!) as Map<String, dynamic>;
    _user = User.fromJson(extractedUserData);
    notifyListeners();
  }
}
