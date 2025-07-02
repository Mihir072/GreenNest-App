import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://greennest-backend.onrender.com';

  //--------------------- REGISTER ---------------------//

  static Future<http.Response> registerUser({
    required String name,
    required String email,
    required String password,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'address': address,
        'role': 'USER',
      }),
    );
    return response;
  }

  //--------------------- LOGIN ---------------------//

  static Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  //--------------------- FORGOT PASSWORD ---------------------//

  static Future<http.Response> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/passwordForgot/$email');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'password': newPassword,
      }),
    );
    return response;
  }
}
