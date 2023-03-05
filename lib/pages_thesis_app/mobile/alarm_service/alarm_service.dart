import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/no_sql_db/nosql_db.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/commuter_page/services_homepage.dart';

import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devstool show log;

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';

import '../chooseUser/commuter_page/services_report_commuter.dart';
import '../pages_mobile/home_page.dart';

class CountdownPage extends StatefulWidget {
  ReportCommuterServices? classServicesReport;
  CountdownPage({
    Key? key,
    // this.servicesReport,
  }) : super(key: key);

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with TickerProviderStateMixin {
  late ReportCommuterServices services;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  ReportModel caseUser = ReportModel();
  final auth = FirebaseFirestore.instance;

  final _user = FirebaseAuth.instance;
  bool? isReported;
  bool? codeStopperOn;
  bool? isFIrstAlarmOn;
  bool? isSendReport, disScreen;
  bool? isSecAlarmOn;

  late AnimationController controller;

  bool isPlaying = false;
  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double progress = 1.0;

  notify(ReportCommuterServices servicesReport,
      LocationServiceHome servicesCommuter) {
    if (countText == '00:00' && isFIrstAlarmOn!) {
      controller.reset();

      devstool.log("First Alarm Code");
      FlutterRingtonePlayer.play(
          volume: 1,
          looping: true,
          fromAsset: soundAlarm, // will be the sound on Android
          ios: IosSounds.glass // will be the sound on iOS
          );
      controller.duration = const Duration(seconds: 30);
      controller.reverse(from: controller.value == 0 ? 1.0 : controller.value);

      setState(() {
        isFIrstAlarmOn = false;
        isSecAlarmOn = true;
      });
    } else if (countText == '00:00' && isSecAlarmOn!) {
      FlutterRingtonePlayer.stop();
      controller.reset();
      controller.duration = const Duration(seconds: 10);
      controller.reverse(from: controller.value == 0 ? 1.0 : controller.value);
      setState(() {
        isSecAlarmOn = false;
        isSendReport = true;
      });
    } else if (countText == '00:00' && isSendReport!) {
      FlutterRingtonePlayer.play(
          volume: 1,
          looping: true,
          fromAsset: soundAlarm, // will be the sound on Android
          ios: IosSounds.glass // will be the sound on iOS
          );
      controller.reset();
      controller.duration = const Duration(seconds: 30);
      controller.reverse(from: controller.value == 0 ? 1.0 : controller.value);
      setState(() {
        disScreen = true;
        isSendReport = false;
      });
    } else if (countText == '00:00' && disScreen!) {
      setState(() {
        HomePage.alarmState = true;
        isReported = true;
      });
      FlutterRingtonePlayer.stop();
      controller.reset();
      Navigator.pop(context);
      servicesReport.setDescription("Unknown");
      servicesReport.setScene("on the road");

      servicesReport.insertCaseReport();
      servicesCommuter.setIsReported(servicesReport.getisReported);
      showRerscuerDialog(
          context,
          "You've Reported An Incident To 911 Wait For The Rescue",
          "Report An Incident");
    }
  }

  @override
  void initState() {
    // final serviceReport = ModalRoute.of(context)?.settings.arguments;
    super.initState();
    isReported ??= false;
    disScreen ??= false;
    isSendReport ??= false;
    codeStopperOn ??= false;
    isSecAlarmOn ??= false;
    isFIrstAlarmOn ??= true;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    controller.reverse(from: controller.value == 0 ? 1.0 : controller.value);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Consumer2<ReportCommuterServices, LocationServiceHome>(
        builder: (context, servicesReport, servicesCommuter, child) {
          controller.addListener(() {
            notify(servicesReport, servicesCommuter);

            if (controller.isAnimating) {
              setState(() {
                progress = controller.value;
              });
            } else {
              setState(() {
                progress = 1.0;
                isPlaying = false;
              });
            }
          });
          return StreamBuilder(
            stream: auth
                .collection("users")
                .where("uid", isEqualTo: _user.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                            backgroundColor: Colors.grey.shade300,
                            value: progress,
                            strokeWidth: 25,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: controller,
                          builder: (context, child) => Text(
                            countText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: SizeConfig.blockY! * 5),
                        child: FloatingActionButton.extended(
                          heroTag: null,
                          backgroundColor:
                              const Color.fromARGB(255, 250, 14, 14),
                          label: const Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Color.fromARGB(221, 250, 250, 250),
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          onPressed: () {
                            popAlert(servicesCommuter);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  popAlert(LocationServiceHome services) {
    services.setAlarmOn(false);
    controller.reset();
    FlutterRingtonePlayer.stop();

    // Navigator.pop(context);
    Navigator.pop(context);
    // return const UpdatedHomePage();
  }
}
