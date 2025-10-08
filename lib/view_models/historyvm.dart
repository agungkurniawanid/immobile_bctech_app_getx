import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:immobile/config/config.dart';
import 'package:immobile/model/stockcheck.dart';
import 'package:immobile/model/history.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xml2json/xml2json.dart';
import 'package:immobile/model/requestmodel.dart';
import 'package:immobile/model/inmodel.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/model/category.dart';
import 'package:async/async.dart';

class HistoryVM extends GetxController {
  Config config = Config();
  var tolisthistory = List<HistoryModel>().obs;

  Rx<List<HistoryModel>> stocklist = Rx<List<HistoryModel>>([]);
  GlobalVM globalvm = Get.find();
  var isLoading = true.obs;
  var datetimenow = DateTime.now().obs;
  var firstdate = DateTime.now().obs;
  var choicedate = "".obs;
  var choice = "".obs;
  var lastdate = DateTime.now().obs;
  var isLoadingPDF = true.obs;
  var isSearch = true.obs;
  var isIconSearchint = 0.obs;
  var isIconSearch = true.obs;
  dynamic pdfFile = Rx<dynamic>();
  dynamic pdfBytes = Rx<dynamic>();
  var pdfDir = ''.obs;
  var tutorialRecent = true.obs;
  String username;
  List<Category> listcategory = [];
  List<Category> listforin = [];

  @override
  void onReady() {
    stocklist.bindStream(history());
  }

  @override
  void onReports() {
    stocklist.bindStream(reports());
  }

  Future<void> processStream2(List<Stream<QuerySnapshot>> streams) async {
    var combinedStream2 = StreamZip(streams);

    await for (var snapshots in combinedStream2) {
      List<HistoryModel> result = [];

      HistoryModel historymodellocal;

      for (var query in snapshots) {
        for (var doc in query.docs) {
          String doctype = doc.data()['doctype'];

          if (doctype == "IN") {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
            if (tolisthistory
                .any((element) => element.ebeln == historymodellocal.ebeln)) {
              tolisthistory.removeWhere(
                  (element) => element.ebeln == historymodellocal.ebeln);
            }
          } else if (doctype == "SR") {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            if (tolisthistory.any((element) =>
                element.documentno == historymodellocal.documentno)) {
              tolisthistory.removeWhere((element) =>
                  element.documentno == historymodellocal.documentno);
            }
          } else {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
          }
          result.add(historymodellocal);
        }
      }
      // result.sort((a, b) => b.updated.compareTo(a.updated));
      tolisthistory.addAll(result);

      isLoading.value = false;
      // yield result;
    }
  }

  Future<void> processStream1(List<Stream<QuerySnapshot>> streams) async {
    var combinedStream = StreamZip(streams);

    await for (var snapshots in combinedStream) {
      List<HistoryModel> result = [];
      tolisthistory.clear();
      HistoryModel historymodellocal;

      for (var query in snapshots) {
        for (var doc in query.docs) {
          String doctype = doc.data()['doctype'];

          if (doctype == "IN") {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
          } else if (doctype == "SR") {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
          } else {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
          }
          result.add(historymodellocal);
        }
      }
      result.sort((a, b) => b.updated.compareTo(a.updated));
      tolisthistory.assignAll(result);

      // isLoading.value = false;
      // yield tolisthistory;
    }
  }

  Stream<List<HistoryModel>> history() async* {
    try {
      listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
      listforin = await DatabaseHelper.db.getCategorywithrole("IN");
      if (listforin.length != 0) {
        for (int i = 0; i < listforin.length; i++) {
          if (listforin[i].inventory_group_name == "Others") {
            listforin.removeWhere((element) =>
                element.inventory_group_id == listforin[i].inventory_group_id);
          }
          if (listcategory.any((element) =>
              element.inventory_group_id == listforin[i].inventory_group_id)) {
            listcategory.removeWhere((element) =>
                element.inventory_group_id == listforin[i].inventory_group_id);
            listcategory.add(listforin[i]);
          } else {
            listcategory.add(listforin[i]);
          }
        }
      }
      final querySnapshot = await FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(listcategory[0].inventory_group_id)
          .collection(choicedate.value)
          .get();

      Set<String> uniqueKeys = Set(); // To store unique keys
      List<HistoryModel> result = [];

      for (var doc in querySnapshot.docs) {
        String doctype = doc.data()['doctype'];
        String key = doc.data()['documentno']; // Unique identifier field

        // Check if this key has already been added
        // if (!uniqueKeys.contains(key)) {
        //   uniqueKeys.add(key);

        HistoryModel ReportsModellocal;

        if (doctype == "IN") {
          ReportsModellocal =
              HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
        } else if (doctype == "SR") {
          ReportsModellocal =
              HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
        } else {
          ReportsModellocal =
              HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
        }

        if (ReportsModellocal.isapprove == "Y") {
          result.add(ReportsModellocal);
        } else {
          result.add(ReportsModellocal);
        }
        // }
      }

      if (listcategory.length > 1) {
        final query2 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc(listcategory[1].inventory_group_id)
            .collection(choicedate.value)
            .get();
        int calculate = 0;

        for (var doc in query2.docs) {
          String doctype = doc.data()['doctype'];
          // String key = doc.data()['documentno']; // Unique identifier field

          // Check if this key has already been added

          HistoryModel ReportsModellocal;

          if (doctype == "IN") {
            ReportsModellocal =
                HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);

            result.add(ReportsModellocal);
          } else if (doctype == "SR") {
            ReportsModellocal =
                HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);

            result.add(ReportsModellocal);
          } else {
            ReportsModellocal =
                HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            result.add(ReportsModellocal);
          }
        }
      }

      if (listcategory.length > 2) {
        final query3 = await FirebaseFirestore.instance
            .collection('HISTORY')
            .doc(listcategory[2].inventory_group_id)
            .collection(choicedate.value)
            .get();
        int calculate = 0;

        for (var doc in query3.docs) {
          String doctype = doc.data()['doctype'];
          // String key = doc.data()['documentno']; // Unique identifier field

          // Check if this key has already been added

          HistoryModel ReportsModellocal;

          if (doctype == "IN") {
            ReportsModellocal =
                HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
            result.add(ReportsModellocal);
          } else if (doctype == "SR") {
            ReportsModellocal =
                HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
            result.add(ReportsModellocal);
          } else {
            ReportsModellocal =
                HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
            result.add(ReportsModellocal);
          }
        }
      }

      QuerySnapshot query3 = await FirebaseFirestore.instance
          .collection('HISTORY')
          .doc("ALL")
          .collection(choicedate.value)
          .get();
      int calculate = 0;

      for (var doc in query3.docs) {
        String doctype = doc.data()['doctype'];
        // String key = doc.data()['documentno']; // Unique identifier field

        // Check if this key has already been added

        HistoryModel ReportsModellocal;

        if (doctype == "IN") {
          ReportsModellocal =
              HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
          if (result
              .any((element) => element.ebeln == ReportsModellocal.ebeln)) {
            // if (calculate == 0) {
            //   calculate = calculate + 1;
            result.removeWhere((element) =>
                element.ebeln == ReportsModellocal.ebeln &&
                element.mblnr == null);
            // }

            // ReportsModellocal.flag = "Y";
            result.add(ReportsModellocal);
          }
        } else if (doctype == "SR") {
          ReportsModellocal =
              HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
          // if (result.any((element) =>
          //     element.documentno == ReportsModellocal.documentno)) {
          //   result.removeWhere((element) =>
          //       element.documentno == ReportsModellocal.documentno &&
          //       element.mblnr == null);
          //   // ReportsModellocal.flag = "Y";
          //   result.add(ReportsModellocal);
          // }
          if (result.any((element) =>
              element.documentno == ReportsModellocal.documentno)) {
            // if (calculate == 0) {
            //   calculate = calculate + 1;
            result.removeWhere((element) =>
                element.documentno == ReportsModellocal.documentno &&
                element.mblnr == null);
            // }

            // ReportsModellocal.flag = "Y";
            result.add(ReportsModellocal);
          } else {
            for (int i = 0; i < listcategory.length; i++) {
              if (ReportsModellocal.detail.any((element) =>
                  element.inventory_group ==
                  listcategory[i].inventory_group_id)) {
                result.removeWhere((element) =>
                    element.documentno == ReportsModellocal.documentno);
                result.add(ReportsModellocal);
              }
            }
            ;
          }
          // result.add(ReportsModellocal);
        } else {
          ReportsModellocal =
              HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
          // if (result.any((element) =>
          //     element.documentno == ReportsModellocal.documentno)) {
          //   result.removeWhere((element) =>
          //       element.documentno == ReportsModellocal.documentno);
          //   // ReportsModellocal.flag = "Y";
          //   result.add(ReportsModellocal);
          // }
        }

        // if (ReportsModellocal.isapprove == "Y") {
        //   result.add(ReportsModellocal);
        // } else {
        //   result.add(ReportsModellocal);
        // }
      }

      tolisthistory.assignAll(result);
      isLoading.value = false;

      yield result; // Yield the result as a Stream
    } catch (e) {
      print(e);
    }
  }

  // Stream<List<HistoryModel>> history() async* {
  //   try {
  //     listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
  //     List<Stream<QuerySnapshot>> streams = [];
  //     tolisthistory.value = [];
  //     if (listcategory.any((element) => element.inventory_group_id == "ALL")) {
  //       for (int i = 0; i < listcategory.length; i++) {
  //         // Check if inventory_group_id is "ALL" and skip it
  //         if (listcategory[i].inventory_group_id == "ALL") {
  //           processStream1(streams);
  //           streams.clear();
  //           Stream<QuerySnapshot> stream = FirebaseFirestore.instance
  //               .collection('HISTORY')
  //               .doc(listcategory[i].inventory_group_id)
  //               .collection(choicedate.value)
  //               .snapshots();

  //           if (stream != null) {
  //             streams.add(stream);
  //           }
  //           await processStream2(streams);
  //         } else {
  //           Stream<QuerySnapshot> stream = FirebaseFirestore.instance
  //               .collection('HISTORY')
  //               .doc(listcategory[i].inventory_group_id)
  //               .collection(choicedate.value)
  //               .snapshots();

  //           if (stream != null) {
  //             streams.add(stream);
  //           }
  //         }
  //       }
  //       yield tolisthistory;
  //     } else {
  //       for (int i = 0; i < listcategory.length; i++) {
  //         // Check if inventory_group_id is "ALL" and skip it
  //         if (listcategory[i].inventory_group_id == "ALL") {
  //           continue;
  //         }

  //         Stream<QuerySnapshot> stream = FirebaseFirestore.instance
  //             .collection('HISTORY')
  //             .doc(listcategory[i].inventory_group_id)
  //             .collection(choicedate.value)
  //             .snapshots();

  //         if (stream != null) {
  //           streams.add(stream);
  //         }
  //       }

  //       var combinedStream = StreamZip(streams);

  //       await for (var snapshots in combinedStream) {
  //         List<HistoryModel> result = [];
  //         tolisthistory.value = [];
  //         HistoryModel historymodellocal;

  //         for (var query in snapshots) {
  //           for (var doc in query.docs) {
  //             String doctype = doc.data()['doctype'];

  //             if (doctype == "IN") {
  //               historymodellocal = HistoryModel.fromDocumentSnapshotInModel(
  //                   documentSnapshot: doc);
  //             } else if (doctype == "SR") {
  //               historymodellocal =
  //                   HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
  //             } else {
  //               historymodellocal = HistoryModel.fromDocumentSnapshotStock(
  //                   documentSnapshot: doc);
  //             }
  //             result.add(historymodellocal);
  //           }
  //         }
  //         result.sort((a, b) => b.updated.compareTo(a.updated));
  //         tolisthistory.assignAll(result);

  //         isLoading.value = false;
  //         yield tolisthistory;
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Stream<List<HistoryModel>> history() async* {
  //   try {
  //     listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
  //     List<Stream<QuerySnapshot>> streams = [];

  //     for (int i = 0; i < listcategory.length; i++) {
  //       Stream<QuerySnapshot> stream = FirebaseFirestore.instance
  //           .collection('HISTORY')
  //           .doc(listcategory[i].inventory_group_id)
  //           .collection(choicedate.value)
  //           .snapshots();

  //       if (stream != null) {
  //         streams.add(stream);
  //       }
  //     }

  //     var combinedStream = StreamZip(streams);

  //     await for (var snapshots in combinedStream) {
  //       List<HistoryModel> result = [];
  //       tolisthistory.value = [];
  //       HistoryModel historymodellocal;

  //       for (var query in snapshots) {
  //         for (var doc in query.docs) {
  //           String doctype = doc.data()['doctype'];

  //           if (doctype == "IN") {
  //             historymodellocal = HistoryModel.fromDocumentSnapshotInModel(
  //                 documentSnapshot: doc);
  //           } else if (doctype == "SR") {
  //             historymodellocal =
  //                 HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
  //           } else {
  //             historymodellocal =
  //                 HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
  //           }
  //           result.add(historymodellocal);
  //           // if(historymodellocal.isapprove == "N" )

  //           // if (historymodellocal.isapprove == "Y") {

  //           // }
  //         }
  //       }
  //       result.sort((a, b) => b.updated.compareTo(a.updated));
  //       tolisthistory.assignAll(result);

  //       isLoading.value = false;
  //       yield result;
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Stream<List<HistoryModel>> reports() {
    // ...
    return FirebaseFirestore.instance
        .collection('HISTORY')
        .doc(globalvm.username.value)
        .collection(choicedate.value)
        .orderBy('updated', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      Set<String> uniqueKeys = Set(); // To store unique keys
      List<HistoryModel> result = [];

      tolisthistory.value = [];
      HistoryModel historymodellocal;

      for (var doc in query.docs) {
        String doctype = doc.data()['doctype'];
        String key = doc.data()['documentno']; // Unique identifier field

        // Check if this key has already been added
        if (!uniqueKeys.contains(key)) {
          uniqueKeys.add(key);

          if (doctype == "IN") {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotInModel(documentSnapshot: doc);
          } else if (doctype == "SR") {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotOut(documentSnapshot: doc);
          } else {
            historymodellocal =
                HistoryModel.fromDocumentSnapshotStock(documentSnapshot: doc);
          }

          if (historymodellocal.isapprove == "Y") {
            result.add(historymodellocal);
          } else {
            result.add(historymodellocal);
          }
        }
      }

      tolisthistory.assignAll(result);
      // Other processing logic...

      isLoading.value = false;
      return result;
    });
  }

  dateToString(String date) {
    final format = DateFormat('dd-MM-yyyy');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }
}
