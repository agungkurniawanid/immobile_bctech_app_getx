import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:immobile/config/config.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CategoryVM extends GetxController {
  Config config = Config();
  var tolistCategory = List<Category>().obs;

  Rx<List<Category>> categoryList = Rx<List<Category>>([]);
  List<Category> categorylocal = [];
  var isLoading = true.obs;

  // Stream<List<Category>> listModel() {
  //   return FirebaseFirestore.instance
  //       .collection('sppa')
  //       .doc(userController.user.value.email)
  //       .collection('sppalist')
  //       .snapshots()
  //       .map((QuerySnapshot query) {
  //     categorylocal = [];
  //     for (var category in query.docs) {
  //       final returncategory =
  //           Category.fromDocumentSnapshot(documentSnapshot: category);

  //       // tolistSPPA.removeWhere((element) =>
  //       //     element.documentnosppa == sppa.data()['documentnosppa']);
  //       categorylocal.add(returncategory);
  //     }

  //     tolistCategory.value = categorylocal;
  //     isLoading.value = false;
  //     return tolistCategory;
  //   });
  // }

dynamic getcategory(int userid, String role) async {
  try {
    RequestWorkflow data = RequestWorkflow();

    data.userid = userid;
    data.role = role;
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    // Await the config.url() method to get the String URL value
    String url = await config.url('getinventorygroup');
    HttpClientRequest request = await client
        .postUrl(Uri.parse(url))
        .timeout(Duration(seconds: 90));

    request.headers.set('content-type', 'application/json');
    request.headers.set('Authorization', config.apiKey);
    request.add(utf8.encode(toJsonCategory(data)));

    HttpClientResponse response = await request.close();
    var reply = await response.transform(utf8.decoder).join();

    switch (response.statusCode) {
      case 200:
        if (reply.isNotEmpty) {
          print(reply);
          var list = json.decode(reply) as List;
          List<Category> resList =
              list.map((i) => Category.fromJson(i)).toList();

          for (int i = 0; i < resList.length; i++) {
            print(i);
            await DatabaseHelper.db.insertCategory(resList[i]);
          }
        }
        return []; // Return an empty list if no valid data

      case 400:
      case 401:
      case 403:
      case 500:
      default:
        return []; // Return an empty list for all error cases
    }
  } on TimeoutException catch (e) {
    print(e);
    return 'Koneksi error'; // Handle timeout exception
  } catch (e) {
    print(e);
    return 'Koneksi error'; // Handle other exceptions
  }
}
}
