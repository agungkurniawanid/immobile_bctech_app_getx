import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/config/config.dart';
import 'package:immobile_app_fixed/config/database_config.dart';
import 'package:immobile_app_fixed/models/category_model.dart';
import 'package:immobile_app_fixed/models/request_model.dart';
import 'package:logger/logger.dart';

class CategoryVM extends GetxController {
  Config config = Config();
  var tolistCategory = <Category>[].obs;
  var isLoading = true.obs;

  // Stream untuk mendapatkan data category dari Firestore (jika masih diperlukan)
  // Stream<List<Category>> listModel() {
  //   return FirebaseFirestore.instance
  //       .collection('sppa')
  //       .doc(userController.user.value.email)
  //       .collection('sppalist')
  //       .snapshots()
  //       .map((QuerySnapshot query) {
  //     List<Category> categorylocal = [];
  //     for (var category in query.docs) {
  //       final returncategory = Category.fromDocumentSnapshot(documentSnapshot: category);
  //       categorylocal.add(returncategory);
  //     }
  //     tolistCategory.value = categorylocal;
  //     isLoading.value = false;
  //     return categorylocal;
  //   });
  // }

  Future<dynamic> getcategory(int userid, String role) async {
    try {
      isLoading.value = true;

      final data = RequestWorkflow()
        ..userid = userid
        ..role = role;

      final client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

      final String url = await config.url('getinventorygroup');
      final request = await client
          .postUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 90));

      request.headers
        ..set('content-type', 'application/json')
        ..set('Authorization', config.apiKey);

      request.add(utf8.encode(toJsonCategory(data)));

      final response = await request.close();
      final reply = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200 && reply.isNotEmpty) {
        final list = json.decode(reply) as List;
        final List<Category> resList = list
            .map((i) => Category.fromJson(i))
            .toList();

        // Clear old categories first
        await DatabaseHelper.db.clearCategories();

        // Insert new categories
        for (final category in resList) {
          await DatabaseHelper.db.insertCategory(category.toJson());
        }

        // Update reactive variable
        tolistCategory.value = resList;
        return resList;
      } else {
        Logger().w("Server returned ${response.statusCode}");
        return <Category>[];
      }
    } on TimeoutException catch (e) {
      Logger().e('Timeout: $e');
      return 'Koneksi error';
    } on SocketException catch (e) {
      Logger().e('Socket: $e');
      return 'Koneksi error';
    } on HttpException catch (e) {
      Logger().e('HTTP: $e');
      return 'Koneksi error';
    } catch (e) {
      Logger().e('General error: $e');
      return 'Koneksi error';
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Method untuk mendapatkan kategori dari database lokal
  Future<void> getCategoriesFromLocal() async {
    try {
      isLoading.value = true;
      List<Category> categories = await DatabaseHelper.db.getCategories();
      tolistCategory.value = categories;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk clear data
  void clearData() {
    tolistCategory.clear();
    isLoading.value = true;
  }
}

// Tambahkan method toJsonCategory jika belum ada di file lain
String toJsonCategory(RequestWorkflow data) {
  return json.encode({
    'userid': data.userid,
    'role': data.role,
    // tambahkan field lainnya sesuai kebutuhan
  });
}
