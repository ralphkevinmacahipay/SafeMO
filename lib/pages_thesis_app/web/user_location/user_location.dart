import 'package:accounts/no_sql_db/nosql_db.dart';
import 'package:accounts/pages_thesis_app/web/side_menu/side_menu.dart';
import 'package:accounts/pages_thesis_app/web/user_location/services_record.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:developer' as devstool show log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class UserLocation extends StatefulWidget {
  const UserLocation({super.key});
  static String? nameUser;
  static String? description;
  static String? scene;
  static String? time;
  static bool? isThisReport;
  static String? userUID;

  @override
  State<UserLocation> createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  RecordModel recordModel = RecordModel();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final auth = FirebaseFirestore.instance;
  final loc.Location location = loc.Location();
  bool? isLiveTracking;
  late GoogleMapController _controller;
  LatLng? coordinatesVictim;
  final TextEditingController nameUserController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController sceneController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController rescuerController = TextEditingController();

  @override
  void initState() {
    devstool.log(UserLocation.userUID.toString());

    super.initState();
    isLiveTracking ??= false;
    coordinatesVictim ??= const LatLng(0, 0);
    nameUserController.text = UserLocation.nameUser.toString();
    descriptionController.text = UserLocation.description.toString();
    sceneController.text = UserLocation.scene.toString();
    timeController.text = UserLocation.time.toString();
  }

  @override
  void dispose() {
    isLiveTracking = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    devstool.log(UserLocation.isThisReport.toString());
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: SideMenu(),
          ),
          Expanded(
            flex: 5,
            child: UserLocation.isThisReport!
                ? locationOFUser()
                : const GoogleMap(
                    initialCameraPosition: CameraPosition(
                        zoom: 9, target: LatLng(9.740696, 118.7355555556))),
          )
        ],
      ),
    );
  }

  Visibility btn(String title, onPressed) {
    return Visibility(
      visible: UserLocation.isThisReport! ? true : false,
      child: Container(
        margin: const EdgeInsets.all(30),
        child: FloatingActionButton.extended(
          heroTag: null,
          backgroundColor: title == "Add Report" ? Colors.blue : Colors.red,
          label: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          // TODO PERFORM ADD RECORD
          onPressed: onPressed,
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> locationOFUser() {
    return StreamBuilder(
      stream: auth
          .collection("admin")
          .where("uid", isEqualTo: UserLocation.userUID)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // if (isLiveTracking!) {
        //   listenLocation(snapshot);

        //   devstool.log("Code is here");
        // }
        if (snapshot.hasData) {
          if (snapshot.hasError) {
            return Text(snapshot.hasError.toString());
          } else {
            coordinatesVictim = LatLng(
                snapshot.data!.docs.singleWhere((element) =>
                    element.id == UserLocation.userUID)["latitude"],
                snapshot.data!.docs.singleWhere((element) =>
                    element.id == UserLocation.userUID)["longitude"]);
            if (isLiveTracking!) {
              listenLocation(coordinatesVictim);
              devstool.log("coordinatesVictim : $coordinatesVictim");
            }

            devstool.log(
                "Latitude: ${snapshot.data!.docs.singleWhere((element) => element.id == UserLocation.userUID)["latitude"]}");
            devstool.log(
                "Longitude: ${snapshot.data!.docs.singleWhere((element) => element.id == UserLocation.userUID)["longitude"]}");
            return Consumer<RecordServices>(
              builder: (context, servicesReport, child) {
                servicesReport.setUserLoc(coordinatesVictim!);

                devstool.log(
                    'servicesReport.getUserLoc : ${servicesReport.getUserLoc}');

                return GoogleMap(
                  markers: {
                    Marker(
                      markerId: const MarkerId("current_marker_id"),
                      infoWindow: const InfoWindow(title: "User"),
                      icon: BitmapDescriptor.defaultMarker,
                      //TODO marker not done
                      position: servicesReport.getUserLoc,
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                    zoom: 12.5,
                    target: LatLng(
                      snapshot.data!.docs.singleWhere((element) =>
                          element.id == UserLocation.userUID)["latitude"],
                      snapshot.data!.docs.singleWhere((element) =>
                          element.id == UserLocation.userUID)["longitude"],
                    ),
                    bearing: 200.8334901395799,
                    tilt: 60.440717697143555,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    isLiveTracking = true;
                  },
                );
              },
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future _deleteRecord() {
    return QuickAlert.show(
      onConfirmBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
        Fluttertoast.showToast(
          fontSize: 20,
          msg: "Deleted Succesfully!",
        );
        await firebaseFirestore
            .collection("reports")
            .doc(UserLocation.userUID)
            .delete();
        await firebaseFirestore
            .collection("admin")
            .doc(UserLocation.userUID)
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

  Future _submitRecord() => showDialog(
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
                      decoration: _styleInput(),
                      readOnly: true),
                  TextFormField(
                    controller: descriptionController,
                    decoration: _styleInput(),
                  ),
                  TextFormField(
                      controller: sceneController,
                      decoration: _styleInput(),
                      readOnly: true),

                  TextFormField(
                    controller: timeController,
                    onSaved: (newValue) {
                      timeController.text = newValue!;
                    },
                    decoration: _styleInputForm(true),
                  ),
                  TextFormField(
                    controller: rescuerController,
                    onSaved: (newValue) {
                      rescuerController.text = newValue!;
                    },
                    decoration: _styleInputForm(true),
                  ),

                  TextButton(
                      onPressed: () async {
                        QuickAlert.show(
                          width: 500,
                          autoCloseDuration: const Duration(seconds: 3),
                          context: context,
                          type: QuickAlertType.loading,
                          title: 'Loading',
                          text: 'Saving Record',
                        );
                        nameUserController.text =
                            UserLocation.nameUser.toString();
                        descriptionController.text =
                            UserLocation.description.toString();
                        sceneController.text = UserLocation.scene.toString();

                        nameUserController.text =
                            UserLocation.nameUser.toString();

                        recordModel.uid = UserLocation.userUID;
                        recordModel.nameUser = nameUserController.text;
                        recordModel.description = descriptionController.text;
                        recordModel.scene = sceneController.text;
                        recordModel.time = timeController.text;
                        recordModel.rescuer = rescuerController.text;

                        await firebaseFirestore
                            .collection("reports")
                            .doc(UserLocation.userUID)
                            .set(recordModel.toMap());
                        FirebaseFirestore.instance
                            .collection('admin')
                            .doc(UserLocation.userUID)
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
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ))
                  // Row(
                  //   children: [
                  //     const Text("Concern:"),
                  //     TextFormField(),
                  //   ],
                  // ),
                ],
              ),
            ),
          ));

  InputDecoration _styleInput() {
    return const InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          strokeAlign: 2,
        ),
      ),
    );
  }

  InputDecoration _styleInputForm(data) {
    return InputDecoration(
      hintText: !data ? "Type of Incident" : "Rescuer",
      border: const OutlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          strokeAlign: 2,
        ),
      ),
    );
  }

  listenLocation(coordinatesVictim) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: coordinatesVictim, zoom: 20),
      ),
    );
  }
}
