class User {
  // required#################################################################
  final String uid;
  final String fullName;
  final String description;
  final String scene;
  final String time;
  // required#################################################################
  const User(
      {required this.uid,
      required this.fullName,
      required this.time,
      required this.description,
      required this.scene});
  // required#################################################################
  User copy({
    String? uid,
    String? fullName,
    String? time,
    String? description,
    String? scene,
  }) =>
      User(
        uid: uid ?? this.uid,
        fullName: fullName ?? this.fullName,
        time: time ?? this.time,
        description: description ?? this.description,
        scene: scene ?? this.scene,
      );
  // required#################################################################
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          fullName == other.fullName &&
          time == other.time &&
          description == other.description &&
          scene == other.scene;
  // required#################################################################
  @override
  int get hashCode =>
      uid.hashCode ^
      fullName.hashCode ^
      time.hashCode ^
      description.hashCode ^
      scene.hashCode;
}

class RecordCase {
  // required#################################################################
  final String uid;
  final String fullname;
  final String description;
  final String scene;
  final String time;
  final String rescuer;

  // required#################################################################
  const RecordCase({
    required this.uid,
    required this.fullname,
    required this.description,
    required this.scene,
    required this.time,
    required this.rescuer,
  });
  // required#################################################################
  RecordCase copy({
    String? uid,
    String? firstName,
    String? description,
    String? scene,
    String? time,
    String? rescuer,
  }) =>
      RecordCase(
        uid: uid ?? this.uid,
        fullname: firstName ?? fullname,
        description: description ?? this.description,
        scene: scene ?? this.scene,
        time: time ?? this.time,
        rescuer: rescuer ?? this.rescuer,
      );
  // required#################################################################
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordCase &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          fullname == other.fullname &&
          description == other.description &&
          scene == other.scene &&
          time == other.time &&
          rescuer == other.rescuer;

  // required#################################################################
  @override
  int get hashCode =>
      uid.hashCode ^
      fullname.hashCode ^
      description.hashCode ^
      scene.hashCode ^
      time.hashCode ^
      rescuer.hashCode;
}
