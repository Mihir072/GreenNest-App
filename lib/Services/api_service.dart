import 'dart:convert';
import 'package:greennest/Helper/email_request.dart';
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

  //--------------------- SHOW ALL PLANTS ---------------------//

  static Future<http.Response> getPlants() async {
    return await http.get(Uri.parse('$baseUrl/plants'));
  }

  //--------------------- SEARCH PLANTS BY NAME ---------------------//

  static Future<http.Response> searchPlants(String query) async {
    return await http.get(Uri.parse('$baseUrl/plants/search?q=$query'));
  }

  //--------------------- PLACE ORDER ---------------------//

  static Future<http.Response> placeOrder({
    required String token,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required String address,
    required String name,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/orders/place'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'totalAmount': totalAmount,
        'address': address,
        'name': name
      }),
    );
  }

  //--------------------- GET MY ORDERS ---------------------//

  static Future<http.Response> getMyOrders({required String token}) async {
    return await http.get(
      Uri.parse('$baseUrl/orders/my-orders'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  //--------------------- GET USER INFO ---------------------//

  static Future<http.Response> getUserByEmail(String email) async {
    return await http.get(Uri.parse('$baseUrl/auth/users/$email'));
  }

  //--------------------- Email Sending ---------------------//

  static Future<http.Response> sendOrderEmail({
    required String token,
    required EmailRequest emailRequest,
  }) async {
    final url = Uri.parse('$baseUrl/orders/send-confirmation-email');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(emailRequest.toJson()),
    );
  }

  //--------------------- Logout ---------------------//

  static Future<http.Response> logout(String token) async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
