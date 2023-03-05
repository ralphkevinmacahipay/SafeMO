// ignore_for_file: file_names, unused_local_variable, deprecated_member_use
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_exception.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'dart:developer' as devtool show log;

import 'package:quickalert/quickalert.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool passwordInVisible = true;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    devtool.log("dispose Start");
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onButtonTappedLogIn() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // ---------------------------> email input <------------------------------
    final inputEmail = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        enableSuggestions: true,
        autocorrect: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          RegExp regex = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
          );
          if (value!.isEmpty) {
            return ("Input field is empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Invalid email");
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!;
        },
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(Icons.email_outlined),
            hintText: "Enter your email",
            labelText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            )),
        textInputAction: TextInputAction.next,
      ),
    );

// ---------------------------> Login Button <---------------------------

    final resetPassBTN = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final email = emailController.text;
            final password = passwordController.text;
            // showDialog(
            //     context: context,
            //     barrierDismissible: false,
            //     builder: (context) => const Center(
            //           child: CircularProgressIndicator(),
            //         ));
            QuickAlert.show(
              autoCloseDuration: const Duration(seconds: 3),
              context: context,
              type: QuickAlertType.loading,
              title: 'Loading',
              text: 'Sending Email',
            );
            await Future.delayed(const Duration(seconds: 3));
            try {
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: email.trim());
              QuickAlert.show(
                title: "Reset Password",
                context: context,
                onConfirmBtnTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      loginPageRoute, (route) => false);
                },
                type: QuickAlertType.success,
                text: 'Check your email or spam inbox',
              );
            } on UserNotFoundAuthException {
              await showErrorDialog(context, 'User not Found');
            }
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Text(
              "Reset Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

// ---------------------------> Scaffold <---------------------------
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () async {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 60),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Receive an email to reset your password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      inputEmail,
                      const SizedBox(height: 15),
                      resetPassBTN,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
