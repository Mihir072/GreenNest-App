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
    fetchPlants('');
    fetchUserInfo();
  }

  Future<void> fetchPlants(String query) async {
    final response = query.isEmpty
        ? await ApiService.getPlants()
        : await ApiService.searchPlants(query);

    if (response.statusCode == 200) {
      setState(() {
        searchQuery = query;
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
      backgroundColor: splashScreenColor,

      //--------------------- BODY ---------------------//
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                      text: 'Hey, $username',
                      textColor: white,
                      textSize: GSizes.fontSizeLg,
                      fontWeight: FontWeight.bold),
                  GestureDetector(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profileHome),
                      radius: 20,
                    ),
                    onTap: () => context.push(
                      ProfileScreen(email: widget.email, token: widget.token),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8, left: 12, bottom: 30),
              child: CustomText(
                  text: welcomeLine,
                  textColor: white,
                  textSize: GSizes.fontSizeSm,
                  fontWeight: FontWeight.normal),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15, left: 15),
              child: CustomTextField2(
                hintText: searchPlants,
                keyboardType: TextInputType.text,
                textFieldImage: treeHome,
                onChanged: (val) {
                  fetchPlants(val);
                },
              ),
            ),

            SizedBox(
              height: context.heightPct(6),
            ),
            //--------------------- PLANT LIST ---------------------//
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: homeBackgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36))),
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await fetchPlants('');
                      await fetchPlants(searchQuery);
                    },
                    child: GridView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      padding: EdgeInsets.all(16),
                      itemCount: plants.length,
                      itemBuilder: (context, index) {
                        final plant = plants[index];

                        return Material(
                          elevation: 4,
                          borderRadius:
                              BorderRadius.circular(GSizes.borderRadiusMd),
                          shadowColor: Colors.grey.shade200,
                          child: Container(
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius:
                                  BorderRadius.circular(GSizes.borderRadiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          GSizes.borderRadiusMd),
                                    ),
                                    child: Image.network(
                                      plant['imageUrl'],
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // Text Info
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: plant['name'],
                                        textColor: black,
                                        textSize: GSizes.fontSizeMd,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      CustomText(
                                        text: "₹${plant['price']}",
                                        textColor: Colors.green.shade700,
                                        textSize: GSizes.fontSizeMd,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),

                                // Add Button (No Spacer)

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => addToCart(plant),
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
