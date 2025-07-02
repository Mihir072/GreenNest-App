import 'package:flutter/material.dart';
import 'package:greennest/services/api_service.dart';
import 'dart:convert';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String token;

  const HomeScreen({super.key, required this.email, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> plants = [];
  List<dynamic> cart = [];
  String searchQuery = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchPlants();
    fetchUserInfo();
  }

  Future<void> fetchPlants() async {
    final response = searchQuery.isEmpty
        ? await ApiService.getPlants()
        : await ApiService.searchPlants(searchQuery);

    if (response.statusCode == 200) {
      setState(() {
        plants = jsonDecode(response.body);
      });
    }
  }

  Future<void> fetchUserInfo() async {
    final response = await ApiService.getUserByEmail(widget.email);
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      setState(() {
        username = user['name'] ?? '';
      });
    }
  }

  void addToCart(dynamic plant) {
    setState(() {
      cart.add({...plant, 'quantity': 1});
    });
  }

  int getTotalAmount() {
    return cart.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as num) * (item['quantity'] as num)).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(email: widget.email, token: widget.token),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Search plants...'),
              onChanged: (val) {
                setState(() => searchQuery = val);
                fetchPlants();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(plant['imageUrl'],
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(plant['name']),
                    subtitle: Text("₹${plant['price']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => addToCart(plant),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isNotEmpty
          ? GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(
                    token: widget.token,
                    cart: cart,
                    email: widget.email,
                    onOrderPlaced: () {
                      setState(() {
                        cart.clear(); // Clear cart in HomeScreen too
                      });
                    },
                  ),
                ),
              ),
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${cart.length} items in cart',
                        style: const TextStyle(color: Colors.white)),
                    Text('Total: ₹${getTotalAmount()}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
