// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:greennest/Helper/email_request.dart';
import 'package:greennest/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartScreen extends StatefulWidget {
  final String token;
  final String email;
  final List<dynamic> cart;
  final VoidCallback? onOrderPlaced;

  const CartScreen(
      {super.key,
      required this.token,
      required this.cart,
      required this.email,
      this.onOrderPlaced});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic> userInfo = {};
  late List<dynamic> cart;

  @override
  void initState() {
    super.initState();
    cart = List.from(widget.cart);
    loadUserInfo();
  }

  void increaseQuantity(int index) {
    setState(() {
      cart[index]['quantity']++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cart[index]['quantity'] > 1) {
        cart[index]['quantity']--;
      }
    });
  }

  int getTotalAmount() {
    return cart.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as num) * (item['quantity'] as num)).toInt());
  }

  Future<void> loadUserInfo() async {
    final response = await ApiService.getUserByEmail(widget.email);
    if (response.statusCode == 200) {
      setState(() {
        userInfo = jsonDecode(response.body);
      });
    }
  }

  void placeOrder() async {
    final totalAmount = getTotalAmount();
    final address = userInfo['address'] ?? '';
    final name = userInfo['name'] ?? '';

    final items = cart
        .map((item) => {
              'plantId': item['id'],
              'name': item['name'],
              'price': item['price'],
              'quantity': item['quantity'],
            })
        .toList();

    final response = await ApiService.placeOrder(
      token: widget.token,
      items: items,
      totalAmount: totalAmount,
      address: address,
      name: name,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        cart.clear();
      });
      widget.onOrderPlaced?.call();
      Fluttertoast.showToast(msg: 'Order Placed Successfully');
      final email = userInfo['email'] ?? 'user@example.com';
      final name = userInfo['name'] ?? 'User';

      final message = '''
Hi $name,

Thank you for your order from GreenNest!
Total Amount: ₹$totalAmount
Delivery Address: $address

We’ll notify you when your plants are shipped.

Regards,
GreenNest Team
''';

      final emailRequest = EmailRequest(
        toEmail: email,
        subject: 'GreenNest - Order Confirmation',
        message: message,
      );

      await ApiService.sendOrderEmail(
        token: widget.token,
        emailRequest: emailRequest,
      );

      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: 'Failed to place order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  leading:
                      Image.network(item['imageUrl'], width: 50, height: 50),
                  title: Text(item['name']),
                  subtitle: Text("₹${item['price']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => decreaseQuantity(index)),
                      Text(item['quantity'].toString()),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => increaseQuantity(index)),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: Column(
              children: [
                Text('Total Amount: ₹${getTotalAmount()}'),
                ElevatedButton(
                  onPressed: placeOrder,
                  child: const Text('Place Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
