import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/congifuration/style.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as devtools show log;
import '../../../services/auth/auth_service.dart';

class ChooseUser extends StatefulWidget {
  const ChooseUser({super.key});

  @override
  State<ChooseUser> createState() => _ChooseUserState();
}

class _ChooseUserState extends State<ChooseUser> {
  String imgURL = "";
  ImagePicker imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.blockY! * 2.5,
              ),
              Row(
                children: [
                  SizedBox(
                    width: SizeConfig.blockX! * 82.167,
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: SizeConfig.blockX! * 8,
                      )),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockY! * 23.125,
              ),
              Text(
                "Type Of User",
                style: kPoppinsSemiBold.copyWith(fontSize: 40),
              ),
              SizedBox(
                height: SizeConfig.blockY! * 14.375,
              ),
              GestureDetector(
                onTap: onTapCommuter,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockX! * 24.723,
                      vertical: SizeConfig.blockY! * 1.5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Text(
                    "Commuter",
                    style: kPoppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: SizeConfig.blockX! * 5.556),
                  ),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockY! * 8.875,
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, incidentReportPageRoute, (route) => false),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockX! * 18.056,
                      vertical: SizeConfig.blockY! * 1.5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Text(
                    "Report Incident",
                    style: kPoppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: SizeConfig.blockX! * 5.556),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onTapCommuter() {
    Navigator.pushNamedAndRemoveUntil(
        context, updatedHomePageRoute, (route) => false);
    devtools.log("I'm Commuter");
  }

  logout() async {
    await AuthService.firebase().logout();
    _logout();
  }

  _logout() {
    Navigator.pushNamedAndRemoveUntil(
        context, loginPageRoute, (route) => false);
  }
}
