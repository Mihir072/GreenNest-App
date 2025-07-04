// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:greennest/Auth/login_screen.dart';
import 'package:greennest/services/api_service.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String email;
  final String token;

  const ProfileScreen({super.key, required this.email, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userInfo = {};
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    loadMyOrders();
  }

  Future<void> logout() async {
    try {
      final response = await ApiService.logout(widget.token);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Logged out successfully');
      } else {
        Fluttertoast.showToast(msg: 'Logout failed on server');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Logout error: $e');
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> loadUserInfo() async {
    final response = await ApiService.getUserByEmail(widget.email);
    if (response.statusCode == 200) {
      setState(() {
        userInfo = jsonDecode(response.body);
      });
    }
  }

  Future<void> loadMyOrders() async {
    final response = await ApiService.getMyOrders(token: widget.token);
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userInfo['name'] ?? ''}'),
            Text('Email: ${userInfo['email'] ?? ''}'),
            Text('Address: ${userInfo['address'] ?? ''}'),
            const SizedBox(height: 20),
            const Text('My Orders:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...orders.map((order) => Card(
                  child: ListTile(
                    title: Text('Order ID: ${order['id']}'),
                    subtitle: Text('Date: ${order['createdAt']}'),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
