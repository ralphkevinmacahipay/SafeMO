import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class GenericSplashScreen extends StatefulWidget {
  const GenericSplashScreen({Key? key, this.isChangRouteAllowed})
      : super(key: key);
  final String? isChangRouteAllowed;

  @override
  State<GenericSplashScreen> createState() => _GenericSplashScreenState();
}

class _GenericSplashScreenState extends State<GenericSplashScreen> {
  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => checkerBool());
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void checkerBool() {
    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) => isLoading
      ? chosePage(const GenericSplashScreen().isChangRouteAllowed)
      : Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitCircle(
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Loading...',
                  style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        );

  chosePage(screen) {
    Navigator.pushAndRemoveUntil(context, screen, (route) => false);
  }
}

class DefaultSplashView {
  Widget defaultSplash() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitCircle(
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Loading...',
              style: GoogleFonts.lato(
                fontStyle: FontStyle.normal,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
