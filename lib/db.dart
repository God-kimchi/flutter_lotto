import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

final String tableName = 'lotto';

class DBHelper {
  DBHelper._();
  static final DBHelper db = DBHelper._();
  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(await getDatabasesPath(), 'lotto_database.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $tableName (
          no TEXT PRIMARY KEY,
          date TEXT,
          win TEXT
        )
        ''');
      },
    );
    return db;
  }

  Future<void> insert(Map map) async {
    final db = await database;
    await db.insert(tableName, map);
  }

  Future<List<Map<String, dynamic>>> all() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
      maps.length,
      (i) => {
        'no': maps[i]['no'],
        'date': maps[i]['date'],
        'win': maps[i]['win'],
      },
    );
  }

  Future<List<Map<String, dynamic>>> find(String no) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'no = ?', whereArgs: [no]);
    return List.generate(
      maps.length,
      (i) => {
        'no': maps[i]['no'],
        'date': maps[i]['date'],
        'win': maps[i]['win'],
      },
    );
  }
}
