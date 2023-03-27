import 'dart:async';

import 'package:accounts/no_sql_db/encrypt_decrypt_service.dart';
import 'package:accounts/no_sql_db/nosql_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class ReportCommuterServices extends ChangeNotifier {
  List<String> items = [
    'Incident',
    'Medical emergencies',
    'Fires',
    'Criminal activity',
    'Accidents',
    'Disasters',
    'Suicidal threats',
    'Animal attacks',
    'Terrorism',
    'Hazmat incidents'
  ];

  String selectedItem = 'Incident';
  String _description = '';
  String _scene = '';
  String _headCOunt = '';
  // TODO : Initialization ********************

  int? _timeOfArrivalInit;

  bool isReported = false;
  String googleAPI = "AIzaSyABH--keESh9Hwo_HsO8QPQKc0V-KJfiKc";
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  ReportModel caseUser = ReportModel();
  final auth = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? user;

  final _user = FirebaseAuth.instance;
  AsyncSnapshot<QuerySnapshot>? snapshot;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _reportStream;

  // TODO : getter ********************
  String get getHeadCount => _headCOunt;
  List<String> get getListItems => items;
  String get getSelectedItems => selectedItem;
  String get getScene => _scene;
  String get getDescription => _description;
  int get getInitTimeOfArrival => _timeOfArrivalInit!;
  AsyncSnapshot<QuerySnapshot> get getSnapshot => snapshot!;
  User get getUser => user!;
  bool get getisReported => isReported;
  Stream<QuerySnapshot<Map<String, dynamic>>> get getReportStream =>
      _reportStream!;

  // TODO : setter ********************
  setHeadCount(String item) {
    _headCOunt = item;
  }

  setSelectedItem(String item) {
    selectedItem = item;
    notifyListeners();
  }

  setDescription(String newVal) {
    _description = newVal;
  }

  setScene(String newVal) {
    _scene = newVal;
  }

  setSnapShot(AsyncSnapshot<QuerySnapshot> setNewSnapshot) {
    snapshot = setNewSnapshot;
    // notifyListeners();
  }

  setUser() {
    user = _auth.currentUser;
    notifyListeners();
  }

  setIsReported(bool isReportedVal) {
    isReported = isReportedVal;
    notifyListeners();
  }

  reportStream() {
    _reportStream = auth
        .collection("users")
        .where("uid", isEqualTo: _user.currentUser?.uid)
        .snapshots();
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

  insertCaseReport() async {
    setUser();
    setIsReported(true);
    devtools.log('insert Method');

    final myName = getInfo(getSnapshot, "fullname");
    final getTime = DateTime.now().toString().substring(0, 19);

    devtools.log('This is the Time: $getTime');
    devtools.log(getTime);

    caseUser.uid = getUser.uid;
    caseUser.nameUser = myName;
    caseUser.time = getTime;
    caseUser.typeOfIncident = getSelectedItems;
    caseUser.headCount = getHeadCount;
    caseUser.description = getDescription;
    caseUser.scene = getScene;

    await firebaseFirestore
        .collection("admin")
        .doc(getUser.uid)
        .set(caseUser.toMap());
  }
}
