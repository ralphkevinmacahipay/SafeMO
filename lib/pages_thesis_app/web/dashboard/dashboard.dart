import 'package:accounts/pages_thesis_app/web/dashboard/header/header.dart';
import 'package:accounts/pages_thesis_app/web/dashboard/main_body/body/main_body.dart';
import 'package:accounts/pages_thesis_app/web/dashboard/main_body/model_user/model_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('admin').snapshots();
  final allUsers = <User>[];
  late List<User> users;
  // final CollectionReference profileList =
  //     FirebaseFirestore.instance.collection('admin');

  @override
  void initState() {
    super.initState();
    // required#################################################################
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final uid = data["uid"];
                final nameUser = data["nameUser"];
                final description = data["description"];
                final scene = data["scene"];
                final time = data["time"];

                allUsers.add(User(
                  uid: uid,
                  fullName: nameUser,
                  description: description,
                  scene: scene,
                  time: time,
                ));
                users = List.of(allUsers);
              }).toList();

              return Column(
                children: [
                  const Header(),
                  MainBody(users: users),
                ],
              );
            }),
      ),
    );
  }
}
