import 'dart:async';
import 'package:accounts/congifuration/configuration.dart';
import 'package:accounts/congifuration/style.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/commuter_page/services_report_commuter.dart';
import 'package:accounts/pages_thesis_app/mobile/chooseUser/user_service_type/user_type_enum.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:developer' as devtools show log;
import '../../../../sound_image_code/sound_images_code.dart';
import '../../../../utility/error_dialog.dart';
import 'navigationa_drawer/navigation_drawer.dart';
import 'services_homepage.dart'
    show CountDownTimer, DropDownButton, LocationServiceHome;

class CommuterPage extends StatefulWidget {
  const CommuterPage({super.key});

  @override
  State<CommuterPage> createState() => _CommuterPageState();
}

class _CommuterPageState extends State<CommuterPage> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();

  late final TextEditingController _controllerInputDes;

  //GoogleMapController : pang control ng MAPA
  GoogleMapController? _controller;
  // List : para sa latitude at longitude
  List<LatLng> latLngList = <LatLng>[];

  // stream : value ng stream parameter sa StreamBuilder
  final StreamController<List<LatLng>> _latLngStreamController =
      StreamController<List<LatLng>>();

  // Loacation : Para makuha location

  // subscribe : para maka kuha mga data ng location e.g. lat and lng
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    // _getLatLngStream();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_one, _two, _three, _four]));
    latLngList = [const LatLng(9.7489, 118.7486)];
    _controllerInputDes = TextEditingController();
    _latLngStreamController.sink.add(latLngList);
  }

  @override
  void dispose() {
    super.dispose();
    _controllerInputDes.dispose();
    _locationSubscription?.cancel();
    _latLngStreamController.close();
    LocationServiceHome(context).locationSubscription?.cancel();
    LocationServiceHome(context).latLngStreamController.close();
    LocationServiceHome(context).getMapController?.dispose();
    LocationServiceHome(context).getLatLngStreamBuilder!.close();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Home",
            style: kPoppinsBold.copyWith(
              fontSize: SizeConfig.blockX! * 5.944,
            ),
          ),
        ),
        drawer: const NavigationDrawerPage(),
        body: Consumer2<LocationServiceHome, ReportCommuterServices>(
          builder: (context, servicesCommuter, servicesReport, __) {
            if (servicesCommuter.getCurrentPosList.isNotEmpty &&
                servicesCommuter.getDisInputKm != null) {
              servicesCommuter.setIsActivateStartBTN(true);
            }
            servicesReport.reportStream();
            // to marke is screen as commuter
            servicesCommuter.setTypeOfUser(UserTypeEnum.commuter);

            if (servicesCommuter.getIsFirstTimeOpen) {
              servicesCommuter.setStreamController();
            }
            return StreamBuilder<List<LatLng>>(
              stream: servicesCommuter.getLatLngStreamBuilder!.stream,
              builder:
                  (BuildContext context, AsyncSnapshot<List<LatLng>> snapshot) {
                if (servicesCommuter.getAlarmON) {
                  servicesCommuter.locationSubscription!.cancel();
                }
                if (snapshot.hasData) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());

                    case ConnectionState.active:
                      final List<LatLng> points = snapshot.data!;

                      // updateCameraPosition: dito nag u update ng camera position

                      return Stack(
                        children: <Widget>[
                          GoogleMap(
                            polylines: servicesCommuter.getPolylines,
                            zoomControlsEnabled: false,
                            markers: {
                              Marker(
                                infoWindow: const InfoWindow(title: "Me"),
                                icon: BitmapDescriptor.defaultMarker,
                                markerId: const MarkerId("user_markerID"),
                                position: points[0],
                              ),
                              Marker(
                                infoWindow: InfoWindow(
                                    title: servicesCommuter.getMarkerName),
                                icon: BitmapDescriptor.defaultMarker,
                                markerId:
                                    const MarkerId("destination_markerID"),
                                position: servicesCommuter.getDesPosition,
                              )
                            },
                            initialCameraPosition: const CameraPosition(
                              zoom: 10,
                              target: LatLng(9.7489, 118.7486),
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              servicesCommuter.setMapController(controller);
                            },
                          ),
                          // TODO : SET DISTANCE THAT TRIGGERS THE ALARM
                          Positioned(
                            top: SizeConfig.blockY! * 35.75,
                            left: SizeConfig.blockX! * 74.75,
                            child: GestureDetector(
                              onTap: () {
                                // servicesCommuter.cancelStream(); TODO mush have this line

                                // servicesCommuter
                                //     .ditanceFromArrival(_controllerInputDes);
                                QuickAlert.show(
                                  onConfirmBtnTap: () {
                                    devtools.log(
                                        "${servicesCommuter.getItemIntDistance} here is the code ");
                                    servicesCommuter
                                        .setIsActivateStartBTN(true);
                                    devtools.log(servicesCommuter
                                        .getItemDistance
                                        .toString());

                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.loading,
                                        autoCloseDuration:
                                            const Duration(seconds: 3));
                                  },
                                  title: "",
                                  context: context,
                                  type: QuickAlertType.info,
                                  widget: Column(
                                    children: [
                                      Text(
                                          "How far from your destination would you like the alarm to start?",
                                          textAlign: TextAlign.center,
                                          style: kPoppinsSemiBold.copyWith(
                                              fontSize: 20)),
                                      DropDownButton(
                                        onChanged: (itemDistance) {
                                          servicesCommuter
                                              .setItemDistance(itemDistance!);
                                        },
                                        selectedItem:
                                            servicesCommuter.getItemDistance,
                                        items: servicesCommuter.getListItem,
                                      )
                                    ],
                                  ),
                                );
                              },
                              child: Showcase(
                                  key: _three,
                                  description:
                                      "Set distance that triggers the alarm",
                                  child: const WidgetIcon(icon: setDesIcon)),
                            ),
                          ),

                          // TODO : DISPLAY DURATION
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: SizeConfig.blockY! * 5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockX! * 5,
                                  vertical: SizeConfig.blockX! * 1),
                              decoration: servicesCommuter.getShowDisTance
                                  ? BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 10,
                                            color:
                                                kDarkBlueLight.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            spreadRadius: 0,
                                            blurStyle: BlurStyle.outer),
                                      ],
                                      color: kWhite,
                                      borderRadius:
                                          BorderRadius.circular(kBorderRadius),
                                    )
                                  : null,
                              child: servicesCommuter.getShowDisTance
                                  ? Text(
                                      servicesCommuter
                                                  .getTimeOfArrivalDisplay ==
                                              "waiting"
                                          ? "waiting"
                                          : "Time Of Arrival : ${servicesCommuter.getTimeOfArrivalDisplay}",
                                      textAlign: TextAlign.justify,
                                      style: kPoppinsSemiBold.copyWith(
                                          color: kDarkBlueLight),
                                    )
                                  : null,
                            ),
                          ),
                          // TODO: Count Down
                          Visibility(
                            visible: false, // TODO  TURN IT INTO FALSE
                            child: servicesCommuter.getCountOn &&
                                    servicesCommuter.getTimeSec != null
                                ? CountDownTimer(
                                    onAlarm: servicesCommuter.getAlarmON,
                                    kTime: servicesCommuter.getTimeSec!,
                                    onFinished: () {
                                      Navigator.pushNamed(
                                          context, alarmScreenRoute);
                                    })
                                : const Text("00:00"),
                          ),

                          // TODO : DISPLAY DISTANCE
                          Positioned(
                            top: SizeConfig.blockY! * 25,
                            left: SizeConfig.blockX! * 69.75,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockX! * 5,
                                  vertical: SizeConfig.blockX! * 1),
                              decoration: servicesCommuter.getShowDisTance
                                  ? BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 10,
                                            color:
                                                kDarkBlueLight.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            spreadRadius: 0,
                                            blurStyle: BlurStyle.outer),
                                      ],
                                      color: kWhite,
                                      borderRadius:
                                          BorderRadius.circular(kBorderRadius),
                                    )
                                  : null,
                              child: servicesCommuter.getShowDisTance
                                  ? Text(
                                      servicesCommuter.getShowDistance,
                                      textAlign: TextAlign.justify,
                                      style: kPoppinsSemiBold.copyWith(
                                          color: kDarkBlueLight),
                                    )
                                  : null,
                            ),
                          ),

                          // TODO : PANIC BUTTON : This is Panic Button --Changed It if you want
                          StreamBuilder(
                            stream: servicesReport.getReportStream,
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              servicesReport.setSnapShot(snapshot);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (servicesCommuter.getAlarmON) {
                                  servicesCommuter.setAlarmOn(false);
                                  Navigator.of(context).pushNamed(
                                      alarmScreenRoute,
                                      arguments: servicesReport);
                                }
                              });

                              return Visibility(
                                visible: servicesCommuter.getShowDisTance
                                    ? true
                                    : false,
                                child: GestureDetector(
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: kBlueSnackBar,
                                      content: Text(
                                        "Double Tap",
                                        textAlign: TextAlign.center,
                                        style: kPoppinsSemiBold.copyWith(
                                            fontSize:
                                                SizeConfig.blockX! * 4.611),
                                      ),
                                    ),
                                  ),
                                  // TODO NEXT PROBLEM
                                  onDoubleTap: () {
                                    servicesReport.setHeadCount('1');
                                    servicesReport.setSelectedItem('undefined');
                                    servicesReport.setDescription("unknown");
                                    servicesReport.setScene("on the road");

                                    servicesReport.insertCaseReport();
                                    servicesCommuter.setIsReported(
                                        servicesReport.getisReported);
                                    showRerscuerDialog(
                                        context,
                                        "You've Reported An Incident To 911 Wait For The Rescue",
                                        "Report An Incident");
                                  },
                                  child: DraggableFab(
                                    initPosition: const Offset(7, 10),
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: SizeConfig.blockY! * 100),
                                      child: FloatingActionButton(
                                        backgroundColor: kRed,
                                        onPressed: () {},
                                        child: const Text("Panic"),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // TODO : FIND DESTINATION
                          Positioned(
                            top: SizeConfig.blockY! * 55.75,
                            left: SizeConfig.blockX! * 74.75,
                            child: GestureDetector(
                              onTap: servicesCommuter.findDestination,
                              child: Showcase(
                                  key: _one,
                                  description: "Find Your Destination",
                                  child: const WidgetIcon(icon: findDes)),
                            ),
                          ),

                          // TODO: FIND YOUR CURRENT LOCATION
                          Positioned(
                            top: SizeConfig.blockY! * 45.75,
                            left: SizeConfig.blockX! * 74.75,
                            child: AnimatedCrossFade(
                                firstChild: GestureDetector(
                                  onTap: servicesCommuter.getLatLngStream,
                                  child: const WidgetIcon(icon: locIcon),
                                ),
                                secondChild: GestureDetector(
                                  onTap: () {
                                    servicesCommuter.requestPermission();
                                    servicesCommuter.requestLocPermissionReq();
                                  },
                                  child: Showcase(
                                      key: _two,
                                      description: "Find Your Current Location",
                                      child: const WidgetIcon(icon: findLoc)),
                                ),
                                crossFadeState: servicesCommuter
                                            .getLocationResult &&
                                        servicesCommuter.getRequestPermissionLoc
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                duration: const Duration(seconds: 2)),
                          ),

                          // TODO: START AND ARRIVED
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Opacity(
                                      opacity:
                                          servicesCommuter.getisActivateStartBTN
                                              ? 1
                                              : .5,
                                      child: widgetBTN(
                                          onPress: servicesCommuter
                                                  .getisActivateStartBTN
                                              ? servicesCommuter.startTravel
                                              : null,
                                          kBackColor: kGreen,
                                          kTextColor: kBlack,
                                          title: " Start"),
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockY! * 3,
                                    ),
                                    Opacity(
                                      opacity: servicesCommuter
                                              .getisActivateArrivedBTN
                                          ? 1
                                          : .5,
                                      child: widgetBTN(
                                        onPress: servicesCommuter
                                                .getisActivateArrivedBTN
                                            ? servicesCommuter.arrivedCallBack
                                            : null,
                                        kBackColor: kYellow,
                                        kTextColor: kBlack,
                                        title: "Arrived ",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.blockY! * 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                } else if (!snapshot.hasData) {
                  return const Center(child: Text("No data found"));
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error Occured"));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ),
      ),
    );
  }

  Container widgetBTN(
      {required kBackColor,
      required title,
      required kTextColor,
      required onPress}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockX! * 8.611,
        vertical: SizeConfig.blockY! * 1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          kBorderRadius,
        ),
        color: kBackColor,
      ),
      child: GestureDetector(
        onDoubleTap: onPress,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: kBlueSnackBar,
            content: Text(
              "Double Tap",
              textAlign: TextAlign.center,
              style: kPoppinsSemiBold.copyWith(
                  fontSize: SizeConfig.blockX! * 4.611),
            ),
          ),
        ),
        child: Text(
          title,
          style: kPoppinsSemiBold.copyWith(
            color: kTextColor,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  updateCameraPosition(LatLng newPosition) async {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 15, target: newPosition),
      ),
    );
  }
}

class WidgetIcon extends StatelessWidget {
  final String icon;

  const WidgetIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: SizeConfig.blockX! * 7,
      backgroundColor: kBlack.withOpacity(0),
      child: Image.asset(icon, scale: SizeConfig.blockX! * 2.3),
    );
  }
}
