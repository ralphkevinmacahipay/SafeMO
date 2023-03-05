import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_exception.dart';
import 'package:accounts/services/auth/auth_service.dart';
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devstool show log;

class RegisterPageBackUp extends StatefulWidget {
  const RegisterPageBackUp({Key? key}) : super(key: key);

  @override
  State<RegisterPageBackUp> createState() => _RegisterPageBackUpState();
}

class _RegisterPageBackUpState extends State<RegisterPageBackUp> {
  bool inputCheck = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameUserController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController reInputPasswordController;

  @override
  void initState() {
    nameUserController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    reInputPasswordController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    devstool.log("dispose Start");
    nameUserController.dispose();
    emailController.dispose();
    passwordController.dispose();
    reInputPasswordController.dispose();
    super.dispose();
  }

  void onButtonTappedVerify() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Navigator.of(context).pushNamed(verifyEmailRoute);
  }

  @override
  Widget build(BuildContext context) {
    // ---------------------------> Name User <-----------------------------
    final inputUserName = TextFormField(
      enableSuggestions: true,
      autocorrect: false,
      controller: nameUserController,
      keyboardType: TextInputType.name,
      onSaved: (value) {
        nameUserController.text = value!;
      },
      decoration: InputDecoration(
          hintText: "Enter your name",
          labelText: "Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          )),
      textInputAction: TextInputAction.next,
    );
    // ---------------------------> email input <---------------------------
    final inputEmail = TextFormField(
      enableSuggestions: true,
      autocorrect: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      // ---------------------------> Not now
      validator: (value) {
        RegExp regex = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        );
        if (value!.isEmpty) {
          return ("Please enter your email");
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
          hintText: "Enter your email",
          labelText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          )),
      textInputAction: TextInputAction.next,
    );

    // ---------------------------> password input <---------------------------

    final inputPassword = TextFormField(
      enableSuggestions: false,
      autocorrect: false,
      controller: passwordController,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Please enter your password");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password (Min. 6 characters)");
        }
        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      decoration: InputDecoration(
          hintText: "Enter your password",
          labelText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          )),
      textInputAction: TextInputAction.done,
    );

    // ---------------------------> re-input password input <---------------------------

    final reInputPassword = TextFormField(
      enableSuggestions: false,
      autocorrect: false,
      controller: reInputPasswordController,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Please enter your password");
        } else if (!regex.hasMatch(value)) {
          return ("Enter Valid Password (Min. 6 characters)");
        } else if (reInputPasswordController.text != passwordController.text) {
          return ("Password don't match");
        }
        return null;
      },
      onSaved: (value) {
        reInputPasswordController.text = value!;
      },
      decoration: InputDecoration(
          hintText: "Confirm Password",
          labelText: "Confirm Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          )),
      textInputAction: TextInputAction.done,
    );

// ---------------------------> Sign Up Button <---------------------------

    final registerButton = ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final email = emailController.text;
          final password = passwordController.text;
          try {
            await AuthService.firebase().createUser(
              email: email,
              password: password,
            );

            await AuthService.firebase().sendEmailVerification();
            onButtonTappedVerify();
          } on UserAlreadyExistsAuthException {
            showErrorDialog(context, 'Email already exists');
          } on GenericAuthException {
            showErrorDialog(context, "Register failed");
          }
        }
      },
      child: const Text("Sign Up"),
    );

// // ---------------------------> Back Button <---------------------------
//     final backButton = ElevatedButton(
//       onPressed: () async {
//         Navigator.of(context)
//             .pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
//       },
//       child: const Text('Back'),
//     );

// ---------------------------> Scaffold <---------------------------
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          color: Colors.white,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(logo),
                inputUserName,
                inputEmail,
                inputPassword,
                reInputPassword,
                registerButton,

                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.platform,
                  value: inputCheck,
                  onChanged: (_) {
                    setState(() {
                      inputCheck = true;
                    });
                  },
                  title: const Text('Terms and Conditions'),
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                )
                // backButton
              ],
            ),
          ),
        ), /* add child content here */
      ),
    );
  }
}
