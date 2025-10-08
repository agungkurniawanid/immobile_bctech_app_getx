import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper db = DatabaseHelper._();

  static Database? _database;

  static const Map<int, List<String>> arrQuery = {
    2: [
      // VERSI 2 (flow baru) MULAI DARI DOCTYPE PSPPA
      "ALTER TABLE user ADD COLUMN id INTEGER",
      "ALTER TABLE user ADD COLUMN userid INTEGER",
      "ALTER TABLE user ADD COLUMN name TEXT(100)",
      "ALTER TABLE user ADD COLUMN email TEXT(50)",
      "ALTER TABLE user ADD COLUMN hasLogin TEXT(10)",
    ],
  };

  Future<void> openDb() async {
    try {
      var db = await database;

      await db.execute("DROP TABLE IF EXISTS user;");
      await db.execute("DROP TABLE IF EXISTS category;");
      await db.execute(
        "CREATE TABLE user("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "userid INTEGER NOT NULL,"
        "name TEXT (100),"
        "email TEXT (50),"
        "hasLogin TEXT (10)"
        ")",
      );
      await db.execute(
        "CREATE TABLE category("
        "id INTEGER,"
        "category TEXT (100),"
        "inventory_group_id TEXT (100),"
        "inventory_group_name TEXT (50)"
        ")",
      );
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "immobile.db");
    return await openDatabase(
      path,
      version: 7,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE user("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "userid INTEGER NOT NULL,"
          "name TEXT (100),"
          "email TEXT (50),"
          "hasLogin TEXT (10)"
          ")",
        );
        await db.execute(
          "CREATE TABLE category("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "category TEXT (100),"
          "inventory_group_id TEXT (100),"
          "inventory_group_name TEXT (50)"
          ")",
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          if (arrQuery.containsKey(i)) {
            for (final query in arrQuery[i]!) {
              await db.execute(query);
            }
          }
        }
      },
    );
  }

  Future<int> loginUser(Account account, String hasLogin) async {
    final db = await database;
    account.hasLogin = hasLogin;
    var user = await db.rawInsert(
      "INSERT Into user (id,userid,name,email,hasLogin) VALUES (?,?,?,?,?)",
      [1, account.userid, account.name, account.email, account.hasLogin],
    );
    return user;
  }

  Future<void> deleteDb() async {
    final db = await database;
    await db.execute("DELETE FROM user");
    await db.execute("DELETE FROM category");
  }

  Future<int?> insertCategory(Category category) async {
    try {
      final db = await database;
      var user = await db.rawInsert(
        "INSERT Into category (id,category,inventory_group_id,inventory_group_name) VALUES (?,?,?,?)",
        [
          1,
          category.category,
          category.inventoryGroupId,
          category.inventoryGroupName,
        ],
      );
      return user;
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<int?> insertOut(OutModel out) async {
    try {
      final db = await database;
      var user = await db.rawInsert(
        "INSERT into out (recordid,createdat,inventory_group,location,delivery_date,total_item,item,detail,doctype) VALUES (?,?,?,?,?,?,?,?,?)",
        [
          out.recordid,
          out.createdat,
          out.inventoryGroup,
          out.location,
          out.deliveryDate,
          out.totalItem,
          out.item,
          out.detail,
          out.doctype,
        ],
      );
      return user;
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<List<Category>?> getCategoryall() async {
    try {
      final db = await database;
      var res = await db.rawQuery("SELECT * FROM category");
      List<Category> list = res.isNotEmpty
          ? res.map((c) => Category.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<List<Category>?> getCategorywithrole(String categoryid) async {
    try {
      final db = await database;
      var res = await db.rawQuery("SELECT * FROM category where category = ?", [
        categoryid,
      ]);
      List<Category> list = res.isNotEmpty
          ? res.map((c) => Category.fromJson(c)).toList()
          : [];
      return list;
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<String> checkHasLogin() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> hasLogin = await db.rawQuery(
        "SELECT hasLogin FROM user",
      );
      final status = hasLogin.isEmpty
          ? 'null'
          : hasLogin.first["hasLogin"].toString();
      return status;
    } catch (e) {
      Logger().e(e);
      return 'null';
    }
  }

  Future<String?> getUser() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT name FROM user",
      );
      if (result.isEmpty) return null;
      final name = result.first["name"].toString();
      return name;
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<String> checkuserid() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> userid = await db.rawQuery(
        "SELECT userid FROM user",
      );
      String user = userid.isEmpty ? 'null' : userid.first["userid"].toString();
      return user;
    } catch (e) {
      Logger().e(e);
      return 'null';
    }
  }
}

// Model classes (asumsi - Anda perlu menyesuaikan dengan model yang sebenarnya)
class Account {
  final int userid;
  final String name;
  final String email;
  String hasLogin;

  Account({
    required this.userid,
    required this.name,
    required this.email,
    required this.hasLogin,
  });
}

class Category {
  final String category;
  final String inventoryGroupId;
  final String inventoryGroupName;

  Category({
    required this.category,
    required this.inventoryGroupId,
    required this.inventoryGroupName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'] as String,
      inventoryGroupId: json['inventory_group_id'] as String,
      inventoryGroupName: json['inventory_group_name'] as String,
    );
  }
}

class OutModel {
  final String recordid;
  final String createdat;
  final String inventoryGroup;
  final String location;
  final String deliveryDate;
  final String totalItem;
  final String item;
  final String detail;
  final String doctype;

  OutModel({
    required this.recordid,
    required this.createdat,
    required this.inventoryGroup,
    required this.location,
    required this.deliveryDate,
    required this.totalItem,
    required this.item,
    required this.detail,
    required this.doctype,
  });
}
