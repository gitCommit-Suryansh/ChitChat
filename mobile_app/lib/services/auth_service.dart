import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Use 10.0.2.2 for Android emulator to access localhost
  // Use your machine's IP address for physical device
  // static const String baseUrl = "http://10.0.2.2:5000/api/user";
  static const String baseUrl = "http://10.62.60.169:5000/api/user";

  Future<User?> login(String email, String password) async {
    print("Attempting login to $baseUrl/login");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10));

      print("Login response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login success, data: $data");
        User user = User.fromJson(data);
        
        // Save user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userInfo', jsonEncode(data));
        
        return user;
      } else {
        print("Login failed: ${response.body}");
        throw Exception("Failed to login: ${response.body}");
      }
    } catch (e) {
      print("Login error: $e");
      throw Exception("Error logging in: $e");
    }
  }

  Future<User?> signup(String name, String email, String password, String pic) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "pic": pic,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        User user = User.fromJson(data);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userInfo', jsonEncode(data));
        
        return user;
      } else {
        throw Exception("Failed to signup: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error signing up: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userInfo');
  }
}
