// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:greennest/Helper/media_query_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field2.dart';
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
      backgroundColor: white,
      //--------------------- APPBAR ---------------------//
      appBar: AppBar(
        backgroundColor: white,
        title: CustomText(
            text: 'Welcome, $username',
            textColor: black,
            textSize: GSizes.fontSizeLg,
            fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: CircleAvatar(
                backgroundImage: NetworkImage(profileHome),
                radius: 20,
              ),
              onTap: () => context.push(
                ProfileScreen(email: widget.email, token: widget.token),
              ),
            ),
          ),
        ],
      ),
      //--------------------- BODY ---------------------//
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: Spacing.all8,
              child: CustomText(
                  text:
                      '''Welcome to Green Harbor, your go-to destination for all things green and thriving! 🌿''',
                  textColor: black,
                  textSize: GSizes.fontSizeSm,
                  fontWeight: FontWeight.normal),
            ),
            Padding(
              padding: Spacing.all8,
              child: CustomTextField2(
                  hintText: searchPlants,
                  keyboardType: TextInputType.text,
                  textFieldImage: treeHome),
            ),
            //--------------------- PLANT LIST ---------------------//
            Expanded(
              child: ListView.builder(
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return Container(
                    decoration: BoxDecoration(
                        color: white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0,
                                4), // You can make it (0, 0) for equal all sides
                          ),
                        ],
                        border: Border.all(color: borderGrey),
                        borderRadius:
                            BorderRadius.circular(GSizes.borderRadiusMd)),
                    margin: Spacing.all8,
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
      ),
      //--------------------- cART BOX ---------------------//
      bottomNavigationBar: cart.isNotEmpty
          ? GestureDetector(
              onTap: () => context.push(
                CartScreen(
                  token: widget.token,
                  cart: cart,
                  email: widget.email,
                  onOrderPlaced: () {
                    setState(() {
                      cart.clear();
                    });
                  },
                ),
              ),
              child: Container(
                height: context.heightPct(11),
                color: cartBoxColor,
                padding: Spacing.all16,
                child: Column(
                  children: [
                    CustomText(
                        text: '${cart.length} items added ➲',
                        textColor: white,
                        textSize: GSizes.fontSizeLg,
                        fontWeight: FontWeight.bold),
                    CustomText(
                        text: 'Total: ₹${getTotalAmount()}',
                        textColor: white,
                        textSize: GSizes.fontSizeMd,
                        fontWeight: FontWeight.normal),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
