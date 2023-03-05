import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecordServices extends ChangeNotifier {
  // INITIALIZATION OF VARIABLES *********************
  AsyncSnapshot<QuerySnapshot>? _snaphot;
  LatLng? _useLoc;
  final _auth = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;
  String userID = '';

  // GETTER ******************************************

  // GET THE LOCATION OF THE USER
  LatLng get getUserLoc => _useLoc!;
  // GET THE VALUE OF SNAPSHOT
  AsyncSnapshot<QuerySnapshot> get getSnapShot => _snaphot!;

  //GET THE USER ID
  String get getUserID => userID;

  // GET THE STREAM DATA
  Stream<QuerySnapshot<Map<String, dynamic>>> get getStream => _stream!;

  // SETTER  ******************************************

  // SET THE LOCATION OF THE USER
  setUserLoc(LatLng latLang) {
    _useLoc = latLang;
    notifyListeners();
  }

  // SET THE SNAPSHOT
  setSnapshot(AsyncSnapshot<QuerySnapshot> neSnap) {
    _snaphot = neSnap;

    // TO SET THE LOCATION OF THE USER
  }

  // SET THE STREAM
  setStream() {
    _stream = _auth
        .collection("admin")
        .where("uid", isEqualTo: getUserID)
        .snapshots();
  }

  // TO SET THE USER ID
  setUserID(String val) {
    userID = val;
  }
}
