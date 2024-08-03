import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  Future<Database?> initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'TestDB');

    _database = await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await db
            .execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, value TEXT)");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log("DB_SERVICE: $newVersion");

        // Old version will also increment when the version is upgraded
        if (oldVersion < newVersion) {
          log('EXECUTE UPGRADE');
          await db.execute("ALTER TABLE Test ADD COLUMN name TEXT");

          // Cannot add the same column
          // await db.execute("ALTER TABLE Test ADD COLUMN name TEXT");
        }
      },
    );

    return _database;
  }
}
