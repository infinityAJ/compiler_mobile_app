import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DBprovider {
  DBprovider._();
  static final DBprovider db = DBprovider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    dynamic documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "programs.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE programs ("
          "id INTEGER PRIMARY KEY,"
          "lang TEXT,"
          "program TEXT"
          ")");
      await db.insert("programs",
          Entry(id: 1, lang: "Python", program: "print('hello')").toMap());
    });
  }

  Entry fromJson(String str) {
    final data = json.decode(str);
    return Entry.fromMap(data);
  }

  String toJson(Entry data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }
//CRUD operations

  newEntry(Entry fresh) async {
    print("in newentry");
    final db = await database;
    var table = await db.rawQuery("Select MAX(id)+1 as id from programs");
    final newid = table.first['id'];
    newid is int ? fresh.id = newid : fresh.id = 1;
    var raw = await db.insert("programs", fresh.toMap());
    return raw;
  }

  langFiles(String lang) async {
    final db = await database;
    var res = await db.query("programs", where: "lang = ?", whereArgs: [lang]);
    List<Entry> list =
        res.isNotEmpty ? res.map((c) => Entry.fromMap(c)).toList() : [];
    return list;
  }

  getEntry(int id) async {
    final db = await database;
    var res = await db.query("programs", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Entry.fromMap(res.first) : Null;
  }

  updateEntry(Entry file) async {
    final db = await database;
    var res = await db
        .update("programs", file.toMap(), where: "id=?", whereArgs: [file.id]);
    return res;
  }

  deleteEntry(int id) async {
    final db = await database;
    db.delete("programs", where: "id = ?", whereArgs: [id]);
  }
}

class Entry {
  int id;
  String lang;
  String program;

  Entry({this.id, this.lang, this.program});

  factory Entry.fromMap(Map<String, dynamic> json) =>
      new Entry(id: json['id'], lang: json['lang'], program: json['program']);

  Map<String, dynamic> toMap() => {"id": id, "lang": lang, "program": program};
}
