// const dbName = 'notes.db';
// const noteTable = 'notes';
// const userTable = 'dbuser';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncWithCloudColumn = 'is_sync_with_cloud';

// // db query
// const createUserTable = '''
// CREATE TABLE IF NOT EXISTS "dbuser" (
//     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
//     "email" TEXT NOT NULL UNIQUE
// );

// ''';
// const createNotesTable = '''
// CREATE TABLE IF NOT EXISTS notes (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     user_id INTEGER NOT NULL,
//     text TEXT,
//     is_sync_with_cloud INTEGER NOT NULL DEFAULT 0,
//     FOREIGN KEY("user_id") REFERENCES "user"("id") ON DELETE CASCADE
// );
// ''';
