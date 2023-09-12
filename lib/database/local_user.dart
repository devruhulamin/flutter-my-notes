import 'package:flutter/foundation.dart';

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> data)
      : id = data[columnId] as int,
        email = data[columnEmail] as String;

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
      : id = other[columnId] as int,
        userId = other[userIdColumn] as int,
        text = other[textColumn] as String,
        isSyncWithCloud = other[isSyncWithCloudColumn] == 0 ? false : true;
  @override
  String toString() {
    return 'Note: $id User : $userId isSync: $isSyncWithCloud';
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id;
}

const columnId = 'id';
const columnEmail = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncWithCloudColumn = 'is_sync_with_cloud';
