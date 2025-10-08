import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:immobile/config/config.dart';
import 'package:immobile/model/inputstocktake.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:immobile/model/stocktake.dart';
import 'package:immobile/model/stocktakedetail.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/rolevm.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

class StockTickVM extends GetxController {
  Config config = Config();
  var selectchoice = "UU".obs;
  var stocktickvm = [].obs; // Example for reactive data; replace with actual type
  var documentno = "".obs;
  var tolistforscan = List<StocktickModel>().obs;
  var tolistforinputstocktake = List<InputStockTake>().obs;
   var tolistcounted = List<InputStockTake>().obs;
    var tolistinput = List<InputStockTake>().obs;
  var toliststock = List<StocktickModel>().obs;
  var tolistdocument = List<StocktickModel>().obs;
  var tolistdocumentnosame = List<StocktickModel>().obs;
    var tolistdocumentsearch= List<StocktickModel>().obs;
  var tolistdocumentcounted = List<StocktickModel>().obs;
  var tolistdetail = List<StocktickModel>().obs;
  var stockhistory = List<StocktickModel>().obs;
  var searchValue = ''.obs;
List<String> choicelocation = [];
  Rx<List<StocktickModel>> stocklist = Rx<List<StocktickModel>>([]);
  List<StocktickModel> StocktickModellocal = [];
  List<InputStockTake> listinputstocktake = [];
   List<InputStockTake> listcountedstocktake = [];
  List<StocktickModel> StocktickModellocalout = [];
  List<StocktickModel> stockforhistory = [];
  GlobalVM globalvm = Get.find();
    Rolevm rolevm = Get.find();
  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  var choicesr = "".obs;
  var document = "".obs;
  // var validationheader = "".obs;
  var lastdate = DateTime.now().obs;
  var isLoadingPDF = true.obs;
  var isSearch = true.obs;
  var isIconSearchint = 0.obs;
  var isIconSearch = true.obs;
  dynamic pdfFile = Rx<dynamic>();
  dynamic pdfBytes = Rx<dynamic>();
  var pdfDir = ''.obs;
  var tutorialRecent = true.obs;
  String choiceforchip;

  @override
  void onReady() async {
    // stocklist.bindStream(listcounted());
    stocklist.bindStream(listDocumentStream());
    stocklist.bindStream(listDetailAll());
  
    // stocklist.bindStream(listDetail());
  }

  @override
  void forDetail() async {
    stocklist.bindStream(listDetail());
  }

  @override
  void forDetailAll() async {
    stocklist.bindStream(listDetailAll());
  }

Future<List<StocktickModel>> listcounted() async {
  try {
    // Fetch documents matching the query from Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('history_stocktake')
        .where('documentno', isEqualTo: document.value)
        .get();

    // Check if there are any documents returned
    if (querySnapshot.docs.isNotEmpty) {
      StocktickModellocal = [];
      StocktickModellocalout = [];
      listcountedstocktake = [];

      // Loop through the documents and process each one
      for (var doc in querySnapshot.docs) {
        final returnstock = InputStockTake.fromDocumentSnapshot(documentSnapshot: doc);
        listcountedstocktake.add(returnstock);

        // Additional processing if needed
        // if (returnstock.isapprove == "N") {
        //   StocktickModellocal.add(returnstock);
        //   StocktickModellocalout.add(returnstock);
        // } else {
        //   // Additional processing if needed
        // }
      }

      tolistcounted.assignAll(listcountedstocktake);
      isLoading.value = false;
    } else {
      print("Document does not exist.");
      return [];
    }
  } catch (e) {
    print(e);
    // Handle the error as needed
    return [];
  }
}


  Stream<List<StocktickModel>> listDetailAll() {
    try {
      return FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(document.value)
          .collection('batchid')
          // .where('createdby', isEqualTo: globalvm.username.value)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        StocktickModellocal = [];
        StocktickModellocalout = [];
        stockforhistory = [];
        tolistforscan.value = [];
        listinputstocktake = [];
        // tolistdocument.value = [];
        tolistdetail.value = [];

        querySnapshot.docs.forEach((stock) {
          final returnstock =
              InputStockTake.fromDocumentSnapshot(documentSnapshot: stock);
          listinputstocktake.add(returnstock);
          // if (returnstock.isapprove == "N") {
          //   StocktickModellocal.add(returnstock);
          //   StocktickModellocalout.add(returnstock);
          // } else {
          //   // Additional processing if needed
          // }

          // Additional processing if needed
        });

        tolistforinputstocktake..assignAll(listinputstocktake);
        isLoading.value = false;

        return toliststock;
      });
    } catch (e) {
      print(e);
      // Handle the error as needed
      return Stream.value([]);
    }
  }

  Stream<List<StocktickModel>> listDetail() {
    try {
      return FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(document.value)
          .collection('batchid')
          // .where('createdby', isEqualTo: globalvm.username.value)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        StocktickModellocal = [];
        StocktickModellocalout = [];
        stockforhistory = [];
        tolistforscan.value = [];
        listinputstocktake = [];
        // tolistdocument.value = [];
        tolistdetail.value = [];

        querySnapshot.docs.forEach((stock) {
          final returnstock =
              InputStockTake.fromDocumentSnapshot(documentSnapshot: stock);
          listinputstocktake.add(returnstock);
          // if (returnstock.isapprove == "N") {
          //   StocktickModellocal.add(returnstock);
          //   StocktickModellocalout.add(returnstock);
          // } else {
          //   // Additional processing if needed
          // }

          // Additional processing if needed
        });

        tolistforinputstocktake..assignAll(listinputstocktake);
        isLoading.value = false;

        return toliststock;
      });
    } catch (e) {
      print(e);
      // Handle the error as needed
      return Stream.value([]);
    }
  }

Stream<List<StocktickModel>> listDocumentStream() {
  try {
    String thisMonth = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1, 0));
    
    return FirebaseFirestore.instance
        .collection('stocktakes')
        .where('created', isGreaterThanOrEqualTo: thisMonth)
        .where('isapprove', isEqualTo: choiceforchip)
        .where('LGORT', arrayContainsAny: choicelocation) // Assuming choiceforchip is an array
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      StocktickModellocal = [];
      StocktickModellocalout = [];
      stockforhistory = [];
      tolistforscan.value = [];
      tolistdocument.value = [];
      tolistdetail.value = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (var stock in querySnapshot.docs) {
          final returnstock = StocktickModel.fromDocumentSnapshotDetail(documentSnapshot: stock);

          if (returnstock.isapprove == choiceforchip) {
            StocktickModellocalout.add(returnstock);

            List<StockTakeDetailModel> uniqueDetails = [];
            Set<String> uniqueMATNRs = Set<String>();

            for (var detail in returnstock.detail) {
              if (uniqueMATNRs.add(detail.MATNR)) {
                uniqueDetails.add(detail);
              }
            }

            StocktickModellocal.add(
              StocktickModel(documentno:returnstock.documentno ,detail: uniqueDetails),
            );
          }
        }
      }

      tolistdocumentnosame.assignAll(StocktickModellocal);
      tolistdocument.assignAll(StocktickModellocalout);
      isLoading.value = false;

      return toliststock;
    });
  } catch (e) {
    print(e);
    return Stream.value([]);
  }
}

// Future<List<StocktickModel>> listdocument() async {
//   try {
//     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('stocktakes')
//         .limit(5)
//         .get();

//     StocktickModellocal = [];
//     StocktickModellocalout = [];
//     stockforhistory = [];
//     tolistforscan.value = [];
//     tolistdocument.value = [];
//     tolistdetail.value = [];

//     for (var stock in querySnapshot.docs) {
//       final returnstock =
//           StocktickModel.fromDocumentSnapshot(documentSnapshot: stock);

//       if (returnstock.isapprove == "N") {
//         StocktickModellocal.add(returnstock);
//         StocktickModellocalout.add(returnstock);
//       } else {
//         // Additional processing if needed
//       }

//       // Additional processing if needed
//     }

//     tolistforscan.assignAll(StocktickModellocal);
//     tolistdocument..assignAll(StocktickModellocalout);
//     isLoading.value = false;

//     return toliststock;
//   } catch (e) {
//     print(e);
//     // Handle the error as needed
//     return [];
//   }
// }


  Future<List<StocktickModel>> listStock() async {
    try {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('sloc')
        .where('LGORT', arrayContainsAny: rolevm.role.stocktake) // Assuming LGORT is an array
        .get();

      StocktickModellocal = [];
      StocktickModellocalout = [];
      stockforhistory = [];
      tolistforscan.value = [];
      toliststock.value = [];
      tolistdetail.value = [];

      for (var stock in querySnapshot.docs) {
        final returnstock =
            StocktickModel.fromDocumentSnapshot(documentSnapshot: stock);

        if (returnstock.isapprove == "N") {
          StocktickModellocal.add(returnstock);
          StocktickModellocalout.add(returnstock);
        } else {
          // Additional processing if needed
        }

        // Additional processing if needed
      }

      tolistforscan.assignAll(StocktickModellocal);
      toliststock..assignAll(StocktickModellocalout);
      isLoading.value = false;

      return toliststock;
    } catch (e) {
      print(e);
      // Handle the error as needed
      return [];
    }
  }

  // Stream<List<StocktickModel>> listStock() {
  //   try {
  //     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //     return FirebaseFirestore.instance
  //         .collection('Product')
  //         // .doc("HQ")
  //         // .collection('header')
  //         .limit(5)
  //         .snapshots()
  //         .map((QuerySnapshot query) {
  //       StocktickModellocal = [];
  //       StocktickModellocalout = [];
  //       stockforhistory = [];
  //       tolistforscan.value = [];
  //       toliststock.value = [];
  //       tolistdetail.value = [];
  //       for (var stock in query.docs) {
  //         final returnstock =
  //             StocktickModel.fromDocumentSnapshot(documentSnapshot: stock);

  //         if (returnstock.isapprove == "N") {
  //           StocktickModellocal.add(returnstock);
  //           StocktickModellocalout.add(returnstock);
  //         } else {}

  //         // if(returnstock.detail.where((element) => element.approvename == username).toList().length > 0){
  //         //   stockfor
  //         // }

  //         // tolistSPPA.removeWhere((element) =>
  //         //     element.documentnosppa == sppa.data()['documentnosppa']);

  //       }

  //       // for (var stock in StocktickModellocalout) {
  //       //   stock.detail.sort((a, b) => b.stock_total.compareTo(a.stock_total));
  //       // }
  //       // StocktickModellocalout.sort((a, b) => b.updated_at.compareTo(a.updated_at));
  //       tolistforscan.assignAll(StocktickModellocal);
  //       toliststock..assignAll(StocktickModellocalout);
  //       isLoading.value = false;
  //       return toliststock;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  createdocument(List<Map<String, dynamic>> detail) async {
    try {
      var today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      String todayString = DateFormat('yyyy').format(today);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('stocktakes')
          .where('validation', isEqualTo: todayString)
          .get();
      var totaldata = querySnapshot.size + 1;
      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc("ST" + todayString + totaldata.toString())
          .set({
        'validation': todayString,
        'documentno': "ST" + todayString + totaldata.toString(),
        'LGORT': "HQ",
        'updated': "",
        'updatedby': "",
        'created': formattedDate,
        'createdby': globalvm.username.value,
        'isapprove': "N",
        'doctype': "stocktake",
        'detail': detail,
      });
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }

    forcounted(InputStockTake stocktickModel2) async {
    try {
      // var today = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day);
      // String todayString = DateFormat('yyyy-MM-dd').format(today);
      // DateTime now = DateTime.now();
      // String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      // var username = await DatabaseHelper.db.getUser();
      await FirebaseFirestore.instance
          .collection('history_stocktake')
          .doc(stocktickModel2.documentno+stocktickModel2.batchid +
              stocktickModel2.matnr +
              stocktickModel2.section+globalvm.username.value+ stocktickModel2.selectedChoice)
          // .collection(globalvm.username.value)
          // .doc()
          .set({
        'matnr': stocktickModel2.matnr,
        'section': stocktickModel2.section,
        'count_box': stocktickModel2.count_box,
        'count_bun': stocktickModel2.count_bun,
        'created': stocktickModel2.created,
        'createdby': stocktickModel2.createdby,
        'documentno': stocktickModel2.documentno,
        'batchid': stocktickModel2.batchid,
        'selectedChoice': stocktickModel2.selectedChoice,
                'unit_box': stocktickModel2.unit_box,
        'unit_bun': stocktickModel2.unit_bun,
         'plant': stocktickModel2.plant,
        'sloc': stocktickModel2.sloc,
        'DOWNLOADTIME' : stocktickModel2.DOWNLOADTIME,
          //  'SAP_STOCK_BOX' : stocktickModel2.SAP_STOCK_BOX,
        'SAP_STOCK_BUN' : stocktickModel2.SAP_STOCK_BUN,
        'istick' : stocktickModel2.istick
      });
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }


  sendtohistory(InputStockTake stocktickModel2) async {
    try {
      // var today = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day);
      // String todayString = DateFormat('yyyy-MM-dd').format(today);
      // DateTime now = DateTime.now();
      // String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      // var username = await DatabaseHelper.db.getUser();
      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(stocktickModel2.documentno)
          .collection('batchid')
          .doc(stocktickModel2.batchid +
              stocktickModel2.matnr +
              stocktickModel2.section + stocktickModel2.selectedChoice)
          .set({
        'matnr': stocktickModel2.matnr,
        'section': stocktickModel2.section,
        'count_box': stocktickModel2.count_box,
        'count_bun': stocktickModel2.count_bun,
        'created': stocktickModel2.created,
        'createdby': stocktickModel2.createdby,
        'documentno': stocktickModel2.documentno,
        'batchid': stocktickModel2.batchid,
        'selectedChoice': stocktickModel2.selectedChoice,
        'unit_box': stocktickModel2.unit_box,
        'unit_bun': stocktickModel2.unit_bun,
        'plant': stocktickModel2.plant,
        'sloc': stocktickModel2.sloc,
        // 'SAP_STOCK_BOX' : stocktickModel2.SAP_STOCK_BOX,
        'DOWNLOADTIME' : stocktickModel2.DOWNLOADTIME,
        'SAP_STOCK_BUN' : stocktickModel2.SAP_STOCK_BUN,
        'istick' : stocktickModel2.istick
      });
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }

   updatedetailtick(String documentno,List<StockTakeDetailModel> indetail) async {
    try {
       List<Map<String, dynamic>> detailList = indetail.map((detail) => detail.toMap()).toList();
      // var today = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day);
      // String todayString = DateFormat('yyyy-MM-dd').format(today);
      // DateTime now = DateTime.now();
      // String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      // var username = await DatabaseHelper.db.getUser();
      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(documentno)
         
          .update({
        'detail': detailList
      });
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }


 updatedetail(InputStockTake stocktickModel2,List<StockTakeDetailModel> indetail) async {
    try {
       List<Map<String, dynamic>> detailList = indetail.map((detail) => detail.toMap()).toList();
      // var today = DateTime(
      //     DateTime.now().year, DateTime.now().month, DateTime.now().day);
      // String todayString = DateFormat('yyyy-MM-dd').format(today);
      // DateTime now = DateTime.now();
      // String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      // var username = await DatabaseHelper.db.getUser();
      await FirebaseFirestore.instance
          .collection('stocktakes')
          .doc(stocktickModel2.documentno)
         
          .update({
        'detail': detailList
      });
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      print(e);
    }
  }


  dynamic getStock(String lgort, String werks, String username) async {
    final Xml2Json xmlToJson = Xml2Json();
    try {
      RequestWorkflow data = RequestWorkflow();
      data.documentno = lgort;
      data.group = werks;
      data.username = username;

        EasyLoading.show(
                              status: 'Getting Stock',
                              maskType: EasyLoadingMaskType.black);

      // EasyLoading.showProgress(0.3,
      //     status: 'Getting Stock...', maskType: EasyLoadingMaskType.black);
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('createdocument_stocktake')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonRefreshStock(data)));
      // print(toJsonApprove(data));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      // EasyLoading.showProgress(0.5,
      //     status: 'Return WS', maskType: EasyLoadingMaskType.black);
      switch (response.statusCode) {
        case 200: // BERHASIL
          EasyLoading.dismiss();
          if (reply.isNotEmpty) {
            List<StockTakeDetailModel> resList = [];
            // var list = json.decode(reply) as List;
            // List<StockTakeDetailModel> resList =
            //     list.map((i) => StockTakeDetailModel.fromJson(i)).toList();
            return resList;
          } else {
            return false;
          }
          return true;
        case 400:
          return "Approval Gagal Error 400";
        case 401:
          return "Approval Gagal Error 401";
        case 403:
          return "Approval Gagal Error 403";
        case 504:
          return "Approval Gagal Error 504";
        case 500:
          return "Approval Gagal Error 500";
        default:
          return "Approval Gagal";
      }
      // if (reply == "dvcid not valid") {
      //   return "dvcid not valid";
      // }
      // if (response.statusCode == 504) {
      //   return "Approval Gagal";
      // } else {

    } on TimeoutException catch (e) {
      EasyLoading.dismiss();
      print(e);
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      return false;
    }
  }

Future<dynamic> sendemail(String documentno) async {
  try {
    EasyLoading.showProgress(0.3,
        status: 'Mempersiapkan request', maskType: EasyLoadingMaskType.black);

    // Ambil URL dari Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('urlsendemail')
        .get();

    if (!doc.exists || !doc.data().toString().contains('value')) {
      EasyLoading.dismiss();
      return "URL tidak ditemukan di Firestore";
    }

    final String url = doc.get('value');

    // Inisialisasi data
    RequestWorkflow data = RequestWorkflow();
    data.documentno = documentno;

    // Siapkan client
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    // Buat request
    HttpClientRequest request = await client
        .postUrl(Uri.parse(url+'send-email-stocktake'))
        .timeout(Duration(seconds: 5));

    // Set headers (HARUS dilakukan sebelum add)
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader,
        'Bearer a76d16bdd5c5043f6f93f3e6c59bd35a');

    // Tambahkan body setelah headers
    request.add(utf8.encode(toJsonEmail(data)));

    // Kirim dan terima response
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();

    EasyLoading.showProgress(0.5,
        status: 'Menerima respon', maskType: EasyLoadingMaskType.black);

    switch (response.statusCode) {
      case 200:
        EasyLoading.dismiss();
        return reply.isNotEmpty ? reply : false;

      case 400:
        return "Request Gagal Error 400";

      case 401:
        return "Request Gagal Error 401";

      default:
        return "Request Gagal Error ${response.statusCode}";
    }
  } on TimeoutException catch (e) {
    EasyLoading.dismiss();
    print("Timeout Exception: $e");
    return "Request Timeout";
  } catch (e) {
    EasyLoading.dismiss();
    print("Exception: $e");
    return false;
  }
}

 dynamic producekafka(Map<String, dynamic> payload) async {
  try {
    EasyLoading.showProgress(0.3,
        status: 'Call WS', maskType: EasyLoadingMaskType.black);

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
var testing = Uri.parse(await config.urlkafka('produce'));
    // Membuat request ke server
    HttpClientRequest request = await client
        .postUrl(Uri.parse(await config.urlkafka('produce')))
        .timeout(Duration(seconds: 2));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer a76d16bdd5c5043f6f93f3e6c59bd35a'); // Menambahkan Bearer token

    // Menambahkan payload ke body request
    request.add(utf8.encode(jsonEncode(payload)));

    // Mendapatkan response dari server
    HttpClientResponse response = await request.close();
    var reply = await response.transform(utf8.decoder).join();

    EasyLoading.showProgress(0.5,
        status: 'Return WS', maskType: EasyLoadingMaskType.black);

      switch (response.statusCode) {
        case 200: 
         EasyLoading.dismiss();
        if (reply.isNotEmpty) {
          return reply; // Mengembalikan response server
        } else {
          return false; // Response kosong
        }
    // Ensure there is no further flow after return
          break;

        case 400:
        return "Request Gagal Error 400";

          break;

        case 401:
            return "Request Gagal Error 401";

          break;

        default:
           return "Request Gagal Error 404";
          break;
      }


  } on TimeoutException catch (e) {
    EasyLoading.dismiss();
    print("Timeout Exception: $e");
    return "Request Timeout";
  } catch (e) {
    EasyLoading.dismiss();
    print("Exception: $e");
    return false;
  }
}


  changeflag(
      StocktickModel StocktickModel, List<Map<String, dynamic>> detail) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('stocktakes')
        .doc(StocktickModel.documentno);
    documentReference.update({"detail": detail}).whenComplete(() async {
      print("Completed");
    }).catchError((e) => print(e));
  }

  approveall(StocktickModel StocktickModel) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('stocktakes')
        .doc(StocktickModel.documentno);
    documentReference.update({
      "isapprove": "Y",
      "updated": StocktickModel.updated,
      "updatedby": StocktickModel.updatedby
    }).whenComplete(() async {
      print("Completed");
    }).catchError((e) => print(e));
  }

  // approvestock(StocktickModel StocktickModel, List<Map<String, dynamic>> tdata) async {
  //   try {
  //     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //     await FirebaseFirestore.instance
  //         .collection('STOCK')
  //         .doc(today)
  //         .collection('header')
  //         .doc(StocktickModel.recordid)
  //         .set({
  //           'recordid': StocktickModel.recordid,
  //           'color': StocktickModel.color,
  //           'created': StocktickModel.created,
  //           'createdby': StocktickModel.createdby,
  //           'orgid': StocktickModel.orgid,
  //           'updated': today,
  //           'updatedby': StocktickModel.updatedby,
  //           'location': StocktickModel.location,
  //           'formatted_updated_at': StocktickModel.formatted_updated_at,
  //           'isapprove': StocktickModel.isapprove,
  //           'location_name': StocktickModel.location_name,
  //           'updated_at': StocktickModel.updated_at,
  //           'clientid': StocktickModel.clientid,
  //           'sync': StocktickModel.issync,
  //           'doctype': StocktickModel.doctype,
  //           'detail': tdata,
  //         })
  //         // return test;
  //         .then((result) => {print("Sukses")})
  //         .catchError((err) => print('Error retrieving data: $err'));
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  dateToString(String date) {
    final format = DateFormat('dd-MM-yyyy');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }
  List<StockTakeDetailModel> newListToDocument(String namechoice, String documentno) {
  // Validasi jika tolistdocument kosong
  if (tolistdocumentnosame.value.isEmpty) {
    return [];
  }

  // Validasi jika documentno tidak ditemukan
  final matchedDocs = tolistdocumentnosame.value.where((element) => element.documentno == documentno);
  if (matchedDocs.isEmpty) {
    return [];
  }

  // Ambil dokumen yang sesuai
  final selectedDoc = matchedDocs.first;

  // Jika ada search value
  if (searchValue.value != null && searchValue.value.trim().isNotEmpty) {
    return selectedDoc.detail
        .where((element) =>
            element.MAKTX.toLowerCase().contains(searchValue.value.toLowerCase()) ||
            element.NORMT.contains(searchValue.value) ||
            element.MATNR.contains(searchValue.value))
        .toSet()
        .toList();
  } else {
    // Tanpa search, filter berdasarkan kondisi
    return selectedDoc.detail
        // .where((element) => element.LABST != 0 && element.INSME != 0 && element.SPEME != 0)
        .toSet()
        .toList();
  }
}


  // List<StockTakeDetailModel> newListToDocument(String namechoice, int index) {
  //   //  List<StocktickModel> tempTick=[];
  //   // List<StockTakeDetailModel> temp=[];
  //   // List<String> tempValue = [];
  //   // for(var list in tolistdocument[index].detail){
  //   //   if(tempValue.contains(list.MATNR)){
  //   //     tempTick =

  //   //     tolistdocument[index].detail.where((element) => element.MATNR == list.MATNR).
  //   //   }else{
  //   //     tempValue.add(list.MATNR);
  //   //     temp.add(list);
  //   //   }
  //   // }
  //   return searchValue.value != '' || searchValue.value != null
  //           ? tolistdocumentnosame[index]
  //               .detail
  //               .where((element) =>
  //                   (element.MAKTX
  //                           .toLowerCase()
  //                           .contains(searchValue.value.toLowerCase()) || element.NORMT.contains(searchValue.value) ||
  //                       element.MATNR.contains(searchValue.value) ) )
  //               .toSet()
  //               .toList()
  //           : tolistdocumentnosame[index]
  //               .detail.where((element) => element.LABST != 0 && element.INSME != 0 && element.SPEME != 0)
  //               .toSet()
  //               .toList();
  // }

  StocktickModel newStockTickModel(String namechoice, int index) {
    return namechoice == "ALL"
        ? searchValue.value == ''
            ? tolistdocument[index]
            : tolistdocument[index]
        : searchValue.value != '' || searchValue.value != null
            ? tolistdocument[index]
            : tolistdocument[index];
  }
}
