import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DiaryDatabaseHelper {

  static final _databaseName = "Budgeterr.db";
  static final _databaseVersion = 1;

  static final table = 'DiaryRecords';

  static final recordId = 'recordId';
  static final year = 'year';
  static final month = 'month';
  static final date = 'date';
  static final time = 'time';
  static final title = 'title';
  static final notes = 'notes';

  // make this a singleton class
  DiaryDatabaseHelper._privateConstructor();
  static final DiaryDatabaseHelper instance = DiaryDatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $recordId TEXT PRIMARY KEY ,
            $year TEXT NOT NULL,
            $month TEXT NOT NULL,
            $date TEXT NOT NULL,
            $time TEXT NOT NULL,
            $title TEXT NOT NULL,
            $notes TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row,conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteAllRecords() async {
    Database db = await instance.database;
    db.delete(table);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String id = row[recordId];
    return await db.update(table, row, where: '$recordId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$recordId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> specificDate(String year1,String month1,String date1) async {
    Database db = await instance.database;
    return await db.query(table,where:'$year = ? AND $month = ? AND $date = ?',whereArgs: [year1,month1,date1] );
  }


}


