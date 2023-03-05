import 'dart:async';
import 'package:accounts/db_thesis_app/database_exception.dart';
import 'package:accounts/extension/list/filter.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;
import 'dart:developer' as devtool show log;

class NotesService {
  Database? _db;
  // Storage of notes
  List<DatabaseNote> _notes = [];

  DatabaseUser? _user;

  // to make a singleton class (NotesService)
  // para ez nalang pag may changes sa bawat widgets
  static final NotesService _shared = NotesService._shareInstace();
  NotesService._shareInstace() {
    // ensures that _notsStreamcontrollers is initialized before the callback
    _notesStreamcontroller = StreamController<List<DatabaseNote>>.broadcast(
      // to populate the stream with our notes from database
      onListen: () {
        _notesStreamcontroller.sink.add(_notes);
      },
    );
  }

  factory NotesService() => _shared;

  // all changes will save here in stream and update the UI (callback)
  late final StreamController<List<DatabaseNote>> _notesStreamcontroller;

  // retrieve all notes from _noteStreamcontroller
  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamcontroller.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userID == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotesException();
        }
      });

  // get or create user
  Future<DatabaseUser> getOrcreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  // cache all notes
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamcontroller.add(_notes);
  }

  // allow update note
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    // make sure that note exists
    await getNote(id: note.id);

    // update the note
    final updatesCount = await db.update(
        noteTable,
        {
          textColumn: text,
          isSycedWithCloudColumn: 0,
        },
        where: 'id = ?',
        whereArgs: [note.id]);
    if (updatesCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      final updatedNOte = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNOte.id);
      _notes.add(updatedNOte);
      _notesStreamcontroller.add(_notes);
      return updatedNOte;
    }
  }

  // get all notes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRows) => DatabaseNote.fromRow(noteRows));
  }

  //  getnote
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(notes.first);

      // need e-remove yung existing note para ma update sa UI
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamcontroller.add(_notes);
      return note;
    }
  }

  // allow delete all notes
  Future<int> deleteAllNote() async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamcontroller.add(_notes);
    return numberOfDeletion;
  }

  // allow to delete note
  Future<void> deleteNote({required int id}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamcontroller.add(_notes);
    }
  }

  // create note
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    // make sure that owner in database has a correct ID
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    const text = '';

    // create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSycedWithCloudColumn: 1,
    });
    // to return the insatanc of a new note
    final note = DatabaseNote(
      id: noteId,
      text: text,
      isSyncedWithCloud: true,
      userID: owner.id,
    );

    _notes.add(note);
    _notesStreamcontroller.add(_notes);
    return note;
  }

  // allow to get the user
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  // create user
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userID = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    // to return the insatanc of a new user
    final user = DatabaseUser(
      id: userID,
      email: email,
    );
    return user;
  }

  // allow to delete user from database
  Future<void> deleteUser({required String email}) async {
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  // to avoid if statement every where making sure that database is open
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  // close the database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
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

  // open the database
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createTableUser);
      await db.execute(createTableNote);
      // To cache notes, after we open/create the database.
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });
  // read the user per Row
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID =$id, email= $email';

  // making an equality to make sure that two person is the same
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userID;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.text,
    required this.isSyncedWithCloud,
    required this.userID,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userID = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSycedWithCloudColumn] as int == 1 ? true : false);

  @override
  String toString() =>
      "Note, ID = $id,userID = $userID,isSyncedWithCloud = $isSyncedWithCloud,text = $text";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "userNotes";
const userTable = "user";
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = "text";
const isSycedWithCloudColumn = 'is_synced_with_cloud';

// Create Note Table
const createTableNote = '''
      CREATE TABLE IF NOT EXISTS "userNotes" (
	    "id"	INTEGER NOT NULL,
	    "user_id"	INTEGER NOT NULL,
	    "text"	TEXT,
	    "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	    FOREIGN KEY("user_id") REFERENCES "user"("id"),
	    PRIMARY KEY("id" AUTOINCREMENT)
      );
      ''';
// Create User Table
const createTableUser = '''
      CREATE TABLE IF NOT EXISTS "user" (
	    "id"	INTEGER NOT NULL,
	    "email"	TEXT NOT NULL UNIQUE,
    	PRIMARY KEY("id" AUTOINCREMENT)
        );
        ''';
