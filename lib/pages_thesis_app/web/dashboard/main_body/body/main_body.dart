import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/pages_thesis_app/web/dashboard/main_body/model_user/model_user.dart';
import 'package:accounts/pages_thesis_app/web/dashboard/main_body/body/upper_part.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as devtools show log;

import '../../../../../no_sql_db/nosql_db.dart';
import '../../../user_location/services_record.dart';
import '../../../user_location/services_report_history.dart';
import '../../../user_location/user_location.dart';

class MainBody extends StatefulWidget {
  static AsyncSnapshot<QuerySnapshot>? snapshot;
  final List<User> users;

  const MainBody({
    super.key,
    required this.users,
  });

  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const BodyUpperPart(),
          const SizedBox(height: 20),
          const Text(
            "Reports",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[350],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SizedBox(width: 150, child: Text("Name")),
                  SizedBox(width: 150, child: Text("Description")),
                  SizedBox(width: 150, child: Text("Scene")),
                  SizedBox(width: 150, child: Text("Time")),
                  SizedBox(width: 150, child: Text("Action")),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 500,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 500,
              decoration: BoxDecoration(
                color: Colors.grey[200]!.withOpacity(.3),
              ),
              child: Consumer<RecordServices>(
                builder: (context, servicesRecord, child) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("admin")
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Consumer<HistoryServicesReport>(
                              builder: (context, servicesHistory, child) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 10, top: 10, left: 10),
                                  child: RowAdmin(
                                      servicesHistory: servicesHistory,
                                      servicesRecord: servicesRecord,
                                      index: index,
                                      snapshot: snapshot,
                                      kName:
                                          "${snapshot.data!.docs[index]['nameUser']}",
                                      kDescription:
                                          "${snapshot.data!.docs[index]['description']}",
                                      kScene: snapshot.data!.docs[index]
                                          ['scene'],
                                      kTime:
                                          "${snapshot.data!.docs[index]['time']}"),
                                );
                              },
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RowAdmin extends StatefulWidget {
  final HistoryServicesReport servicesHistory;
  AsyncSnapshot<QuerySnapshot> snapshot;
  final int index;
  final String kName;
  final String kDescription;
  final String kScene;
  final String kTime;
  final RecordServices servicesRecord;

  RowAdmin(
      {super.key,
      required this.index,
      required this.snapshot,
      required this.kName,
      required this.kDescription,
      required this.kScene,
      required this.kTime,
      required this.servicesRecord,
      required this.servicesHistory});

  @override
  State<RowAdmin> createState() => _RowAdminState();
}

class _RowAdminState extends State<RowAdmin> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  RecordModel recordModel = RecordModel();
  final TextEditingController nameUserController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sceneController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController rescuerController = TextEditingController();

  InputDecoration _styleInput(String title) {
    return InputDecoration(
      hintText: title,
      border: const OutlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          strokeAlign: 2,
        ),
      ),
    );
  }

  Future _submitRecord(AsyncSnapshot<QuerySnapshot> snapshot, index,
      HistoryServicesReport servicesHistory) {
    return showDialog(
        context: context,
        builder: (context) => Container(
              margin: const EdgeInsets.only(bottom: 50, top: 50),
              child: AlertDialog(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Submit Report"),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.cancel))
                  ],
                ),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextFormField(
                      controller: nameUserController,
                      onSaved: (nameVal) {
                        nameUserController.text = nameVal!;
                      },
                      decoration: _styleInput("Name"),
                    ),
                    TextFormField(
                      controller: descriptionController,
                      onSaved: (desVal) {
                        descriptionController.text = desVal!;
                      },
                      decoration: _styleInput("Description"),
                    ),
                    TextFormField(
                      controller: sceneController,
                      onSaved: (sceneVal) {
                        sceneController.text = sceneVal!;
                      },
                      decoration: _styleInput("Scene"),
                    ),
                    TextFormField(
                      controller: timeController,
                      onSaved: (timeVal) {
                        timeController.text = timeVal!;
                      },
                      decoration: _styleInput("Time"),
                    ),
                    TextFormField(
                      controller: rescuerController,
                      onSaved: (resVal) {
                        rescuerController.text = resVal!;
                      },
                      decoration: _styleInput("Rescuer or Fake Report Count"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            recordModel.uid = servicesHistory.getuserID;
                            recordModel.nameUser = nameUserController.text;
                            recordModel.description =
                                descriptionController.text;
                            recordModel.scene = sceneController.text;
                            recordModel.time = timeController.text;
                            recordModel.rescuer = rescuerController.text;
                            QuickAlert.show(
                              width: 500,
                              autoCloseDuration: const Duration(seconds: 3),
                              context: context,
                              type: QuickAlertType.loading,
                              title: 'Loading',
                              text: 'Saving Record',
                            );

                            await firebaseFirestore
                                .collection("reports")
                                .doc(recordModel.uid)
                                .set(recordModel.toMap());
                            FirebaseFirestore.instance
                                .collection('admin')
                                .doc(recordModel.uid)
                                .update({'status': 'Done'});

                            Fluttertoast.showToast(
                              fontSize: 20,
                              msg: "Added Succesfully!",
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _deleteRecord(servicesHistory),
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            recordModel.uid = servicesHistory.getuserID;
                            recordModel.nameUser = nameUserController.text;
                            recordModel.description =
                                descriptionController.text;
                            recordModel.scene = sceneController.text;
                            recordModel.time = timeController.text;
                            recordModel.rescuer = rescuerController.text;
                            QuickAlert.show(
                              width: 500,
                              autoCloseDuration: const Duration(seconds: 3),
                              context: context,
                              type: QuickAlertType.loading,
                              title: 'Loading',
                              text: 'Saving Fake Report',
                            );

                            await firebaseFirestore
                                .collection("fake_report")
                                .doc(recordModel.uid)
                                .set(recordModel.toMap());

                            Fluttertoast.showToast(
                              fontSize: 20,
                              msg: "Added Succesfully!",
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Fake Report",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  Future _deleteRecord(HistoryServicesReport servicesHistory) {
    return QuickAlert.show(
      onConfirmBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
        Fluttertoast.showToast(
          fontSize: 20,
          msg: "Deleted Succesfully!",
        );
        // await firebaseFirestore
        //     .collection("reports")
        //     .doc(UserLocation.userUID)
        //     .delete();
        await firebaseFirestore
            .collection("admin")
            .doc(servicesHistory.getuserID)
            .delete();
      },
      title: "Are you sure you want to delete this report?",
      onCancelBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      showCancelBtn: true,
      cancelBtnText: "Cancel",
      context: context,
      type: QuickAlertType.confirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    devtools.log(widget.kScene);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 150, child: Text(widget.kName)),
        SizedBox(width: 150, child: Text(widget.kDescription)),
        widget.kScene == "on the road"
            ? roadWidget(
                context: context,
                index: widget.index,
                snapshot: widget.snapshot,
                servicesRecord: widget.servicesRecord)
            : imageWidget(index: widget.index, snapshot: widget.snapshot),
        SizedBox(width: 150, child: Text(widget.kTime)),
        SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                widget.servicesHistory.setNameFields(
                    nameUser: widget.snapshot.data!.docs[widget.index]
                        ['nameUser'],
                    description: widget.snapshot.data!.docs[widget.index]
                        ['description'],
                    scene: widget.snapshot.data!.docs[widget.index]['scene'],
                    time: widget.snapshot.data!.docs[widget.index]['time'],
                    userID: widget.snapshot.data!.docs[widget.index]['uid']);

                nameUserController.text = widget.servicesHistory.getnameUser;
                descriptionController.text =
                    widget.servicesHistory.getdescription;
                sceneController.text = widget.servicesHistory.getscene;
                timeController.text = widget.servicesHistory.getTime;
                rescuerController.text = widget.servicesHistory.getrescuer;

                _submitRecord(
                    widget.snapshot, widget.index, widget.servicesHistory);
              },
              child: const Text("Report"),
            )),
      ],
    );
  }

  InkWell roadWidget(
      {required AsyncSnapshot<QuerySnapshot> snapshot,
      required index,
      required BuildContext context,
      required RecordServices servicesRecord}) {
    return InkWell(
        onTap: () {
          UserLocation.nameUser = snapshot.data!.docs[index]['nameUser'];
          UserLocation.description = snapshot.data!.docs[index]['description'];
          UserLocation.scene = snapshot.data!.docs[index]['scene'];
          UserLocation.time = snapshot.data!.docs[index]['time'];
          UserLocation.userUID = snapshot.data!.docs[index]['uid'];

          UserLocation.isThisReport = true;

          Navigator.of(context)
              .pushNamedAndRemoveUntil(userLocationWebRoute, (route) => false);
        },
        child: SizedBox(width: 150, child: Text(widget.kScene)));
  }

  InkWell imageWidget(
      {required AsyncSnapshot<QuerySnapshot> snapshot, required int index}) {
    devtools.log(
        "widget.servicesHistory.getscene : ${widget.servicesHistory.getscene}");
    return InkWell(
        onTap: () => snapshot.data!.docs[index]['scene'] == "unable to capture"
            ? null
            : _launchUrl(widget.kScene),
        child: SizedBox(
            width: 150,
            child: Text(
                snapshot.data!.docs[index]['scene'] == "unable to capture"
                    ? "Unable to Capture"
                    : "View Image")));
  }

  Future<void> _launchUrl(url) async {
    Uri uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
