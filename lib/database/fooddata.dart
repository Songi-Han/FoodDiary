import 'dart:typed_data';
import 'dart:ui';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

final String tableFoodLog = 'foodlog';
final String columnId = '_id';
final String columnDate = '_datetime';
final String columnContent = 'content';
final String columnImage = 'image';
final String columnFoods = 'foods';
final String columnCalories = 'calories';

class FoodData {
  int? id;
  String? date;
  String? content;
  late Uint8List image;
  late String foods;
  late int calories;

  FoodData({
    this.id,
    this.date,
    this.content,
    required this.image,
    required this.foods,
    required this.calories,
  });

  Map<String , dynamic?> toMap() {
    var map = <String , dynamic?>{
      columnDate : date,
      columnContent : content,
      columnFoods : foods,
      columnImage : image,
      columnCalories : calories,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  FoodData.fromMap(Map<String, dynamic?> map){
    id = map[columnId] as int?;
    date = map[columnDate] as String?;
    content = map[columnContent] as String?;
    foods = map[columnFoods] as String;
    image = map[columnImage] as Uint8List;
    calories = map[columnCalories] as int;
  }

  static Image uint8listToImage(Uint8List uint8list) {
    Image image;
    image = Image.memory(
      uint8list,
      fit: BoxFit.cover,
    );
    return image;
  }
}

class FoodDataProvider {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  Future init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), tableFoodLog),
      onCreate: onCreateDB,
      version: 1,
    );
  }

  Future<void> onCreateDB(Database db, int version) {
    return db.execute('''
              create table $tableFoodLog ( 
              $columnId integer primary key autoincrement, 
              $columnDate text not null,
              $columnContent text null,
              $columnFoods text not null,
              $columnImage BLOB not null,
              $columnCalories integer not null)
            ''');
  }

  // Future<void> insert(FoodData fooddata) async {
  //   final db = await database;
  //   await db.insert(tableFoodLog, fooddata.toMap());
  // }

  Future openDB(String path) async {
    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
              create table $tableFoodLog ( 
              $columnId integer primary key autoincrement, 
              $columnDate datetime not null,
              $columnContent text null,
              $columnFoods text not null,
              $columnImage BLOB not null,
              $columnCalories integer not null)
            ''');
        });
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> fooddata) async {
    fooddata['_id'] = await _db?.insert(tableFoodLog, fooddata);
    return fooddata;
  }

  Future<List<FoodData>> fooddatas() async {
    final db = await database;
    List<FoodData> fooddatas = [];

    final List<Map<String, Object?>> maps = await db.query(
      tableFoodLog,
      orderBy: "$columnId desc",
    );
    for (var map in maps) {
      fooddatas.add(FoodData.fromMap(map));
    }
    return fooddatas;
  }

  Future<List<FoodData>> getFoodlog(String StartDate, String EndDate) async {
    final db = await database;
    List<FoodData> fooddatas = [];

    final List<Map<String, Object?>> maps = await db.query(
        tableFoodLog,
        columns: [columnId, columnDate, columnContent, columnImage, columnFoods, columnCalories],
        where: 'DATE($columnDate) BETWEEN ? AND ?',
        whereArgs: [StartDate, EndDate],
        orderBy: "$columnDate desc");
    for (var map in maps) {
      fooddatas.add(FoodData.fromMap(map));
    }
    return fooddatas;
  }

  Future<int> delete(int id) async {
    if( _db != null ){
      return await _db!.delete(tableFoodLog, where: '$columnId = ?', whereArgs: [id]);
    }
    return -1;
  }

  Future<int> update(FoodData fooddata) async {
    if( _db != null) {

      return await _db!.update(tableFoodLog, fooddata.toMap(),
          where: '$columnId = ?', whereArgs: [fooddata.id]);
    }

    return -1;
  }

  Future close() async => _db!.close();


}

