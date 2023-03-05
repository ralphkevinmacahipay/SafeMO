import 'dart:async';
import 'package:accounts/sound_image_code/sound_images_code.dart';

import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_exception.dart';
import 'package:accounts/services/auth/auth_service.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtool show log;

import 'home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  final _auth = FirebaseAuth.instance;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    isEmailVerified = AuthService.firebase().currentUser!.isEmailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      timer =
          Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerify());
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  // deleteCollection() async {
  //   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //   User? user = _auth.currentUser;
  //   await firebaseFirestore.collection("users").doc(user!.uid).delete();
  // }

  deleteCollection() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    await firebaseFirestore.collection("users").doc(user!.uid).delete();
    //await AuthService.firebase().logout();
    await FirebaseAuth.instance.currentUser!.delete();
  }

  Future checkEmailVerify() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  Future sendVerificationEmail() async {
    try {
      await AuthService.firebase().sendEmailVerification();
    } on UserNotLogInAuthException {
      await showErrorDialog(context, 'User not Found');
    } on GenericAuthException {
      await showErrorDialog(context, 'Authentication error');
    }
  }

  //  // ---------------------------> Back Button <---------------------------
  //   final backButton = ElevatedButton(
  //     onPressed: () async {
  //       AuthService.firebase().logout();
  //       Navigator.of(context)
  //           .pushNamedAndRemoveUntil(registerPageRoute, (route) => false);
  //     },
  //     child: const Text('Back'),
  //   );

  // ---------------------------> verify Button <---------------------------

  double boxConstraintsMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double boxConstraintsMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  // ---------------------------> Scaffold <---------------------------

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomePage()
      : Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () async {
                deleteCollection();
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
            child: SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: boxConstraintsMaxWidth(context),
                    maxWidth: boxConstraintsMaxWidth(context),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(
                          Icons.lock_clock,
                          size: 60,
                        ),
                        Text(
                            "A verification \nlink has been sent to your \nemail",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.amber[600],
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            )),

                        Column(
                          children: [
                            const Text(
                              "Not yet received?",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                              ),
                            ),
                            TextButton(
                                onPressed: () async {
                                  AuthService.firebase()
                                      .sendEmailVerification();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      splashRoute, (route) => false);
                                },
                                child: const Text('Resend code',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ))),
                          ],
                        ),

                        // backButton,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
