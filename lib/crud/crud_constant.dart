const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncWithCloudColumn = 'is_sync_with_cloud';

// db query
const createUserTable = '''
CREATE TABLE IF NOT EXITS "user" (
	"id"	INTEGER NOT NULL UNIQUE,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id","email")
);
''';
const createNotesTable = ''''
CREATE TABLE IF NOT EXITS "notes" (
        "id"	INTEGER NOT NULL UNIQUE,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
 );
      ''';
