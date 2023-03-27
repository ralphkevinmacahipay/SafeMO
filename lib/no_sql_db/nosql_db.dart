import 'package:encrypt/encrypt.dart';

class UserModel {
  String? uid;
  String? password;
  String? email;
  String? fullname;
  String? gender;
  String? myNumber;
  String? contactPersonName;
  String? contactPersonNumber;

  UserModel({
    this.uid,
    this.email,
    this.fullname,
    this.gender,
    this.myNumber,
    this.contactPersonName,
  });

  //receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      fullname: map['fullname'],
      gender: map['gender'],
      myNumber: map['myNumber'],
      contactPersonName: map['contactPerson'],
    );
  }

  // sending data to our server
  // target: LatLng(9.740696, 118.7355555556),

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullname': fullname,
      'gender': gender,
      'myNumber': myNumber,
      'contactPerson': {
        "Name": contactPersonName,
        "contactNumber": contactPersonNumber,
      },
      "latitude": 9.740696,
      "longitude": 118.7355555556,
    };
  }
}

Encrypted encryptedData({required String data}) {
  final key = Key.fromUtf8('my 32 length key................');
  final iv = IV.fromLength(16);

  final encrypter = Encrypter(AES(key));
  final encryptedData = encrypter.encrypt(data, iv: iv);
  return encryptedData;
}

String decryptedData({required String data}) {
  final key = Key.fromUtf8('my 32 length key................');
  final iv = IV.fromLength(16);

  final encrypter = Encrypter(AES(key));
  final decryptedData = encrypter.decrypt64(data, iv: iv);
  return decryptedData.toString();
}

class ReportModel {
  String? uid;
  String? nameUser;
  String? time;
  String? typeOfIncident;
  String? headCount;
  String? description;
  String? scene;

  ReportModel({
    this.uid,
    this.nameUser,
    this.typeOfIncident,
    this.headCount,
    this.time,
    this.description,
    this.scene,
  });

  //receiving data from server
  factory ReportModel.fromMap(map) {
    return ReportModel(
      uid: map['uid'],
      nameUser: map['nameUser'],
      time: map['time'],
      description: map['description'],
      typeOfIncident: map['typeOfIncident'],
      headCount: map['headCount'],
      scene: map['scene'],
    );
  }

  // sending data to our server
  // target: LatLng(9.740696, 118.7355555556),

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "nameUser": nameUser,
      'time': time,
      "description": description,
      "typeOfIncident": typeOfIncident,
      "headCount": headCount,
      'scene': scene,
    };
  }
}

class RecordModel {
  String? uid;
  String? nameUser;
  String? description;
  String? scene;
  String? time;
  String? rescuer;

  RecordModel({
    this.uid,
    this.nameUser,
    this.description,
    this.scene,
    this.time,
    this.rescuer,
  });

  //receiving data from server
  factory RecordModel.fromMap(map) {
    return RecordModel(
      uid: map['uid'],
      nameUser: map['nameUser'],
      description: map['description'],
      scene: map['scene'],
      time: map['time'],
      rescuer: map['rescuer'],
    );
  }

  // sending data to our server
  // target: LatLng(9.740696, 118.7355555556),

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "nameUser": nameUser,
      "description": description,
      'scene': scene,
      "time": time,
      "rescuer": rescuer,
    };
  }
}
