// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:greennest/Auth/forgot_password_screen.dart';
import 'package:greennest/Auth/register_screen.dart';
import 'package:greennest/Helper/loader_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Screens/home_screen.dart';
import 'dart:convert';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_button.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field.dart';
import 'package:greennest/Widget/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.showLoader(message: loadingIn);

    try {
      final response = await ApiService.loginUser(
        email: emailCtrl.text,
        password: passwordCtrl.text,
      );

      context.hideLoader();
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);

          CustomToast.show(
            title: successLogin,
            message: successLoginMessage,
            bgColor: green,
            iconUrl: successLoginIcon,
          );

          print('Token: ${data["token"]}');
          context.pushReplacement(HomeScreen(
            email: data["email"],
            token: data["token"],
          ));
        } else {
          CustomToast.show(
            title: failedLogin,
            message: failedLogin,
            bgColor: red,
            iconUrl: failedLoginIcon,
          );
        }
      } else {
        String errorMessage = failedLoginMessage;
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? failedLoginMessage;
        }

        CustomToast.show(
          title: failedLogin,
          message: errorMessage,
          bgColor: red,
          iconUrl: failedLoginIcon,
        );
      }
    } catch (e) {
      context.hideLoader();

      CustomToast.show(
        title: error,
        message: somethingWentWrong,
        bgColor: red,
        iconUrl: failedLoginIcon,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.all20,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //----- Text -----//
                      CustomText(
                          text: loginHeadline,
                          textColor: Colors.black,
                          textSize: GSizes.fontSizeLg,
                          fontWeight: FontWeight.bold),

                      //----- Text -----//
                      CustomText(
                          text: loginSubHeadline,
                          textColor: Colors.black,
                          textSize: GSizes.fontSizeMd,
                          fontWeight: FontWeight.normal),
                      SizedBox(
                        height: GSizes.defaultSpace,
                      ),

                      //----- Text Field -----//
                      CustomTextField(
                        controller: emailCtrl,
                        hintText: email,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        textFieldImage: textFieldImageEmail,
                      ),

                      SizedBox(
                        height: GSizes.spaceBtwInputFields,
                      ),

                      //----- Text Field -----//
                      CustomTextField(
                        controller: passwordCtrl,
                        hintText: password,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textFieldImage: textFieldImagePassword,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () =>
                                  context.push(ForgotPasswordScreen()),
                              child: Text(forgotPassword)),
                        ],
                      ),
                      SizedBox(
                        height: GSizes.spaceBtwInputFields,
                      ),

                      //----- Text -----//
                      CustomButton(
                        text: loginText,
                        onPressed: login,
                        backgroundColor: splashScreenColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () => context.push(RegisterScreen()),
                              child: Text(dontHaveAnAccount)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
