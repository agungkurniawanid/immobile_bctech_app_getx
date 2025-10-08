import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:immobile/config/config.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:immobile/model/outmodel.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;

class StockrequestVM extends GetxController {
  GlobalVM globalvm = Get.find();
  Config config = Config();
  var tolistsrbackup = List<OutModel>().obs;
  var tolistsrout = List<OutModel>().obs;
  var tolistsrapprove = List<OutModel>().obs;

  Rx<List<OutModel>> srlist = Rx<List<OutModel>>([]);
  Rx<bool> srbutton = Rx<bool>(false);
  List<OutModel> outmodellocal = [];
  List<OutModel> outmodellocalout = [];
  List<OutModel> originalsrout = [];
  List<OutModel> listsrapprove = [];
  OutModel modellocal;
  String samecode = "";
  String total_item = "";
  String uom = "";
  String validationdocumentno = "";
  bool validationbuttonrefresh = false;
  // String username;
  String replyfromserver;
  ValueNotifier<bool> forbutton = ValueNotifier(false);

  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  // String choicedate = "";
  var choicesr = "".obs;
  var isapprove = false.obs;
  var lastdate = DateTime.now().obs;
  var isLoadingPDF = true.obs;
  var isSearch = true.obs;
  var isIconSearchint = 0.obs;
  var isIconSearch = true.obs;
  dynamic pdfFile = Rx<dynamic>();
  dynamic pdfBytes = Rx<dynamic>();
  var pdfDir = ''.obs;
  var tutorialRecent = true.obs;
  String name = "";

  @override
  void onReady() {
    srlist.bindStream(listSR());
    // srlist.bindStream(listSRWithRefresh(Duration(seconds: 10)));
  }

  @override
  void onButton() {
    srbutton.bindStream(validationForButton());
    // srlist.bindStream(listSRWithRefresh(Duration(seconds: 10)));
  }

  // Future<String> forbutton() async {
  //   String result = await validationforbutton();
  //   String url = result;
  //   return url;
  // }

  // Stream<List<OutModel>> listSRWithRefresh(Duration refreshDuration) {
  //   isLoading.value = true;
  //   StreamController<List<OutModel>> streamController;

  //   void fetchData() async {
  //     Stopwatch stopwatch = Stopwatch()..start(); // Start a stopwatch

  //     try {
  //       var h1 = DateTime.now().subtract(Duration(days: 1));
  //       String h1string = DateFormat('yyyy-MM-dd').format(h1);

  //       var querySnapshot = await FirebaseFirestore.instance
  //           .collection('SR')
  //           .where('createdat', isGreaterThanOrEqualTo: h1string)
  //           .get();

  //       outmodellocalout = [];
  //       originalsrout = [];
  //       samecode = "";
  //       total_item = "";
  //       uom = "";
  //       tolistsrout.clear();

  //       for (var doc in querySnapshot.docs) {
  //         var test = doc.data()["doctype"];
  //         print(test);
  //         final returnsr = OutModel.fromDocumentSnapshot(documentSnapshot: doc);
  //         if (returnsr.detail.any((element) => element.updatedat != "")) {
  //           returnsr.flag = "Y";
  //         } else {
  //           returnsr.flag = "";
  //         }

  //         if (returnsr.isapprove == "Y") {
  //           // Handle 'Y' case if needed
  //         } else {
  //           originalsrout.add(returnsr);
  //           outmodellocalout.add(returnsr);
  //         }
  //       }

  //       if (GlobalVar.choicecategory == "ALL") {
  //         outmodellocalout.sort((a, b) => b.flag.compareTo(a.flag));
  //         tolistsrout.assignAll(outmodellocalout);
  //       } else {
  //         try {
  //           var validation = outmodellocalout.where((element) =>
  //               element.detail != null &&
  //               element.detail.any((detail) =>
  //                   detail.isapprove == "N" &&
  //                   detail.inventory_group.contains(GlobalVar.choicecategory)));
  //           tolistsrout.assignAll(validation);
  //         } catch (e) {
  //           print(e);
  //         }
  //       }

  //       originalsrout.sort((a, b) => b.flag.compareTo(a.flag));
  //       tolistsrbackup.assignAll(originalsrout);

  //       isLoading.value = false;
  //       streamController.add(tolistsrbackup);

  //       // Stop the stopwatch and print the elapsed time
  //       stopwatch.stop();
  //       print("Elapsed time: ${stopwatch.elapsedMilliseconds} ms");
  //     } catch (e) {
  //       isLoading.value = false;
  //       print(e);
  //     }
  //   }

  //   // Start by fetching the data immediately
  //   fetchData();

  //   // Set up a periodic timer to fetch data every 'refreshDuration' period
  //   Timer.periodic(refreshDuration, (_) {
  //     fetchData();
  //   });

  //   streamController = StreamController<List<OutModel>>();

  //   return streamController.stream;
  // }

  dynamic approveSR(OutModel outmodel, String group) async {
    final Xml2Json xmlToJson = Xml2Json();
    try {
      RequestWorkflow data = RequestWorkflow();
      data.documentno = outmodel.documentno;
      data.group = group;
      // EasyLoading.showProgress(0.3,
      //     status: 'Call WS', maskType: EasyLoadingMaskType.black);
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('postsrtosap')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(toJsonApproveSR(data)));
      // print(toJsonApprove(data));

      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();
      replyfromserver = reply;
      // EasyLoading.showProgress(0.5,
      //     status: 'Return WS', maskType: EasyLoadingMaskType.black);
      switch (response.statusCode) {
        case 200: // BERHASIL
          if (reply.isNotEmpty) {
          } else {
            return "Failed" + reply;
          }
          return true;
        case 400:
          return "Failed" + reply;
        case 401:
          return "Failed" + reply;
        case 403:
          return "Failed" + reply;
        case 504:
          return "Failed" + reply;
        case 500:
          return "Failed" + reply;
        default:
          return "Failed" + reply;
      }
      // if (reply == "dvcid not valid") {
      //   return "dvcid not valid";
      // }
      // if (response.statusCode == 504) {
      //   return "Approval Gagal";
      // } else {

    } on TimeoutException catch (e) {
      print(e);
      return "Failed" + replyfromserver;
    } catch (e) {
      print(e);
      if (replyfromserver != null) {
        return "Failed" + replyfromserver;
      } else {
        return "Failed";
      }
    }
  }

  approveout(OutModel outmodel, List<Map<String, dynamic>> tdata) async {
    try {
      forcollection();
      await FirebaseFirestore.instance
          .collection(name)
          .doc(outmodel.documentno)
          .update({
        // 'clientid': outmodel.clientid,
        // 'created': outmodel.created,
        // 'createdat': outmodel.createdat,
        // 'createdby': outmodel.createdby,
        // 'delivery_date': outmodel.delivery_date,
        'details': tdata,
        // 'doctype': outmodel.doctype,
        // 'documentno': outmodel.documentno,
        // 'grouped_items': outmodel.item,
        // 'inventory_group': outmodel.inventory_group,
        // 'isapprove': outmodel.isapprove,
        // 'location': outmodel.location,
        // 'location_name': outmodel.location_name,
        // 'orgid': outmodel.orgid,
        // 'recordid': outmodel.recordid,
        'sync': outmodel.issync,
        // 'total_item': outmodel.total_item,
        // 'total_quantities': outmodel.totalquantity,
        'updated': outmodel.updated,
        'updatedby': globalvm.username.value,
      });
      return true;
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      return false;
    }
  }

  flagaftersendsap(OutModel outmodel) async {
    try {
      forcollection();
      await FirebaseFirestore.instance
          .collection(name)
          .doc(outmodel.documentno)
          .update({
        // 'clientid': outmodel.clientid,
        // 'created': outmodel.created,
        // 'createdat': outmodel.createdat,
        // 'createdby': outmodel.createdby,
        // 'delivery_date': outmodel.delivery_date,
        // 'details': tdata,
        // 'doctype': outmodel.doctype,
        // 'documentno': outmodel.documentno,
        // 'grouped_items': outmodel.item,
        // 'inventory_group': outmodel.inventory_group,
        'isapprove': outmodel.isapprove,
        // 'location': outmodel.location,
        // 'location_name': outmodel.location_name,
        // 'orgid': outmodel.orgid,
        // 'recordid': outmodel.recordid,
        'sync': outmodel.issync,
        // 'total_item': outmodel.total_item,
        // 'total_quantities': outmodel.totalquantity,
        // 'updated': outmodel.updated,
        // 'updatedby': globalvm.username.value,
      });
      return true;
      // .then((result) => {print("Sukses")})
      // .catchError((err) => print('Error retrieving data: $err'));
    } catch (e) {
      return false;
    }
  }

  Future<void> sendtohistory(
    OutModel outmodel,
    List<Map<String, dynamic>> tdata,
    String group,
  ) async {
    try {
      var today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      String todayString = DateFormat('yyyy-MM-dd').format(today);
      var username = await DatabaseHelper.db.getUser();

      // Reference to the collection (no specific document ID)
      final CollectionReference historyCollection = FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(group)
          .collection(todayString);

      final Map<String, dynamic> historyData = {
        'clientid': outmodel.clientid,
        'created': outmodel.created,
        'createdat': outmodel.createdat,
        'createdby': outmodel.createdby,
        'delivery_date': outmodel.delivery_date,
        'details': tdata,
        'doctype': outmodel.doctype,
        'documentno': outmodel.documentno,
        'grouped_items': outmodel.item,
        'inventory_group': outmodel.inventory_group,
        'isapprove': outmodel.isapprove,
        'location': outmodel.location,
        'location_name': outmodel.location_name,
        'orgid': outmodel.orgid,
        'recordid': outmodel.recordid,
        'sync': outmodel.issync,
        'total_item': outmodel.total_item,
        'total_quantities': outmodel.totalquantity,
        'updated': outmodel.updated,
        'updatedby': globalvm.username.value,
      };

      // Add the data as a new document with a generated document ID
      await historyCollection.add(historyData);
    } catch (e) {
      print(e);
    }
  }

  // Stream<List<OutModel>> listSR() {
  //   isLoading.value = true;
  //   globalvm.username.value;
  //   var h1 = DateTime(
  //       DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  //   String h1string = DateFormat('yyyy-MM-dd').format(h1);
  //   var today =
  //       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  //   String todayString = DateFormat('yyyy-MM-dd').format(today);

  //   // Use a StreamController to manage the stream of OutModel
  //   final controller = StreamController<List<OutModel>>();

  //   try {
  //     // Create a query to listen to changes in the Firestore collection
  //     final query = FirebaseFirestore.instance
  //         .collection('SR')
  //         .where('createdat', isGreaterThanOrEqualTo: h1string)
  //         .snapshots();

  //     final subscription = query.listen((event) {
  //       outmodellocalout = [];
  //       originalsrout = [];
  //       samecode = "";
  //       total_item = "";
  //       uom = "";
  //       // tolistsrout.clear();

  //       for (var change in event.docChanges) {
  //         switch (change.type) {
  //           case DocumentChangeType.added:
  //             var sr = change.doc;
  //             var test = sr.data()["doctype"];
  //             print(test);
  //             final returnsr =
  //                 OutModel.fromDocumentSnapshot(documentSnapshot: sr);

  //             if (returnsr.detail.any((element) => element.updatedat != "")) {
  //               returnsr.flag = "Y";
  //             } else {
  //               returnsr.flag = "";
  //             }

  //             if (returnsr.isapprove == "Y") {
  //               // Handle 'added' for isapprove "Y" if needed
  //             } else {
  //               originalsrout.add(returnsr);
  //               outmodellocalout.add(returnsr);
  //             }
  //             break;

  //           case DocumentChangeType.modified:
  //             var sr = change.doc;
  //             var test = sr.data()["doctype"];
  //             print(test);
  //             final returnsr =
  //                 OutModel.fromDocumentSnapshot(documentSnapshot: sr);

  //             int index = tolistsrout.indexWhere(
  //                 (element) => element.documentno == returnsr.documentno);
  //             if (index != -1) {
  //               originalsrout[index] = returnsr;
  //             }

  //             break;

  //           case DocumentChangeType.removed:
  //             var sr = change.doc;
  //             var test = sr.data()["doctype"];
  //             print(test);
  //             final returnsr =
  //                 OutModel.fromDocumentSnapshot(documentSnapshot: sr);

  //             // Handle removal here
  //             // Remove the document from your data

  //             tolistsrout.removeWhere(
  //                 (element) => element.documentno == returnsr.documentno);
  //             break;
  //         }
  //       }

  //       if (GlobalVar.choicecategory == "ALL") {
  //         outmodellocalout.sort((a, b) => b.flag.compareTo(a.flag));
  //         for (int i = 0; i < tolistsrout.length - 1; i++) {
  //           outmodellocalout.removeWhere(
  //               (element) => element.documentno == tolistsrout[i].documentno);
  //         }
  //         tolistsrout.assignAll(outmodellocalout);
  //       } else {
  //         try {
  //           var validation = outmodellocalout
  //               .where((element) =>
  //                   element.detail != null &&
  //                   element.detail.any((detail) =>
  //                       detail.isapprove == "N" &&
  //                       detail.inventory_group
  //                           .contains(GlobalVar.choicecategory)))
  //               .toList();
  //           tolistsrout.assignAll(validation);
  //         } catch (e) {
  //           print(e);
  //         }
  //       }

  //       originalsrout.sort((a, b) => b.flag.compareTo(a.flag));
  //       tolistsrbackup.assignAll(originalsrout);

  //       controller.add(tolistsrbackup);
  //       isLoading.value = false;
  //     });

  //     return controller.stream;
  //   } catch (e) {
  //     isLoading.value = false;
  //     print(e);
  //     return Stream.value([]); // Return an empty stream in case of an error
  //   }
  // }

  Future<String> forcollectionname() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('validation')
        .doc('collectionsr')
        .get();

    // Check if the document exists and contains data
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      // Use the [] operator to access a specific field in the document
      String url = documentSnapshot.data()[
          'name']; // Replace 'fieldName' with the actual field name you want to retrieve

      return url;
    } else {
      // Handle the case where the document doesn't exist or is empty
      return 'rpos_sr'; // or throw an exception, return a default value, etc.
    }
  }

  void forcollection() async {
    String result = await forcollectionname();
    name = result;
  }

  Stream<bool> validationForButton() {
    return FirebaseFirestore.instance
        .collection('validation')
        .doc('buttonrefreshout')
        .snapshots()
        .map((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        forbutton.value = documentSnapshot.data()['name'];
        return forbutton.value;
      } else {
        return false;
      }
    });
  }

  Stream<List<OutModel>> listSR() {
    var h1 = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
    String h1string = DateFormat('yyyy-MM-dd').format(h1);
    var today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    String todayString = DateFormat('yyyy-MM-dd').format(today);
    // String name = forcollection();
    forcollection();
    try {
      return FirebaseFirestore.instance
          .collection(name)
          .where('createdat', isGreaterThanOrEqualTo: h1string)
          .snapshots()
          .map((QuerySnapshot query) {
        isLoading.value = true;
        outmodellocalout = [];
        originalsrout = [];
        samecode = "";
        total_item = "";
        uom = "";
        // tolistsrout.value = [];
        for (var sr in query.docs) {
          var test = sr.data()["doctype"];
          final returnsr = OutModel.fromDocumentSnapshot(documentSnapshot: sr);
          if (returnsr.detail.any((element) => element.updatedat != "")) {
            returnsr.flag = "Y";
          } else {
            returnsr.flag = "";
          }
          if (returnsr.isapprove == "Y") {
          } else {
            if (tolistsrout.value != 0 &&
                validationdocumentno == returnsr.documentno) {
            } else {
              originalsrout.add(returnsr);
              outmodellocalout.add(returnsr);
            }
          }
        }
        if (tolistsrout.value != 0) {
          var list = tolistsrout.value
              .where((element) => element.documentno != validationdocumentno)
              .toList();
          for (int i = 0; i < list.length; i++) {
            tolistsrout.value.removeWhere(
                (element) => element.documentno == list[i].documentno);
          }
        }

        if (GlobalVar.choicecategory == "ALL") {
          outmodellocalout.sort((a, b) => b.flag.compareTo(a.flag));
          for (int i = 0; i < outmodellocalout.length; i++) {
            tolistsrout.add(outmodellocalout[i]);
          }
        } else {
          try {
            var validation = outmodellocalout
                .where((element) =>
                    element.detail != null &&
                    element.detail.any((detail) =>
                        detail.isapprove == "N" &&
                        detail.inventory_group
                            .contains(GlobalVar.choicecategory)))
                .toList();
            for (int i = 0; i < validation.length; i++) {
              tolistsrout.add(validation[i]);
            }
            // tolistsrout.assignAll(validation);
          } catch (e) {
            print(e);
          }
        }
        originalsrout.sort((a, b) => b.flag.compareTo(a.flag));
        tolistsrbackup.assignAll(originalsrout);
        isLoading.value = false;
        return tolistsrbackup;
      });
    } catch (e, stackTrace) {
      print("Error in listSR: $e");
      print("Stack Trace: $stackTrace");
      print(e);
    }
  }

  Stream<List<OutModel>> history() {
    // getname();
    var h1 = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
    String h1string = DateFormat('yyyy-MM-dd').format(h1);
    var today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    String todayString = DateFormat('yyyy-MM-dd').format(today);
    try {
      return FirebaseFirestore.instance
          .collection('SR')
          // .where("isapprove", isEqualTo: "N")
          .where('createdat', isGreaterThanOrEqualTo: h1string)
          // .where('createdat', isLessThanOrEqualTo: todayString)
          // .where('isapprove', isEqualTo: "N")
          // .limit(1)
          .snapshots()
          .map((QuerySnapshot query) {
        samecode = "";
        total_item = "";
        listsrapprove = [];
        tolistsrapprove.value = [];
        // tolistsrapprove.value = [];
        uom = "";
        for (var sr in query.docs) {
          print(sr);
          final returnsr = OutModel.fromDocumentSnapshot(documentSnapshot: sr);
          // if (returnsr.isapprove == "Y") {
          // } else {
          if (returnsr.isapprove == "Y") {
            listsrapprove.add(returnsr);
          } else {
            listsrapprove.add(returnsr);
          }

          // }
        }

        var listsrbyusername = listsrapprove
            .where((element) => element.detail.any(
                (element) => element.approvename == globalvm.username.value))
            .toList();
        var listsrapproveall = listsrapprove
            .where((element) => element.updatedby == globalvm.username.value)
            .toList();
        if (listsrbyusername.length > 0) {
          for (var sr in listsrbyusername) {
            tolistsrapprove.value.add(sr);
          }
        }
        if (listsrapproveall.length > 0) {
          for (var sr2 in listsrapproveall) {
            tolistsrapprove.value.add(sr2);
          }
        }

        // isLoading.value = false;
        return tolistsrbackup;
      });
    } catch (e) {
      print(e);
    }
  }

  dynamic getstockrequest() async {
    try {
      RequestWorkflow data = RequestWorkflow();
      List<dynamic> emptyArray = [];
      String emptyArrayJson = jsonEncode(emptyArray);

      // data.userid = userid;
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

      HttpClientRequest request = await client
          .postUrl(Uri.parse(await config.url('getstockrequest')))
          .timeout(Duration(seconds: 90));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Authorization', config.apiKey);
      request.add(utf8.encode(emptyArrayJson));
      //print(toJsonInsertTrip(data));
      HttpClientResponse response = await request.close();
      var reply = await response.transform(utf8.decoder).join();

      switch (response.statusCode) {
        case 200:
          if (reply.isNotEmpty) {
            onReady();
            // print(reply);
            // var list = json.decode(reply) as List;
            // List<OutModel> resList =
            //     list.map((i) => OutModel.toJsonDetail(i)).toList();

            // for (int i = 0; i < resList.length; i++) {
            //   print(i);
            //   await DatabaseHelper.db.insertOut(resList[i]);
            // }
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
          // List<Category> resList = [];
          return true;

        case 400:
          return false;
        case 401:
          // List<Category> resList = [];
          return false;
        case 403:
          // List<Category> resList = [];
          return false;
        case 500:
        default:
          // List<Category> resList = [];
          return false;
      }
    } on TimeoutException catch (e) {
      // print(e);
      return false;
    } catch (e) {
      // print(e);
      return false;
    }
  }
}
