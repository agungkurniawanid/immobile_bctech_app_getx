import 'package:immobile_app_fixed/models/account_model.dart';
import 'package:immobile_app_fixed/models/category_model.dart';
import 'package:immobile_app_fixed/models/out_model.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// ------------------------------
// Database Helper
// ------------------------------
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper db = DatabaseHelper._();

  static Database? _database;

  static const Map<int, List<String>> arrQuery = {
    2: [
      // VERSI 2 (flow baru)
      "ALTER TABLE user ADD COLUMN id INTEGER",
      "ALTER TABLE user ADD COLUMN userid INTEGER",
      "ALTER TABLE user ADD COLUMN name TEXT(100)",
      "ALTER TABLE user ADD COLUMN email TEXT(50)",
      "ALTER TABLE user ADD COLUMN hasLogin TEXT(10)",
    ],
  };

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  Future<void> openDb() async {
    try {
      var db = await database;
      await db.execute("DROP TABLE IF EXISTS user;");
      await db.execute("DROP TABLE IF EXISTS category;");

      await db.execute("""
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          userid INTEGER NOT NULL,
          name TEXT(100),
          email TEXT(50),
          hasLogin TEXT(10)
        )
      """);

      await db.execute("""
        CREATE TABLE category(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          category TEXT(100),
          inventory_group_id TEXT(100),
          inventory_group_name TEXT(50)
        )
      """);
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final db = await database;
      final res = await db.query("category");

      // Ubah hasil query (List<Map<String, dynamic>>) menjadi List<Category>
      return res.map((map) {
        return Category(
          category: map['category']?.toString(),
          inventoryGroupId: map['inventory_group_id']?.toString(),
          inventoryGroupName: map['inventory_group_name']?.toString(),
        );
      }).toList();
    } catch (e) {
      Logger().e("getCategories error: $e");
      return [];
    }
  }

  Future<void> clearCategories() async {
    try {
      final db = await database;
      await db.delete("category");
    } catch (e) {
      Logger().e("clearCategories error: $e");
    }
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "immobile.db");

    return await openDatabase(
      path,
      version: 7,
      onCreate: (Database db, int version) async {
        await db.execute("""
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            userid INTEGER NOT NULL,
            name TEXT(100),
            email TEXT(50),
            hasLogin TEXT(10)
          )
        """);

        await db.execute("""
          CREATE TABLE category(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            category TEXT(100),
            inventory_group_id TEXT(100),
            inventory_group_name TEXT(50)
          )
        """);
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

  Future<void> deleteDb() async {
    final db = await database;
    await db.execute("DELETE FROM user");
    await db.execute("DELETE FROM category");
  }

  // ------------------------------
  // CATEGORY
  // ------------------------------
  Future<int?> insertCategory(Map<String, dynamic> category) async {
    try {
      final db = await database;
      return await db.rawInsert(
        "INSERT INTO category (category,inventory_group_id,inventory_group_name) VALUES (?,?,?)",
        [
          category['category'],
          category['inventory_group_id'],
          category['inventory_group_name'],
        ],
      );
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCategoryAll() async {
    try {
      final db = await database;
      var res = await db.rawQuery("SELECT * FROM category");
      return res;
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  // Dalam class DatabaseHelper
  Future<int> loginUser(Account account, String hasLogin) async {
    final db = await database;

    // Buat objek baru agar tidak melanggar aturan final
    final updatedAccount = Account(
      userid: account.userid,
      name: account.name,
      email: account.email,
      status: account.status,
      hasLogin: hasLogin,
    );

    return await db.rawInsert(
      "INSERT INTO user (id, userid, name, email, hasLogin) VALUES (?,?,?,?,?)",
      [
        1,
        updatedAccount.userid,
        updatedAccount.name,
        updatedAccount.email,
        updatedAccount.hasLogin,
      ],
    );
  }

  Future<List<Category>> getCategoryWithRole(String role) async {
    try {
      final db = await database;
      final res = await db.rawQuery(
        "SELECT * FROM category WHERE category = ?",
        [role],
      );

      return res.map((map) {
        return Category(
          category: map['category']?.toString(),
          inventoryGroupId: map['inventory_group_id']?.toString(),
          inventoryGroupName: map['inventory_group_name']?.toString(),
        );
      }).toList();
    } catch (e) {
      Logger().e(e);
      return [];
    }
  }

  Future<String> checkHasLogin() async {
    try {
      final db = await database;
      final result = await db.rawQuery("SELECT hasLogin FROM user");
      return result.isEmpty ? 'null' : result.first["hasLogin"].toString();
    } catch (e) {
      Logger().e(e);
      return 'null';
    }
  }

  Future<String?> getUser() async {
    try {
      final db = await database;
      final result = await db.rawQuery("SELECT name FROM user");
      return result.isEmpty ? null : result.first["name"].toString();
    } catch (e) {
      Logger().e(e);
      return null;
    }
  }

  Future<String> checkUserId() async {
    try {
      final db = await database;
      final result = await db.rawQuery("SELECT userid FROM user");
      return result.isEmpty ? 'null' : result.first["userid"].toString();
    } catch (e) {
      Logger().e(e);
      return 'null';
    }
  }

  Future<int?> insertOut(OutModel out) async {
    try {
      final database = await this.database;
      return await database.insert('out', {
        'recordid': out.recordId,
        'createdat': out.createdAt,
        'inventory_group': out.inventoryGroup,
        'location': out.location,
        'delivery_date': out.deliveryDate,
        'total_item': out.totalItem,
        'item': out.item,
        'detail': out.detail,
        'doctype': out.docType,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      Logger().e("insertOut error: $e");
      return null;
    }
  }
}
