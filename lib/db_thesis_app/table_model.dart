import 'package:accounts/db_thesis_app/database_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as devtool show log;

class SafAwareService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  //ensure that database is open
  Future<void> _ensureDBisOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

// insert data to database
  Future<void> insertCommuter(
      {required int id,
      required String name,
      required String email,
      required String gender,
      required int number,
      required int contactPerson}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    await db.insert(
      commuterTable,
      {
        idColmn: id,
        nameColmn: name,
        emailColmn: email,
        genderColmn: gender,
        numberColmn: number,
        contactColmn: contactPerson
      },
    );
    devtool.log('done insert');
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createCommuterTable);
      devtool.log("done create");
      // To cache notes, after we open/create the database.

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

// Database Model
@immutable
class DatabaseCommuter {
  final int id;
  final String name;
  final String email;
  final String gender;
  final int number;
  final int contactPerson;

  const DatabaseCommuter({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.number,
    required this.contactPerson,
  });

  DatabaseCommuter.fromRow(Map<String, Object?> map)
      : id = map[idColmn] as int,
        name = map[nameColmn] as String,
        email = map[emailColmn] as String,
        gender = map[genderColmn] as String,
        number = map[numberColmn] as int,
        contactPerson = map[contactColmn] as int;

  @override
  String toString() =>
      'commuter, id=$id, name=$name,gender=$gender,number=$number,contactPerson=$contactPerson';
  // @override
  // bool operator ==(covariant DatabaseCommuter other) => id == other.id;

  // @override
  // int get hashcode => id.hashCode;
}

const commuterTable = "commuter";
const idColmn = "id_commuter";
const nameColmn = "name_commuter";
const emailColmn = "email_commuter";
const genderColmn = "gender";
const numberColmn = "contact_number";
const contactColmn = "contactPerson";
const dbName = 'SafAware.db';

// Create commuter Table
const createCommuterTable = '''
      CREATE TABLE IF NOT EXISTS "commuter" (
	        "id_commuter"	INTEGER NOT NULL,
	        "name_commuter"	String NOT NULL,
	        "email_commuter"	String NOT NULL,
	        "gender"	String NOT NULL,
	        "contact_number"	INTEGER,
	        "contactPerson"	INTEGER,
	        PRIMARY KEY("id_commuter" AUTOINCREMENT)
);
      ''';
