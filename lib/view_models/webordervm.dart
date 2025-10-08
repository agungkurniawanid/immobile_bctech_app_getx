import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:immobile/config/config.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:immobile/model/outmodel.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WeborderVM extends GetxController {
  Config config = Config();
  var tolistWO = List<OutModel>().obs;
  var tolistwoout = List<OutModel>().obs;
  Rx<List<OutModel>> wolist = Rx<List<OutModel>>([]);
  List<OutModel> outmodellocal = [];
  List<OutModel> outmodellocalout = [];

  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  var lastdate = DateTime.now().obs;
  var isLoadingPDF = true.obs;
  var sortVal = "Location".obs;
  var sortValSR = "Request Date".obs;
  var isSearch = true.obs;
  var intlistwo = 0.obs;
  var isIconSearch = true.obs;
  dynamic pdfFile = Rx<dynamic>();
  dynamic pdfBytes = Rx<dynamic>();
  var pdfDir = ''.obs;
  var tutorialRecent = true.obs;
  var choiceWO = "".obs;
  var choiceout = "".obs;

  @override
  void onReady() {
    wolist.bindStream(listWO());
  }

  Stream<List<OutModel>> listWO() {
    try {
      tolistWO.value = [];
      tolistwoout.value = [];
      var h1 = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
      String h1string = DateFormat('yyyy-MM-dd').format(h1);
      return FirebaseFirestore.instance
          .collection('WO')
          .doc(GlobalVar.choicecategory)
          .collection('headerdetail')
          .where('delivery_date', isGreaterThanOrEqualTo: h1string)
          // .where('isapprove', isEqualTo: 'N')
          .snapshots()
          .map((QuerySnapshot query) {
        outmodellocal = [];
        outmodellocalout = [];
        for (var sppa in query.docs) {
          final returnsppa =
              OutModel.fromDocumentSnapshot(documentSnapshot: sppa);

          // tolistSPPA.removeWhere((element) =>
          //     element.documentnosppa == sppa.data()['documentnosppa']);
          if (outmodellocal.length != 10) {
            outmodellocal.add(returnsppa);
          }
          outmodellocalout.add(returnsppa);
        }
        tolistwoout.value = outmodellocalout;
        tolistWO.value = outmodellocal;
        intlistwo.value = tolistwoout.value.length;
        isLoading.value = false;
        return tolistwoout;
      });
    } catch (e) {
      print(e);
    }
  }

  dynamic getlistwo(int userid) async {
    try {
      RequestWorkflow data = RequestWorkflow();

      data.userid = userid;
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('getweborderheader')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonCategory(data)));
      //print(toJsonInsertTrip(data));
      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();

      switch (response.statusCode) {
        case 200:
          if (reply.isNotEmpty) {
            print(reply);
            var list = json.decode(reply) as List;
            List<OutModel> resList =
                list.map((i) => OutModel.toJsonDetail(i)).toList();

            for (int i = 0; i < resList.length; i++) {
              print(i);
              await DatabaseHelper.db.insertOut(resList[i]);
            }
            // var jsonData = Category.fromJson(jsonDecode(reply));
            // // print(jsonDecode(response.body));

            // await DatabaseHelper.db.insertCategory(jsonData);
            // bool user = await fetchUserId(jsonData, token);
            // if (user) {
            //   GlobalVar.email = email;
            // } else {
            //   return 'NO USER';
            // }
          }
          List<Category> resList = [];
          return resList;

        case 400:
          List<Category> resList = [];
          return resList;
        case 401:
          List<Category> resList = [];
          return resList;
        case 403:
          List<Category> resList = [];
          return resList;
        case 500:
        default:
          List<Category> resList = [];
          return resList;
      }
    } on TimeoutException catch (e) {
      print(e);
      return 'Koneksi error';
    } catch (e) {
      print(e);
      return 'Koneksi error';
    }
  }
}
