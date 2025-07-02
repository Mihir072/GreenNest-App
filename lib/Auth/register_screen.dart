// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:greennest/Auth/login_screen.dart';
import 'package:greennest/Helper/loader_extensions.dart';
import 'package:greennest/Helper/navigation_extensions.dart';
import 'package:greennest/Helper/spacing_helper.dart';
import 'package:greennest/Screens/home_screen.dart';
import 'package:greennest/Services/api_service.dart';
import 'package:greennest/Util/colors.dart';
import 'package:greennest/Util/icons.dart';
import 'package:greennest/Util/sizes.dart';
import 'package:greennest/Util/strings.dart';
import 'package:greennest/Widget/custom_button.dart';
import 'package:greennest/Widget/custom_text.dart';
import 'package:greennest/Widget/custom_text_field.dart';
import 'package:greennest/Widget/custom_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.showLoader(message: loadingIn);
    final response = await ApiService.registerUser(
      name: nameCtrl.text,
      email: emailCtrl.text,
      password: passwordCtrl.text,
      address: addressCtrl.text,
    );
    context.hideLoader();
    if (response.statusCode == 200 || response.statusCode == 201) {
      CustomToast.show(
          title: successRegister,
          message: successRegisterMessage,
          bgColor: green,
          iconUrl: successRegisterIcon);
      context.push(HomeScreen());
    } else {
      CustomToast.show(
          title: failedRegister,
          message: failedRegisterMessage,
          bgColor: red,
          iconUrl: failedRegisterIcon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: Spacing.all20,
          child: Center(
            child: SingleChildScrollView(
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
                            text: registerHeadline,
                            textColor: Colors.black,
                            textSize: GSizes.fontSizeLg,
                            fontWeight: FontWeight.bold),

                        //----- Text -----//
                        CustomText(
                            text: registerSubHeadline,
                            textColor: Colors.black,
                            textSize: GSizes.fontSizeMd,
                            fontWeight: FontWeight.normal),
                        SizedBox(
                          height: GSizes.defaultSpace,
                        ),

                        //----- Text Field -----//
                        CustomTextField(
                          controller: nameCtrl,
                          hintText: name,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          textFieldImage: textFieldImageName,
                        ),

                        SizedBox(
                          height: GSizes.spaceBtwInputFields,
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

                        SizedBox(
                          height: GSizes.spaceBtwInputFields,
                        ),

                        //----- Text Field -----//
                        CustomTextField(
                          controller: addressCtrl,
                          hintText: address,
                          obscureText: false,
                          keyboardType: TextInputType.multiline,
                          textFieldImage: textFieldImageAddress,
                        ),

                        SizedBox(
                          height: GSizes.spaceBtwInputFields,
                        ),

                        //----- Button -----//
                        CustomButton(
                          text: registerText,
                          onPressed: register,
                          backgroundColor: splashScreenColor,
                        ),

                        //----- Text Button -----//
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () => context.push(LoginScreen()),
                                child: Text(alreadyHaveAnAccount)),
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
      ),
    );
  }
}
