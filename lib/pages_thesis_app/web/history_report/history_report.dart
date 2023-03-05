import 'package:accounts/pages_thesis_app/web/dashboard/main_body/model_user/model_user.dart';
import 'package:accounts/pages_thesis_app/web/side_menu/side_menu.dart';
import 'package:accounts/pages_thesis_app/web/user_location/user_location.dart';
import 'package:accounts/routes/route_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as devtools show log;

import '../user_location/services_report_history.dart';

class HistoryReport extends StatefulWidget {
  const HistoryReport({super.key});

  @override
  State<HistoryReport> createState() => _HistoryReportState();
}

class _HistoryReportState extends State<HistoryReport> {
  late final TextEditingController controller;
  final allRecords = <RecordCase>[];
  late List<RecordCase> recordCase;

  bool? isSearchTap;

  // final CollectionReference profileList =
  //     FirebaseFirestore.instance.collection('admin');

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    isSearchTap ??= false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(children: [
          const Expanded(
            flex: 1,
            child: SideMenu(),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  const Text(
                    "Reports History",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200),
                    child: TextField(
                      onChanged: searchItem,
                      controller: controller,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 50),
                          hintText: "Search",
                          fillColor: const Color.fromARGB(57, 165, 149, 149),
                          filled: true,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          prefixIcon: InkWell(
                            child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(16 * .75),
                              decoration: BoxDecoration(
                                color: Colors.blue[300],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 30,
                                fill: 1,
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          SizedBox(width: 150, child: Text("Name")),
                          SizedBox(width: 150, child: Text("description")),
                          SizedBox(width: 150, child: Text("scene")),
                          SizedBox(width: 150, child: Text("time")),
                          SizedBox(width: 150, child: Text("Rescuer")),
                          SizedBox(width: 150, child: Text("Action")),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.only(top: 10),
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[200]!.withOpacity(.5),
                    ),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("reports")
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            if (!isSearchTap!) {
                              snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                final uid = data["uid"];
                                final nameUser = data["nameUser"];
                                final description = data["description"];
                                final scene = data["scene"];
                                final time = data["time"];
                                final rescuer = data["rescuer"];

                                allRecords.add(RecordCase(
                                  uid: uid,
                                  fullname: nameUser,
                                  description: description,
                                  scene: scene,
                                  time: time,
                                  rescuer: rescuer,
                                ));
                                recordCase = List.of(allRecords);
                                devtools.log("code is here");
                              }).toList();
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.active:
                                return ListView.builder(
                                  itemCount: snapshot.data!.size,
                                  itemBuilder: (context, index) {
                                    return Consumer<HistoryServicesReport>(
                                      builder:
                                          (context, servicesReport, child) {
                                        servicesReport.setNameFields(
                                          nameUser: snapshot.data!.docs[index]
                                              ['nameUser'],
                                          description: snapshot
                                              .data!.docs[index]['description'],
                                          scene: snapshot.data!.docs[index]
                                              ['scene'],
                                          time: snapshot.data!.docs[index]
                                              ['time'],
                                          userID: snapshot.data!.docs[index]
                                              ['uid'],
                                        );
                                        servicesReport.setRescuer(
                                            rescue: snapshot.data!.docs[index]
                                                ['rescuer']);

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            SizedBox(
                                                width: 150,
                                                child: Text(servicesReport
                                                    .getnameUser)),
                                            SizedBox(
                                                width: 150,
                                                child: Text(servicesReport
                                                    .getdescription)),
                                            SizedBox(
                                              width: 150,
                                              child: servicesReport.getscene ==
                                                      "on the road"
                                                  ? roadWidget(
                                                      context: context,
                                                      index: index,
                                                      snapshot: snapshot,
                                                      servicesReportHistory:
                                                          servicesReport)
                                                  : imageWidget(
                                                      index: index,
                                                      servicesHistory:
                                                          servicesReport,
                                                      snapshot: snapshot),
                                            ),
                                            SizedBox(
                                                width: 150,
                                                child: Text(
                                                    servicesReport.getTime)),
                                            SizedBox(
                                                width: 150,
                                                child: Text(
                                                    servicesReport.getrescuer)),
                                            SizedBox(
                                                width: 150,
                                                child: ElevatedButton(
                                                    onPressed: () =>
                                                        servicesReport
                                                            .deleteRecord(
                                                                servicesReport
                                                                    .getuserID),
                                                    child:
                                                        const Text("Delete"))),
                                            const SizedBox(
                                              height: 50,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );

                              default:
                                // TODO: Handle this case.
                                return const Center(
                                    child: CircularProgressIndicator());
                            }
                          } else if (!snapshot.hasData) {
                            return const Center(
                                child: Text("No Data Available!!!"));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  InkWell imageWidget(
      {required AsyncSnapshot<QuerySnapshot> snapshot,
      required int index,
      required HistoryServicesReport servicesHistory}) {
    devtools.log("servicesHistory.getscene : ${servicesHistory.getscene}");
    devtools.log("servicesHistory.getuserID : ${servicesHistory.getuserID}");
    return InkWell(
        onTap: () => snapshot.data!.docs[index]['scene'] == "unable to capture"
            ? null
            : _launchUrl(snapshot.data!.docs[index]['scene']),
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

  InkWell roadWidget(
      {required AsyncSnapshot<QuerySnapshot> snapshot,
      required index,
      required BuildContext context,
      required HistoryServicesReport servicesReportHistory}) {
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
        child:
            SizedBox(width: 150, child: Text(servicesReportHistory.getscene)));
  }

  void searchItem(String query) {
    setState(() => isSearchTap = true);
    if (query.isNotEmpty) {
      final suggestion = allRecords.where((record) {
        final nameOfUser = record.fullname.toLowerCase();
        final input = query.toLowerCase();

        return nameOfUser.contains(input);
      }).toList();

      devtools.log(suggestion.toString());
      setState(() => recordCase = suggestion);
    }
  }
}
