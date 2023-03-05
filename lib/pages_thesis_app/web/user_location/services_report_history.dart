import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryServicesReport extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  BuildContext context;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  HistoryServicesReport(this.context);
  // INITIALIZER ***************************************************************
  String _nameUser = "",
      _description = "",
      _scene = "",
      _time = "",
      _rescuer = "",
      _userID = "";

  // GETTER ********************************************************************
  String get getnameUser => _nameUser;
  String get getdescription => _description;
  String get getscene => _scene;
  String get getTime => _time;
  String get getrescuer => _rescuer;
  String get getuserID => _userID;

  // SETTER  *******************************************************************
  deleteCollection() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    await firebaseFirestore.collection("users").doc(user!.uid).delete();
    //await AuthService.firebase().logout();
    await FirebaseAuth.instance.currentUser!.delete();
  }

  Future deleteRecord(String userID) {
    return QuickAlert.show(
      onConfirmBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
        Fluttertoast.showToast(
          fontSize: 20,
          msg: "Deleted Succesfully!",
        );

        await firebaseFirestore.collection("reports").doc(userID).delete();
      },
      title: "Are you sure you want to delete this report history?",
      onCancelBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      showCancelBtn: true,
      cancelBtnText: "Cancel",
      context: context,
      type: QuickAlertType.confirm,
    );
  }

  Future deleteAccount(String userID) {
    return QuickAlert.show(
      onConfirmBtnTap: () async {
        Navigator.of(context, rootNavigator: true).pop();
        Fluttertoast.showToast(
          fontSize: 20,
          msg: "Deleted Succesfully!",
        );

        deleteCollection();

        await firebaseFirestore.collection("fake_report").doc(userID).delete();
      },
      title: "Are you sure you want to delete this Account?",
      onCancelBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      showCancelBtn: true,
      cancelBtnText: "Cancel",
      context: context,
      type: QuickAlertType.confirm,
    );
  }

  setRescuer({required String rescue}) {
    _rescuer = rescue;
  }

  setNameFields({
    required String nameUser,
    required String description,
    required String scene,
    required String time,
    required String userID,
  }) {
    _nameUser = nameUser;
    _description = description;
    _scene = scene;
    _time = time;
    _userID = userID;
  }
}
