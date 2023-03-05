// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:accounts/enum/enum.dart';
import 'package:accounts/maps_utility/location_service.dart';
import 'package:accounts/no_sql_db/encrypt_decrypt_service.dart';
import 'package:accounts/no_sql_db/nosql_db.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_service.dart';
import 'package:accounts/sound_image_code/sound_images_code.dart';
import 'package:accounts/utility/addnum_dialog.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:accounts/utility/logout_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:quickalert/quickalert.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static bool? alarmState;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  ReportModel caseUser = ReportModel();
  Offset position = Offset(20.0, 20.0);
  late AnimationController controllerCountDownt;
  String get countText {
    Duration count =
        controllerCountDownt.duration! * controllerCountDownt.value;
    return '${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool? isSetAlarm;
  final Mode _mode = Mode.overlay;
  Set<Marker> markerList = {};
  bool? isPanicShow;
  bool? isFindBtnOn;
  LatLng? currentCoordinates;
  LatLng? destinationCoordinates;
  final Set<Polyline> polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints? polyLinePoints;
  bool? isOutPutCreated;
  bool? isLocatioOn;
  bool? isStartBtnOn;
  bool? isArriveBtnOn;
  final _auth = FirebaseAuth.instance;
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool? isPermissionTrue;
  Verify verify = Verify();
  bool? gotEnabled;
  bool? isNameIsNotEmpty; //I used this
  bool? setIconCLear; //I used this
  bool? setBTNcodeReq; //I used this
  bool? isTheCodeSent; //I used this
  String? countDown; //I used this
  Timer? timer; //I used this
  var letterS = 's'; //I used this
  bool? isNumberNotEmpty;
  bool? isNumberValid;
  bool? isBTNTouch;
  LatLng? latlang;
  String? dropDownVehicle = "Tricycle";
  String? dropDownAlarm = "Set Alarm";
  String? destinationMarker = "";
  late GoogleMapController _controller;
  late final TextEditingController myNumberController;
  final auth = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    isPanicShow ??= false;
    HomePage.alarmState ??= false;
    controllerCountDownt = AnimationController(
      vsync: this,
      duration: Duration(seconds: 0),
    );
    isSetAlarm ??= false;
    polyLinePoints = PolylinePoints();
    destinationCoordinates = LatLng(48.864716, 2.349014);
    currentCoordinates = LatLng(48.864716, 2.349014);

    myNumberController = TextEditingController();
    _requestPermission();
    isPermissionTrue ??= false;
    setBTNcodeReq ??= false;
    isTheCodeSent ??= false;
    setIconCLear ??= false;
    isNameIsNotEmpty ??= true;
    isNumberValid ??= true;
    gotEnabled ??= false;
    isBTNTouch ??= false;

    latlang ??= LatLng(9.740696, 118.7355555556);

    isOutPutCreated ??= false;
    // 40.4165, -3.70256

    isStartBtnOn ??= false;
    isArriveBtnOn ??= false;
    isLocatioOn ??= false;
    isFindBtnOn ??= true;
    controllerCountDownt.addListener(() {
      notify();
    });
  }

  void checkIfSafe() {
    if (HomePage.alarmState!) {
      setState(() {
        controllerCountDownt.reverse(
            from: controllerCountDownt.value == 0
                ? 1.0
                : controllerCountDownt.value);
        isArriveBtnOn = true;
        HomePage.alarmState = false;
      });
      devtools.log("The HomePage().alarmState! is ${HomePage.alarmState}");
    } else {
      devtools.log("The HomePage().alarmState! is ${HomePage.alarmState}");
    }
  }

  void notify() {
    if (countText == '00:00' && isArriveBtnOn!) {
      setState(() {
        isArriveBtnOn = false;
      });
      Navigator.pushNamed(context, alarmScreenRoute);
    }
  }

  @override
  void dispose() {
    controllerCountDownt.dispose();

    myNumberController.dispose();
    _controller.dispose();
    _locationSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWith = MediaQuery.of(context).size.width;

    //-----------------------------------Profile button-------------------
    const profileBTN = PopupMenuItem<MenuAction>(
      value: MenuAction.profile,
      child: Text('Profile'),
    );
    //-----------------------------------ContactPerson button-----------------
    const contactPersonBTN = PopupMenuItem<MenuAction>(
      value: MenuAction.contactPerson,
      child: Text('Contact Person'),
    );

    //-----------------------------------About button-----------------
    const aboutBTN = PopupMenuItem<MenuAction>(
      value: MenuAction.about,
      child: Text('About'),
    );

    //-----------------------------------logout button-------------------
    const logoutBTN = PopupMenuItem<MenuAction>(
      value: MenuAction.logout,
      child: Text('Logout'),
    );

    //-----------------------------------back button-------------------
    const backBTN = PopupMenuItem<MenuAction>(
      value: MenuAction.back,
      child: Text('Back'),
    );

    //-----------------------------------Panic button-------------------
    final panic = StreamBuilder(
        stream: auth
            .collection("users")
            .where("uid", isEqualTo: _user.currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return Visibility(
            visible: isPanicShow! ? true : false,
            child: FloatingActionButton(
              enableFeedback: false,
              backgroundColor: Colors.red,
              onPressed: () {
                insertCaseReport(snapshot);
                showRerscuerDialog(
                    context,
                    "You've Reported An Incident To 911 Wait For The Rescue",
                    "Report An Incident");
              },
              child: Text(
                "Panic",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });

    //-----------------------------------PopUpbutton for logout (3 dots)--------
    final threeDOtsButton = PopupMenuButton<MenuAction>(
      icon: SvgPicture.asset(
        threeDots,
      ),
      onSelected: (value) async {
        switch (value) {
          case MenuAction.profile:
            Navigator.of(context)
                .pushNamedAndRemoveUntil(profilePageRoute, (route) => false);
            // add functionality
            break;
          case MenuAction.contactPerson:
            Navigator.of(context)
                .pushNamedAndRemoveUntil(contactpersonRoute, (route) => false);
            // TODO: Handle this case.
            break;
          case MenuAction.about:
            Navigator.of(context)
                .pushNamedAndRemoveUntil(contactPageRoute, (route) => false);
            // TODO: Handle this case.
            break;
          case MenuAction.back:
            await Future.delayed(Duration(seconds: 2));
            // futureDelay();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(chooseUserPageRoute, (route) => false);
            break;
          case MenuAction.logout:
            final showLogout = await showLogoutDialog(context);
            if (showLogout) {
              await AuthService.firebase().logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
            }
            break;
        }
      },
      itemBuilder: (context) {
        return [
          profileBTN,
          contactPersonBTN,
          aboutBTN,
          logoutBTN,
          backBTN,
        ];
      },
    );

    //-----------------------------------Destination TextField--------------
// TODO DAPAT DISABLE PAG WALA PA NA SET YUNG CURRENT LOCATION
    final destinaitonLoc = SizedBox(
      width: currentWith - 25,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25), color: Colors.white),
        child: TextButton(
          onPressed: _findDestination,
          child: Text(
            "Find Destination",
            style: TextStyle(
              wordSpacing: 5,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

    //-----------------------------------typeOfVehicle TextField--------------
    late final typeOfVehicle = SizedBox(
      height: 50,
      width: currentWith - 25,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: Align(
          alignment: Alignment.center,
          child: DropdownButton(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
            value: dropDownVehicle,
            onChanged: (String? newValue) {
              setState(() {
                dropDownVehicle = newValue;
              });
            },
            items: <String>[
              'Tricycle',
              "Motorcylce",
              'Multicab',
              'Private Vehicle'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );

    //------------------------------Start BTN ---------------------

    final startBTN = StreamBuilder<QuerySnapshot>(
        stream: auth
            .collection("users")
            .where("uid", isEqualTo: _user.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          return Opacity(
            opacity: isStartBtnOn! ? 1.0 : .3,
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.greenAccent[400],
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'START',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              onPressed: isStartBtnOn!
                  ? () async {
                      controllerCountDownt.reverse(
                          from: controllerCountDownt.value == 0
                              ? 1.0
                              : controllerCountDownt.value);
                      final nameContactPerson = snapshot.data!.docs.singleWhere(
                          (element) =>
                              element.id ==
                              _user.currentUser!.uid)["contactPerson.Name"];

                      final numberContactPerson = snapshot.data!.docs
                              .singleWhere((element) =>
                                  element.id == _user.currentUser!.uid)[
                          "contactPerson.contactNumber"];
                      if (nameContactPerson != null &&
                          numberContactPerson != null) {
                        setPolyline();
                        setState(() {
                          isPanicShow = true;
                          isSetAlarm = true;
                          isArriveBtnOn = true;
                          isStartBtnOn = false;
                          isOutPutCreated = true;
                          isFindBtnOn = false;
                        });

                        devtools.log(
                            "nameContactPerson is ${EncryptAndDecryptService.decryptFernet(nameContactPerson.toString())}");
                        devtools.log(
                            "numberContactPerson is ${EncryptAndDecryptService.decryptFernet(numberContactPerson.toString())}");

                        _listenLocation();
                      } else {
                        Navigator.pushNamed(context, addCOntactPersonRoute);
                      }
                    }
                  : null,
            ),
          );
        });

    //------------------------------Arrived BTN ---------------------
    final arrivedtBTN = Opacity(
      opacity: isArriveBtnOn! ? 1.0 : .3,
      child: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: Colors.yellowAccent,
        label: Text(
          'ARRIVED',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        onPressed: isArriveBtnOn!
            ? () {
                // TODO quick alert after mag arrived
                setState(() {
                  QuickAlert.show(
                    title: "Safely Arrived",
                    context: context,
                    onConfirmBtnTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    type: QuickAlertType.success,
                    text:
                        "\"SafAware\" is your partner, We care about your safety.",
                  );
                  isPanicShow = false;
                  isSetAlarm = false;
                  isArriveBtnOn = false;
                  isStartBtnOn = true;
                  isFindBtnOn = true;
                  isOutPutCreated = false;
                });
                controllerCountDownt.stop();
                controllerCountDownt.reset();
                devtools.log("isArriveBtnOn is $isArriveBtnOn");

                _stopListening();
                setState(() {
                  isBTNTouch = false;
                });

                devtools.log("_locationSubscription is $_locationSubscription");
                devtools.log("isBTNTouch is $isBTNTouch");
              }
            : null,
      ),
    );

//------------------------------Set Alarm ---------------------

    final setAlarm = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButton(
        borderRadius: BorderRadius.circular(25),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
        value: dropDownAlarm,
        onChanged: (String? newValue) {
          if (newValue != "Set Alarm") {
            // TODO changed seconds to minute after testing
            setState(() {
              dropDownAlarm = newValue;
              controllerCountDownt.duration =
                  Duration(minutes: int.parse(dropDownAlarm!));
            });
          } else {
            setState(() {
              dropDownAlarm = newValue;
            });
          }
        },
        items: <String>[
          "Set Alarm",
          '2',
          '3',
          '5',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: value == "Set Alarm"
                ? Text(
                    value,
                    style: TextStyle(color: Colors.red),
                  )
                : Text("$value minutes"),
          );
        }).toList(),
      ),
    );
    //-----------------------------------Scaffold--------------
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          _choseLeftRange(currentWith: currentWith), 10, 0, 0),
                      child: threeDOtsButton,
                    ),
                    destinaitonLoc,
                    typeOfVehicle,
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: auth
                      .collection("users")
                      .where("uid", isEqualTo: _user.currentUser!.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (isOutPutCreated!) {
                      listenLocation(snapshot);
                      _getLocation();
                    }
                    if (snapshot.hasData) {
                      return GoogleMap(
                        polylines: polylines,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        markers: {
                          Marker(
                              markerId: MarkerId("current_marker_id"),
                              infoWindow: InfoWindow(title: "I'm Here"),
                              icon: BitmapDescriptor.defaultMarker,
                              position: currentCoordinates!),
                          Marker(
                              markerId: MarkerId("destination_marker_id"),
                              infoWindow: InfoWindow(title: destinationMarker!),
                              icon: BitmapDescriptor.defaultMarker,
                              position: destinationCoordinates!),
                        },
                        initialCameraPosition:
                            CameraPosition(zoom: 8, target: latlang!),
                        onMapCreated: (GoogleMapController controller) {
                          setState(() {
                            _controller = controller;
                          });
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
          ],
        ),
//  FIND LOCATION ------------------------------
        floatingActionButton: StreamBuilder(
            stream: auth
                .collection("users")
                .where("uid", isEqualTo: _user.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              return Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Draggable(
                      childWhenDragging: Container(),
                      feedback: panic,
                      child: panic,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 250),
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadiusDirectional.circular(25),
                                color: isSetAlarm!
                                    ? Colors.red[400]
                                    : Colors.white,
                              ),
                              child: AnimatedCrossFade(
                                firstChild: setAlarm,
                                secondChild: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  child: AnimatedBuilder(
                                    animation: controllerCountDownt,
                                    builder: (context, child) => Text(
                                      countText,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                crossFadeState: isSetAlarm!
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: Duration(milliseconds: 200),
                              ))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Opacity(
                          opacity: isFindBtnOn! ? 1 : 0.3,
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black, //<-- SEE HERE
                            onPressed: isFindBtnOn!
                                ? () async {
                                    _locationSubscription?.cancel();
                                    setState(() {
                                      isBTNTouch = true;

                                      isArriveBtnOn = false;
                                      _locationSubscription = null;
                                    });

                                    if (isPermissionTrue! && isBTNTouch!) {
                                      devtools.log("All true");

                                      bool gotEnabled =
                                          await location.requestService();
                                      if (gotEnabled) {
                                        setState(() {
                                          gotEnabled = true;
                                        });

                                        _getLocation();
                                      }
                                    } else {
                                      _requestPermission();
                                    }
                                  }
                                : null,
                            child: IconButton(
                                icon: Icon(
                                  Icons.location_searching_rounded,
                                  color: Colors.red,
                                  size: 30,
                                  fill: .5,
                                ),
                                onPressed: null),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(child: startBTN),
                          Container(child: arrivedtBTN),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              //  evstool.log("${snapshot.data!.docs[3]['subjectName']}");
            }),
      ),
    );
  }

  void setPolyline() async {
    PolylineResult result = await polyLinePoints!.getRouteBetweenCoordinates(
      googleAPI,
      PointLatLng(currentCoordinates!.latitude, currentCoordinates!.longitude),
      PointLatLng(
          destinationCoordinates!.latitude, destinationCoordinates!.longitude),
    );
    if (result.status == "OK") {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        polylines.clear();
        polylines.add(
          Polyline(
            width: 5,
            polylineId: PolylineId("polyline"),
            color: Colors.blue,
            points: polylineCoordinates,
          ),
        );
      });
    }
    devtools
        .log("MY CURRENT LOCATION LATITUDE ${currentCoordinates!.latitude}");
    devtools
        .log("MY CURRENT LOCATION LONGITUDE ${currentCoordinates!.longitude}");

    devtools.log(
        "MY DESTINATION LOCATION LATITUDE ${destinationCoordinates!.latitude}");
    devtools.log(
        "MY DESTINATION LOCATION LONGITUDE ${destinationCoordinates!.longitude}");
  }

  Widget paddingWidget({required Widget data, required}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: data,
    );
  }

  double _choseLeftRange({required double currentWith}) {
    return currentWith - 30;
  }

  _getLocation() async {
    User? user = _auth.currentUser;

    try {
      final loc.LocationData locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "longitude": locationResult.longitude,
        "latitude": locationResult.latitude,
      }, SetOptions(merge: true));
      devtools.log("Done insert");
      changingCameraPossition(
          latitude: locationResult.latitude!,
          longitude: locationResult.longitude!);
    } catch (e) {
      devtools.log(e.toString());
    }
  }

  Future<void> _listenLocation() async {
    User? user = _auth.currentUser;

    _locationSubscription = location.onLocationChanged.handleError((onError) {
      devtools.log("Error Occured");
      devtools.log(onError.toString());
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentLocation) async {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "longitude": currentLocation.longitude,
        "latitude": currentLocation.latitude,
      }, SetOptions(merge: true));
      devtools.log("I'm Listening");
      checkIfSafe();
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();

    setState(() {
      _locationSubscription = null;
    });
    devtools.log("I'm Stop Listening");
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      devtools.log("status Grandted");
      setState(() {
        isPermissionTrue = true;
        isBTNTouch = false;
      });
    } else if (status.isPermanentlyDenied) {
      devtools.log("status isPermanentlyDenied");

      openAppSettings();
    }
  }

  Future<void> changingCameraPossition(
      {required double latitude, required double longitude}) async {
    setState(() {
      currentCoordinates = LatLng(latitude, longitude);
    });
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              latitude,
              longitude,
            ),
            zoom: 15)));
  }

  Future<void> changingCameraPossitionDestination(
      {required double latitude, required double longitude}) async {
    setState(() {
      destinationCoordinates = LatLng(latitude, longitude);
    });
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              latitude,
              longitude,
            ),
            zoom: 15)));
  }

  Future<void> listenLocation(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere((element) =>
                  element.id == _user.currentUser!.uid)["latitude"],
              snapshot.data!.docs.singleWhere((element) =>
                  element.id == _user.currentUser!.uid)["longitude"],
            ),
            bearing: 200.8334901395799,
            tilt: 60.440717697143555,
            zoom: 15.5)));
  }

  double boxConstraintsMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double boxConstraintsMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  Future<void> _findDestination() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: googleAPI,
        onError: onError,
        mode: _mode,
        language: "en",
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
          hintText: "Search",
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        components: [
          Component(Component.country, "ph"),
        ]);

    displayPrediction(p!);
  }

  void onError(PlacesAutocompleteResponse response) {
    showErrorDialog(context, response.errorMessage!.toString());
  }

  Future<void> displayPrediction(Prediction p) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: googleAPI,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    changingCameraPossitionDestination(latitude: lat, longitude: lng);
    setState(() {
      destinationMarker = detail.result.name;
      isStartBtnOn = true;
    });
  }

  dynamic getInfo(AsyncSnapshot<QuerySnapshot> snapshot, String typeOfData) {
    final inputData = snapshot.data!.docs.singleWhere(
        (element) => element.id == _user.currentUser!.uid)[typeOfData];
    if (typeOfData == "gender") {
      return inputData;
    } else {
      final inputDataDecrypted =
          EncryptAndDecryptService.decryptFernet(inputData);
      devtools.log(inputDataDecrypted);
      return inputDataDecrypted;
    }
  }

  insertCaseReport(AsyncSnapshot<QuerySnapshot> snapshot) async {
    User? user = _auth.currentUser;
    final myName = getInfo(snapshot, "fullname");
    final myNumber = getInfo(snapshot, "myNumber");
    final contactPersonName = getInfo(snapshot, "contactPerson.Name");
    final contactPersonNumber =
        getInfo(snapshot, "contactPerson.contactNumber");
    final gender = getInfo(snapshot, "gender");
    final getTime = DateTime.now().toString().substring(0, 19);

    devtools.log('This is the Time: $getTime');
    devtools.log(getTime);

    caseUser.uid = user!.uid;
    caseUser.nameUser = myName;

    caseUser.time = getTime;

    await firebaseFirestore
        .collection("admin")
        .doc(user.uid)
        .set(caseUser.toMap());
  }

  String _getTime() {
    return "time";
  }
}
