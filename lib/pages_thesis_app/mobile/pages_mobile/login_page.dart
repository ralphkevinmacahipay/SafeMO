// ignore_for_file: file_names, unused_local_variable, deprecated_member_use
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_exception.dart';
import 'package:accounts/services/auth/auth_service.dart';
import 'package:accounts/utility/error_dialog.dart';

import 'package:flutter/material.dart';
import 'dart:developer' as devtool show log;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void onButtonTappedHomePage() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(splashRoute, (route) => false);
  }

  void onButtonTappedVerify() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
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

    // ---------------------------> password input <----------------------------

    final inputPassword = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(Icons.vpn_key_sharp),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  passwordInVisible = !passwordInVisible;
                  devtool.log("code is here");
                  devtool.log(passwordInVisible.toString());
                });
              },
              icon: Icon(
                  passwordInVisible ? Icons.visibility_off : Icons.visibility),
            ),
            hintText: "Enter your password",
            labelText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            )),
        obscureText: passwordInVisible,
        enableSuggestions: false,
        autocorrect: false,
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Input field is empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password (Min. 6 characters)");
          }
          return null;
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
      ),
    );

// ---------------------------> Forgot Password Button <------------------
    final forgotButton = TextButton(
      child: const Text(
        "Forgot Password",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(forgotpasswordPageRoute, (route) => false);
      },
    );

// ---------------------------> Login Button <---------------------------

    final loginButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final email = emailController.text;
            final password = passwordController.text;
            try {
              await AuthService.firebase()
                  .login(email: email, password: password);
              final user = AuthService.firebase().currentUser;

              if (user?.isEmailVerified ?? false) {
                onButtonTappedHomePage();
              } else {
                onButtonTappedVerify();
              }
            } on UserNotFoundAuthException {
              await showErrorDialog(context, 'User not Found');
            } on WrongPasswordAuthException {
              await showErrorDialog(context, 'Wrong Password');
            } on GenericAuthException {
              await showErrorDialog(context, 'Authentication error');
            }
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Text(
              "Sign In",
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
// ---------------------------> Don't Have an aaccount (Text)<--------------
    const noAccountText = Text("Don't have an aaccount Create now!");
// ---------------------------> Register Button <---------------------------
    final registerButton = TextButton(
      onPressed: () async {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(registerPageRoute, (route) => false);
      },
      child: const Text(
        'Sign Up',
      ),
    );
// ---------------------------> Scaffold <---------------------------
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      logo,
                      height: 200,
                      width: 200,
                    ),
                    const SizedBox(height: 40),
                    inputEmail,
                    const SizedBox(height: 30),
                    inputPassword,
                    forgotButton,
                    const SizedBox(height: 15),
                    loginButton,
                    const SizedBox(height: 50),
                    noAccountText,
                    registerButton,
                  ],
                ),
              ),
            ),
          ),
        ), /* add child content here */
      ),
    );
  }
}
