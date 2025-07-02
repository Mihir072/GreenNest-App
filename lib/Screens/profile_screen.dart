import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Profile')),
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
