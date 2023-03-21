import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/congifuration/style.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/enum_user.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/commuter_page/commuter_page.dart'
    show CommuterPage;
import 'package:accounts/routes/route_pages.dart';
import 'package:accounts/services/auth/auth_service.dart';
import 'package:distance/distance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:location/location.dart' as loc;
import 'dart:developer' as devtools show log;
import 'package:accounts/maps_utility/location_service.dart';
import 'package:accounts/utility/error_dialog.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_background/flutter_background.dart';

import '../user_service_type/user_type_enum.dart';

/*
   _________________________________
  |                                 |
  |       LocationServiceHome       |
  |_________________________________|
*/
class LocationServiceHome extends ChangeNotifier {
  // ********************* initialization *********************

  List<String> itemList = const ['200 meters', '500 meters', '1 kilometer'];

  String _itemDistance = "500 meters";
  String? _typeOfTime;
  bool kCountOn = false;
  int? kTimeSec, itemIntDistance;
  double? kDistanceInKM;

  // is Run in the background
  bool isSuccessRun = false;
  // Bool to ask permission
  bool isHasPermissionBack = false;
  //Config of running background
  FlutterBackgroundAndroidConfig? _androidConfig;
  bool isInit = false;

  Duration? _duration;
  int? _timeOfArrivalInit;
  late Timer _timer;
  final _auth = FirebaseAuth.instance;

  //get the time of arrival

  // to conver distance km to meter
  String timeOfArrivalDisplay = "waiting";
  Distance? _distance;

  //List: for type of unit
  final List<TypeOfUnitEnum> itemsUnit = [TypeOfUnitEnum.km, TypeOfUnitEnum.m];

  // set distance : pag na reach ako set na distance saka lang aalarm

  double? distanceInputValue, kDistanceInKm;

  int? timeOfArrival, initTimeOfArrival;

  // display: distance in UI
  String showDistance = "";

  // enum for type of user
  UserTypeEnum? userType;

  PolylinePoints polyLinePoints = PolylinePoints();
  // Storage : List of polylines points
  List<LatLng> polylineCoordinates = [];

  //Set Of Polylines
  final Set<Polyline> polylines = <Polyline>{};
  String markerName = "";

  LatLng _markerCurrentPos = const LatLng(0, 0);

  // stream : value ng stream parameter sa StreamBuilder
  final StreamController<List<LatLng>> latLngStreamController =
      StreamController<List<LatLng>>();

  // subscribe : para maka kuha mga data ng location e.g. lat and lng
  StreamSubscription<loc.LocationData>? locationSubscription;

  final List<LatLng> _currentPos = <LatLng>[const LatLng(9.7489, 118.7486)];

  final Mode _mode = Mode.overlay;
  bool isReported = false;
  GoogleMapController? _controllerMap;
  final BuildContext _context;
  LocationServiceHome? _consumer;

  LatLng destinationPos = const LatLng(0, 0);
  LatLng currentForPoly = const LatLng(0, 0);

  bool isLocationOpen = false, isGetAllSetIcon = false, isShowDistance = false;
  bool isFirstTimeOpen = true, isRequestPermissionLoc = false;
  bool isDrawPoly = false,
      isAlarmON = false,
      iskTOA = false,
      isActivateStartBTN = false,
      isActivateArrivedBTN = false;

  //Location Class : para makuha yung instace ng location
  final loc.Location location = loc.Location();

  LocationServiceHome(this._context);

  //********************* getter : pang expose sa UI *********************
  double get getkDistanceInKM => kDistanceInKM!;
  int get getItemIntDistance => itemIntDistance!;
  List<String> get getListItem => itemList;
  String get getItemDistance => _itemDistance;

  String? get getTypeOfTime => _typeOfTime;

  bool get getCountOn => kCountOn;

  int? get getTimeSec => kTimeSec;
  String get getShowDistance => showDistance;
  bool? get getIsSuccesRun => isSuccessRun;

  bool get getIshasPermissionBack => isHasPermissionBack;

  bool get getIsInit => isInit;
  FlutterBackgroundAndroidConfig get getAndroidConfig => _androidConfig!;

  int? get getInitTimeOfArrivalCount => _timeOfArrivalInit;
  bool get getisReported => isReported;
  bool get getisActivateArrivedBTN => isActivateArrivedBTN;

  bool get getisActivateStartBTN => isActivateStartBTN;
  bool get getIskTOA => iskTOA;
  int get getInitTimeOfrrival => initTimeOfArrival!;

  String get getTimeOfArrivalDisplay => timeOfArrivalDisplay;

  int get getTimeOfArrival => timeOfArrival!;

  bool get getAlarmON => isAlarmON;

  Distance get getDistance => _distance!;

  double? get getDisInputKm => distanceInputValue;
  UserTypeEnum? get getUserType => userType;

  UserTypeEnum? get getTypeOfUser => userType;

  double? get getkDistanceInKm => kDistanceInKm;
  bool get getIsDrawPoly => isDrawPoly;
  Set<Polyline> get getPolylines => polylines;
  LatLng get getCurrentForPoly => currentForPoly;
  String get getMarkerName => markerName;
  LatLng get getMarkerPosCurrent => _markerCurrentPos;
  List<LatLng> get getCurrentPosList => _currentPos;
  StreamController<List<LatLng>>? get getLatLngStreamBuilder =>
      latLngStreamController;
  GoogleMapController? get getMapController => _controllerMap;
  BuildContext get getContext => _context;
  LocationServiceHome get getConsumerInstace => _consumer!;

  LatLng get getDesPosition => destinationPos;
  bool get getLocationResult => isLocationOpen;
  bool get getShowDisTance => isShowDistance;

  bool get getRequestPermissionLoc => isRequestPermissionLoc;
  bool get getIsFirstTimeOpen => isFirstTimeOpen;

  // ********************* setter : pang set value *********************

  String getOnlyString(String duration) {
    _typeOfTime = duration.split(' ')[1];

    return _typeOfTime!;
  }

  int getNumberOnly(duration) {
    timeOfArrival =
        int.parse(duration.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    return timeOfArrival!;
  }

  setItemDistance(String itemDistance) {
    int intDistance =
        int.parse(itemDistance.toString().replaceAll(RegExp(r'[^0-9]'), ''));
    String stringDistance = itemDistance.split(' ')[1];

    switch (stringDistance) {
      case "meters":
        itemIntDistance = intDistance;
        break;
      case "kilometer":
        itemIntDistance = intDistance * 1000;
        break;
    }

    _itemDistance = itemDistance;
  }

  setTimeSec({required int time, required String typeOfTime}) {
    switch (typeOfTime) {
      case "mins":
        kTimeSec = time * 60;
        break;
      case "hours":
        kTimeSec = time * 60 * 60;
        break;
    }
    notifyListeners();
  }

  setCountOn(bool stateCount) {
    kCountOn = stateCount;
    notifyListeners();
  }

  setShowDistace(String newDistance) {
    showDistance = newDistance;
    notifyListeners();
  }

  setIsSuccesRun() async {
    isSuccessRun = await FlutterBackground.enableBackgroundExecution();
    notifyListeners();
  }

  setIsHasPermission() async {
    isHasPermissionBack = await FlutterBackground.hasPermissions;
    notifyListeners();
  }

  // TODO: DI PA NA CALL
  setIsInit() async {
    isInit =
        await FlutterBackground.initialize(androidConfig: getAndroidConfig);
    notifyListeners();
  }

  // TODO: DI PA NA CALL
  setConfig() {
    _androidConfig = const FlutterBackgroundAndroidConfig(
      notificationTitle: "flutter_background example app",
      notificationText:
          "Background notification for keeping the example app running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    notifyListeners();
  }

  setIsReported(bool isReportedVal) {
    isReported = isReportedVal;
  }

  setIsActivateStartBTN(bool isActivateButtonsVal) {
    isActivateStartBTN = isActivateButtonsVal;
  }

  setIsActivateArrivedBTN(bool value) {
    isActivateArrivedBTN = value;
  }

  setIskTOA(bool setIskTOAval) {
    iskTOA = setIskTOAval;
    notifyListeners();
  }

  setInitTimeOfArrival(int setinitTimeOfArrival) {
    initTimeOfArrival = setinitTimeOfArrival;
    notifyListeners();
  }

  setAlarmOn(bool value) {
    isAlarmON = value;
    notifyListeners();
  }

  setTimeOfArrivalDisplay(String kDisplayTimeOfArrival) {
    timeOfArrivalDisplay = kDisplayTimeOfArrival;
    notifyListeners();
  }

  setTypeOfUser(UserTypeEnum type) {
    userType = type;
  }

  // calculateDistance(
  //     {required lat1, required lon1, required lat2, required lon2}) {
  //   var p = 0.017453292519943295;
  //   var a = 0.5 -
  //       cos((lat2 - lat1) * p) / 2 +
  //       cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  //   kDistanceInKm = 12742 * asin(sqrt(a));
  //   _distance = Distance(kilometers: getkDistanceInKm!.toInt());
  // }

  setIsDrawPoly(bool value) {
    isDrawPoly = value;
    notifyListeners();
  }

  setcurrentForPoly(LatLng setCurrentPoly) {
    currentForPoly = setCurrentPoly;
  }

  // para sa unang view lang
  setIsFirstTime(bool value) {
    isFirstTimeOpen = value;
    notifyListeners();
  }

  setMarkerName(String setNameMarker) {
    markerName = setNameMarker;
    notifyListeners();
  }

  setStreamController() {
    latLngStreamController.sink.add(getCurrentPosList);
  }

  setMarkerCurrntPos(LatLng setMarkerCurrent) {
    _markerCurrentPos = setMarkerCurrent;
    notifyListeners();
  }

  addLatLngListToStream(List<LatLng> listOfLatLng) {
    latLngStreamController.sink.add(listOfLatLng);
    notifyListeners();
  }

  setMapController(GoogleMapController setMapController) {
    _controllerMap = setMapController;
    notifyListeners();
  }

  setDesPosition(setPositionDes) {
    destinationPos = setPositionDes;
    notifyListeners();
  }

  setShowDistance(value) {
    isShowDistance = value;
    notifyListeners();
  }

  setPermissionLoc(value) {
    isRequestPermissionLoc = value;
    notifyListeners();
  }

  setOnLocation(value) {
    isLocationOpen = value;
    notifyListeners();
  }

  // *********************Pang update ng UI *********************

  // print the time of arrival
  double getOnlyNumber(data) {
    var durationString = data;
    var durationRegExp = RegExp(r'\d+');
    var durationMatch = durationRegExp.firstMatch(durationString);
    if (durationMatch != null) {
      double durationNumber = double.parse(durationMatch.group(0)!);
      notifyListeners();

      return durationNumber;
    }
    return 0;
  }

  getDistanceMatrix() async {
    try {
      var response = await Dio().get(
          'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${getDesPosition.latitude},${getDesPosition.longitude}&origins=${getCurrentPosList[0].latitude},${getCurrentPosList[0].longitude}&key=$googleAPI');

      if (response.data['status'] == 'OK') {
        var duration =
            response.data['rows'][0]['elements'][0]['duration']['text'];
        var distance =
            response.data['rows'][0]['elements'][0]['distance']['text'];
        devtools.log("$distance this is distance");

        // kDistanceInKM =
        //     double.parse(distance.toString().replaceAll("[^\\d.]+", ""));

        double value = double.parse(distance.split(" ")[0]);

        devtools.log("$value new here after the");

        // to get the value of the duration and  distance
        //getOnlyNumber(duration);

        setTimeSec(
            time: getNumberOnly(duration), typeOfTime: getOnlyString(duration));
        setCountOn(true);

        // String kTypeOfTime =
        kDistanceInKm = getOnlyNumber(distance);
        setShowDistace(distance);

        devtools.log(distance);

        devtools.log("$duration here");
        devtools.log(timeOfArrival.toString());

        if (!getIskTOA) {
          setInitTOA(timeOfArrival);

          devtools.log("The value of getIskTOA  : $getIskTOA before");
          setInitTimeOfArrival(timeOfArrival!);
          start();

          setIskTOA(true);
          devtools.log("The value of getIskTOA  : $getIskTOA after");
        }
        // start();

        // this is just to display the arrival time in the ui
        setTimeOfArrivalDisplay(duration);

        notifyListeners();
        // do something with the duration
      } else {
        return const Text(
            "Sorry unable to get the direction in the sea direction");
      }
    } catch (e) {
      return Text("Error: ${e.toString()}");
    }
  }

  alarmTrigger() {}

  compareDistance() {
    devtools.log(
        " The current distance is : $_distance and the expected distance is $getDisInputKm  other: $getkDistanceInKm");
  }

  setDistanceInput(String setDistanceVal) {
    distanceInputValue = double.parse(setDistanceVal) / 1000;

    notifyListeners();
  }

  // methos for getting the set distance from arrival
  ditanceFromArrival(TextEditingController controllerDes) {
    final loadingDes = QuickAlert.show(
        onConfirmBtnTap: () {
          if (controllerDes.text.isEmpty) {
            return;
          } else {
            setDistanceInput(controllerDes.text);
            controllerDes.text = "";
            Navigator.of(getContext, rootNavigator: true).pop();
          }
        },
        animType: QuickAlertAnimType.slideInUp,
        context: getContext,
        type: QuickAlertType.info,
        title: "",
        widget: Column(
          children: [
            Text(
              "How far from your destination do you want the alarm to start? ",
              textAlign: TextAlign.center,
              style:
                  kPoppinsSemiBold.copyWith(fontSize: SizeConfig.blockX! * 5),
            ),
            SizedBox(height: SizeConfig.blockY! * 3),
            SizedBox(
              height: SizeConfig.blockY! * 6,
              child: TextField(
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  controllerDes.text = value;
                },
                controller: controllerDes,
                decoration: InputDecoration(
                  suffix: Text(
                    "meters",
                    style: kPoppinsMediumBold.copyWith(
                        fontSize: SizeConfig.blockX! * 4),
                  ),
                  fillColor: kWhite,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: kBlue),
                    borderRadius: BorderRadius.circular(
                      kBorderRadius,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));

    loadingDes.whenComplete(() {});
  }

  //Para ma open yung location ng app
  requestLocPermissionReq() async {
    final dataLocation = await location.requestService();
    devtools.log("requestService : $dataLocation");
    setOnLocation(dataLocation);
  }

  requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      devtools.log("isGranted : ${status.isGranted}");
      setPermissionLoc(status.isGranted);
    } else if (status.isPermanentlyDenied) {
      devtools.log("isGranted ${status.isPermanentlyDenied}");

      openAppSettings();
    }
  }

  Future<void> findDestination() async {
    cancelStream();
    Prediction? p = await PlacesAutocomplete.show(
        context: getContext,
        apiKey: googleAPI,
        onError: onError,
        mode: _mode,
        language: "en",
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
          hintText: "Search Destination",
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        components: [
          Component(Component.country, "ph"),
        ]);
    if (p != null) {
      locationSubscription?.cancel();
      setIsFirstTime(false);
      setShowDistance(false);
      displayPrediction(p);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    showErrorDialog(getContext, response.errorMessage!.toString());
  }

  Future<void> displayPrediction(Prediction p) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: googleAPI,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    final position = LatLng(lat, lng);
    setMarkerName(detail.result.name);
    setDesPosition(position);
    changingCameraPossitionDestination(latitude: lat, longitude: lng);

    // setState(() {
    //   destinationMarker = detail.result.name;
    // });
  }

  Future<void> changingCameraPossitionDestination(
      {required double latitude, required double longitude}) async {
    // TODO: SET STATE
    // setState(() {
    //   destinationCoordinates = LatLng(latitude, longitude);
    // });
    await getMapController!
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              latitude,
              longitude,
            ),
            zoom: 15)));
  }

  getLatLngStream() async {
    User? user = _auth.currentUser;
    devtools.log("Get Lat Lang Stream dito ba");
    //  LocationData : Para makuha data ng location
    await location.getLocation();

    // subscribe: pang subscribe sa real time changes ng location
    locationSubscription = location.onLocationChanged.listen(
      (loc.LocationData updatedLoc) {
        _currentPos.clear();
        _currentPos.add(
          LatLng(
            updatedLoc.latitude!.toDouble(),
            updatedLoc.longitude!.toDouble(),
          ),
        );
        devtools.log(" the value of getisReported is : $getisReported");
        if (getisReported) {
          devtools.log("LAT AND LANG  OKAY");
          listeningLatLng(updatedLoc, user);
        }

        //_latLngStreamController add :  add ng list ng LatLng para sa stream parameter sa StreamBuilder
        addLatLngListToStream(_currentPos);
        updateCameraPosition(_currentPos);
        notifyListeners();
      },
    );

    // _print();
    return _currentPos;
  }

  listeningLatLng(loc.LocationData updatedLoc, user) async {
    await FirebaseFirestore.instance.collection("admin").doc(user!.uid).set({
      "longitude": updatedLoc.longitude,
      "latitude": updatedLoc.latitude,
    }, SetOptions(merge: true));
  }

  startTravel() async {
    setConfig();
    setIsInit();
    devtools.log(
        "getIsInit $getIsInit  getIshasPermissionBack $getIshasPermissionBack");

    if (getIsInit && getIshasPermissionBack) {
      setIsSuccesRun();
      devtools.log("The value of getIsSuccesRun is : $getIsSuccesRun");
    } else {
      setIsHasPermission();
    }

    QuickAlert.show(
        title: "",
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Safely Reminder",
                textAlign: TextAlign.center,
                style: kPoppinsBold.copyWith(fontSize: SizeConfig.blockX! * 6)),
            SizedBox(
              height: SizeConfig.blockY! * 3,
            ),
            Text(
              "Keep your cellphone on and keep it within your possession for safety purposes",
              style:
                  kPoppinsSemiBold.copyWith(fontSize: SizeConfig.blockX! * 5),
              textAlign: TextAlign.center,
            )
          ],
        ),
        context: getContext,
        type: QuickAlertType.warning);
    setIsActivateArrivedBTN(true);
    setIsActivateStartBTN(false);
    devtools.log("Start Travel");
    //  LocationData : Para makuha data ng location
    await location.getLocation();

    // subscribe: pang subscribe sa real time changes ng location
    locationSubscription = location.onLocationChanged.listen(
      (loc.LocationData updatedLoc) {
        devtools.log("Inside : startTravel ");

        _currentPos.clear();
        _currentPos.add(
          LatLng(
            updatedLoc.latitude!.toDouble(),
            updatedLoc.longitude!.toDouble(),
          ),
        );

        getDistanceMatrix(); // TODO: HERE
        // calculateDistance(
        //     lat1: getCurrentPosList[0].latitude,
        //     lon1: getCurrentPosList[0].longitude,
        //     lat2: getDesPosition.latitude,
        //     lon2: getDesPosition.longitude);
        setcurrentForPoly(getCurrentPosList[0]);
        drawPolyline();
        addLatLngListToStream(getCurrentPosList);
        updateCameraPositionTravel(getCurrentPosList);

        setShowDistance(true);

        if (getDisInputKm != null &&
            getkDistanceInKm != null &&
            initTimeOfArrival != null &&
            timeOfArrival != null) {
          // TODO : CONDITIONS THAT TRIGGERS THE ALARM
          if (getDisInputKm! > getkDistanceInKm! &&
              initTimeOfArrival! < timeOfArrival!) {
            setAlarmOn(true); // to activate the alarm
          }
        }

        notifyListeners();
      },
    );

    // _print();
    return _currentPos;
  }

  arrivedCallBack() {
    setIsActivateArrivedBTN(false);
    setIsActivateStartBTN(false);
    showRerscuerDialog(
        getContext, "You've Safely arrived to your destination", "Great!!!");
    cancelStream();
  }

  cancelStream() {
    locationSubscription?.cancel();
    setIsFirstTime(false);
    setShowDistance(false);

    devtools.log("Cancelled successfully");
    // notifyListeners();
  }

  closeStream() {
    latLngStreamController.close();
    devtools.log("close successfully");
    notifyListeners();
  }

  updateCameraPosition(List<LatLng> newPosition) async {
    devtools.log("DONE UPDATE.............updateCameraPosition");
    getMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 15, target: newPosition[0]),
      ),
    );
  }

  updateCameraPositionTravel(List<LatLng> newPosition) async {
    devtools.log("Code is in updateCameraPositionTravel method");
    getMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(tilt: 30, bearing: 12, zoom: 20, target: newPosition[0]),
      ),
    );
  }

  drawPolyline() async {
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
      googleAPI,
      PointLatLng(getCurrentForPoly.latitude, getCurrentForPoly.longitude),
      PointLatLng(getDesPosition.latitude, getDesPosition.longitude),
    );
    if (result.status == "OK") {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      polylines.clear();
      polylines.add(
        Polyline(
          width: 5,
          polylineId: const PolylineId("polyline"),
          color: Colors.blue,
          points: polylineCoordinates,
        ),
      );

      notifyListeners();
    }
  }

  start() {
    _duration = Duration(
        minutes:
            getInitTimeOfArrivalCount!); // Alarm Initial travel time not done
    devtools.log("code is here");
    _timer = Timer.periodic(_duration!, (timer) {
      _duration = _duration! - const Duration(seconds: 1);
      devtools.log("COUNT DOWN : ${_duration!.inSeconds}");
      if (_duration!.inSeconds == 0) {
        cancel();
        devtools.log("done counting");
        setAlarmOn(true);
      }
    });
  }

  cancel() {
    _timer.cancel();
  }

  setInitTOA(value) {
    _timeOfArrivalInit = value;
    notifyListeners();
  }
}

/*
   _________________________________
  |                                 |
  |     NavigatorLoadingService     |
  |_________________________________|
  
*/

class NavigatorLoadingService {
  BuildContext context;

  NavigatorLoadingService({required this.context});

  home() {
    Navigator.pop(context);
    return const CommuterPage();
  }

  logout() {
    QuickAlert.show(
        onConfirmBtnTap: _logout,
        confirmBtnTextStyle: kPoppinsMediumBold.copyWith(
          color: kWhite,
          fontSize: 20,
        ),
        cancelBtnTextStyle: kPoppinsMediumBold.copyWith(
          fontSize: 20,
        ),
        confirmBtnText: "Yes",
        cancelBtnText: "No",
        showCancelBtn: true,
        title: "",
        widget: Text(
          "Are you sure you want to logout?",
          style: kPoppinsSemiBold.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        context: context,
        type: QuickAlertType.warning);
  }

  about() {
    Navigator.of(context).pushNamed(contactPageRoute);
  }

  _logout() async {
    await AuthService.firebase().logout();
    loading();
    quicAlertPop();

    navGotoLoginPage();
  }

  loading() async => await Future.delayed(const Duration(seconds: 2));

  quicAlertPop() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  navGotoLoginPage() async {
    loading();
    Navigator.pushNamedAndRemoveUntil(
        context, loginPageRoute, (route) => false);
  }

  chooseUser() {
    loading();
    Navigator.of(context).pushNamed(chooseUserPageRoute);
  }
}

class CountDownTimer extends StatefulWidget {
  final bool onAlarm;
  final int kTime;
  final VoidCallback onFinished;
  const CountDownTimer({
    super.key,
    required this.kTime,
    required this.onFinished,
    required this.onAlarm,
  });

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  bool isAlarm = false;
  late Timer _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.kTime;
    // isAlarm = widget.onAlarm;

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft < 1) {
          _timer.cancel();
          widget.onFinished();
        } else {
          _timeLeft--;
        }
      });
    });
  }

  String get timerDisplay {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(timerDisplay);
  }
}

class DropDownTriggersAlarm extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final void Function(String?)? onChanged;

  const DropDownTriggersAlarm({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedItem,
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
