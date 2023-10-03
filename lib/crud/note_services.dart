import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mynotes/crud/crud_constant.dart';
import 'package:mynotes/crud/crud_exception.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class NoteServices {
  NoteServices._sharedInstance() {
    print("_shared Instance called");
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        print(_notes);
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  static final _shared = NoteServices._sharedInstance();

  factory NoteServices() => _shared;

  Database? _db;
  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get getUserAllNotes =>
      _notesStreamController.stream;

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpen {}
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFoundUser {
      final newUser = await createUser(email: email);
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();

    _notesStreamController.add(_notes);
  }

  // updating a note
  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(
        noteTable, {textColumn: text, isSyncWithCloudColumn: 0},
        where: 'id = ?', whereArgs: [note.id]);
    print("Here iam updated count $updateCount");
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    }
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  // get allnotes
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    final result = notes.map((note) => DatabaseNote.fromRow(note));
    return result;
  }

  // get a single note by its id
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final note =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (note.isEmpty) {
      throw CouldNotFindNote();
    }

    final newNote = DatabaseNote.fromRow(note.first);
    _notes.removeWhere((element) => element.id == newNote.id);
    _notes.add(newNote);
    _notesStreamController.add(_notes);
    return newNote;
  }

  // delete all notes
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deletedCount;
  }

// deleteing a note by id
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount =
        await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
    _notes.removeWhere((element) => element.id == id);
    _notesStreamController.add(_notes);
  }

// insert a new to database with its owner
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final user = await getUser(email: owner.email);
    if (user != owner) {
      throw CouldNotFoundUser();
    }
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncWithCloudColumn: 1,
    });
    final newNote = DatabaseNote(
      id: noteId,
      text: text,
      isSyncWithCloud: true,
      userId: owner.id,
    );
    _notes.add(newNote);
    _notesStreamController.add(_notes);
    return newNote;
  }

// delete the user from database
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  // get the user from database
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFoundUser();
    }

    return DatabaseUser.fromRow(result.first);
  }

// creating a user in database if user not exits
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final checkUser = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (checkUser.isNotEmpty) {
      throw CouldNotCreateUser();
    }
    try {
      final userId = await db.insert(
          userTable, {emailColumn: email.toLowerCase()},
          conflictAlgorithm: ConflictAlgorithm.replace);
      return DatabaseUser(id: userId, email: email);
    } catch (e) {
      rethrow;
    }
  }

// trying to getting database if not then throw exception
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      return db;
    }
  }

// closing the open database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

// open database connection
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpen();
    }
    try {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDocumentsDir.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> data)
      : id = data[idColumn] as int,
        email = data[emailColumn] as String;

  @override
  String toString() {
    return "id : $id email : $email";
  }

  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncWithCloud;

  const DatabaseNote(
      {required this.id,
      required this.text,
      required this.isSyncWithCloud,
      required this.userId});

  DatabaseNote.fromRow(Map<String, Object?> other)
      : id = other[idColumn] as int,
        userId = other[userIdColumn] as int,
        text = other[textColumn] as String,
        isSyncWithCloud = other[isSyncWithCloudColumn] == 0 ? false : true;
  @override
  String toString() {
    return 'Note: $id User : $userId Text: $text';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id;
}
