import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/config/config.dart';
import 'package:immobile_app_fixed/config/database_config.dart';
import 'package:immobile_app_fixed/config/global_variable_config.dart';
import 'package:immobile_app_fixed/models/in_model.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:intl/intl.dart';

class InVM extends GetxController {
  final GlobalVM globalvm = Get.find();
  static final HttpClient client = HttpClient();
  final Config config = Config();

  final RxList<InModel> tolistPO = <InModel>[].obs;
  final RxList<InModel> tolistPOapprove = <InModel>[].obs;
  final RxList<InModel> tolistPObackup = <InModel>[].obs;

  final Rx<List<InModel>> srlist = Rx<List<InModel>>([]);
  final Rx<List<InModel>> srlisthistory = Rx<List<InModel>>([]);

  final List<InModel> outmodellocal = [];
  final List<InModel> outmodellocalbackup = [];
  final List<InModel> outmodelhistory = [];

  final RxBool isLoading = true.obs;
  final RxBool isLoadingPDF = true.obs;
  final RxBool isSearch = true.obs;
  final RxBool isapprove = false.obs;
  final RxBool isIconSearch = true.obs;
  final RxBool isDark = true.obs;
  final RxBool tutorialRecent = true.obs;

  final RxInt isIconSearchint = 0.obs;
  final Rx<DateTime> datetimenow = DateTime.now().obs;
  final Rx<DateTime> firstdate = DateTime.now().obs;
  final Rx<DateTime> lastdate = DateTime.now().obs;
  final RxString sortVal = 'PO Date'.obs;
  final RxString choicein = ''.obs;
  final RxString pdfDir = ''.obs;

  final Rx<dynamic> pdfFile = Rx<dynamic>(null);
  final Rx<dynamic> pdfBytes = Rx<dynamic>(null);

  String username = '';

  @override
  void onReady() {
    srlist.bindStream(listPO());
  }

  void onRecent() {
    srlist.bindStream(listforRecentALL());
  }

  Future<void> getname() async {
    username = (await DatabaseHelper.db.getUser()) ?? '';
  }

  String? dateToString(String? date, String test) {
    if (date == null) return '';
    try {
      final format = DateFormat('dd-MM-yyyy');
      final dateTime = DateTime.parse(date);
      return format.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Future<bool> approveIn(
    InModel inmodel,
    List<Map<String, dynamic>> tdata,
  ) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      final username = await DatabaseHelper.db.getUser();

      await FirebaseFirestore.instance
          .collection('in')
          .doc(inmodel.group)
          .collection('header')
          .doc(inmodel.ebeln)
          .set({
            'AEDAT': inmodel.aedat,
            'BWART': inmodel.bwart,
            'DLV_COMP': inmodel.dlvComp,
            'EBELN': inmodel.ebeln,
            'ERNAM': inmodel.ernam,
            'GROUP': inmodel.group,
            'LGORT': inmodel.lgort,
            'LIFNR': inmodel.lifnr,
            'T_DATA': tdata,
            'WERKS': inmodel.werks,
            'clientid': inmodel.clientid,
            'created': inmodel.created,
            'createdby': inmodel.createdby,
            'doctype': inmodel.doctype,
            'orgid': inmodel.orgid,
            'sync': inmodel.issync,
            'updated': formattedDate,
            'updatedby': username,
            'TRUCK': inmodel.truck,
            'INVOICENO': inmodel.invoiceno,
            'VENDORPO': inmodel.vendorpo,
          });

      return true;
    } catch (e) {
      debugPrint('Error in approveIn: $e');
      return false;
    }
  }

  Future<void> sendHistory(
    InModel inmodel,
    List<Map<String, dynamic>> tdata,
  ) async {
    try {
      final now = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(now);
      final formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
      final username = await DatabaseHelper.db.getUser();

      final historyCollection = FirebaseFirestore.instance
          .collection('HISTORY')
          .doc(GlobalVar.choicecategory)
          .collection(todayString);

      final historyData = {
        'AEDAT': inmodel.aedat,
        'BWART': inmodel.bwart,
        'DLV_COMP': inmodel.dlvComp,
        'EBELN': inmodel.ebeln,
        'ERNAM': inmodel.ernam,
        'GROUP': inmodel.group,
        'LGORT': inmodel.lgort,
        'LIFNR': inmodel.lifnr,
        'T_DATA': tdata,
        'WERKS': inmodel.werks,
        'clientid': inmodel.clientid,
        'created': inmodel.created,
        'createdby': inmodel.createdby,
        'doctype': inmodel.doctype,
        'orgid': inmodel.orgid,
        'sync': inmodel.issync,
        'updated': formattedDate,
        'updatedby': username,
        'TRUCK': inmodel.truck,
      };

      await historyCollection.add(historyData);
    } catch (e) {
      debugPrint('Error in sendHistory: $e');
    }
  }

  Future<List<InModel>> getData(String ebeln, String category) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('in')
          .doc(category)
          .collection('header')
          .where('EBELN', isEqualTo: ebeln)
          .get();

      if (query.docs.isEmpty) return [];

      final List<InModel> result = [];
      for (final sr in query.docs) {
        final returnpo = InModel.fromDocumentSnapshot(sr);
        final returnpobackup = InModel.fromDocumentSnapshot(sr);

        if (returnpo.dlvComp != 'X' && returnpo.dlvComp != 'I') {
          result.add(returnpo);
          outmodellocalbackup.add(returnpobackup);
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error fetching data: $e');
      rethrow;
    }
  }

  Stream<List<InModel>> listPO() {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    final oneMonthString = DateFormat('yyyy-MM-dd').format(oneMonthAgo);

    try {
      if (GlobalVar.choicecategory == 'ALL') {
        final stream1 = FirebaseFirestore.instance
            .collection('in/AB/header')
            .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
            .snapshots();

        final stream2 = FirebaseFirestore.instance
            .collection('in/CH/header')
            .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
            .snapshots();

        final stream3 = FirebaseFirestore.instance
            .collection('in/FZ/header')
            .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
            .snapshots();

        final combinedStream = StreamZip([stream1, stream2, stream3]);

        return combinedStream
            .asyncMap<List<InModel>>((snapshots) {
              final outmodellocal = <InModel>[];

              for (final query in snapshots) {
                for (final sr in query.docs) {
                  final returnpo = InModel.fromDocumentSnapshot(sr);
                  if (returnpo.dlvComp == 'I') {
                    outmodellocal.add(returnpo);
                  }
                }
              }

              tolistPO.assignAll(outmodellocal);
              return tolistPO;
            })
            .timeout(
              const Duration(seconds: 10),
              onTimeout: (event) => Stream.value([]),
            );
      } else {
        return FirebaseFirestore.instance
            .collection('in/${GlobalVar.choicecategory}/header')
            .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
            .snapshots()
            .map((query) {
              final outmodellocal = <InModel>[];

              for (final sr in query.docs) {
                final returnpo = InModel.fromDocumentSnapshot(sr);
                if (returnpo.dlvComp != 'X' && returnpo.dlvComp != 'I') {
                  outmodellocal.add(returnpo);
                }
              }

              if (outmodellocal.any(
                (e) => e.group != GlobalVar.choicecategory,
              )) {
                onReady();
                return tolistPO;
              } else {
                tolistPO.assignAll(outmodellocal);
                return tolistPO;
              }
            })
            .timeout(
              const Duration(seconds: 10),
              onTimeout: (event) => Stream.value([]),
            );
      }
    } catch (e) {
      debugPrint('Error in listPO: $e');
      return Stream.error(e);
    }
  }

  Stream<List<InModel>> listforRecentALL() {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    final oneMonthString = DateFormat('yyyy-MM-dd').format(oneMonthAgo);

    final stream1 = FirebaseFirestore.instance
        .collection('in/AB/header')
        .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
        .limit(10)
        .snapshots();

    final stream2 = FirebaseFirestore.instance
        .collection('in/CH/header')
        .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
        .limit(10)
        .snapshots();

    final stream3 = FirebaseFirestore.instance
        .collection('in/FZ/header')
        .where('AEDAT', isGreaterThanOrEqualTo: oneMonthString)
        .limit(10)
        .snapshots();

    final combinedStream = StreamZip([stream1, stream2, stream3]);

    return combinedStream.asyncMap<List<InModel>>((snapshots) {
      final outmodellocal = <InModel>[];

      for (final query in snapshots) {
        for (final sr in query.docs) {
          final returnpo = InModel.fromDocumentSnapshot(sr);
          if (returnpo.dlvComp != 'X' && outmodellocal.length < 10) {
            outmodellocal.add(returnpo);
          }
        }
      }

      tolistPO.assignAll(outmodellocal);
      tolistPObackup.assignAll(outmodellocal);
      return tolistPO;
    });
  }

  Stream<List<InModel>> getFilteredPO({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return listPO().map((list) {
      var filteredList = list;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredList = filteredList
            .where(
              (po) =>
                  (po.ebeln?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false) ||
                  (po.lifnr?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }

      if (startDate != null && endDate != null) {
        filteredList = filteredList.where((po) {
          if (po.aedat == null) return false;
          try {
            final poDate = DateTime.parse(po.aedat!);
            return poDate.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                poDate.isBefore(endDate.add(const Duration(days: 1)));
          } catch (e) {
            return false;
          }
        }).toList();
      }

      return filteredList;
    });
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      srlist.bindStream(listPO());
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    tolistPO.assignAll(tolistPObackup);
    isSearch.value = true;
    isIconSearch.value = true;
  }

  @override
  void onClose() {
    srlist.close();
    super.onClose();
  }
}
