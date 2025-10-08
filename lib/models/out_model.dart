import 'dart:convert';
import 'details_out_model.dart';
import 'immobileitem_model.dart';
import 'detail_double_out_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OutModel implements ImmobileItem {
  String? recordid;
  String? createdat;
  String? created;
  String? createdby;
  String? inventoryGroup;
  String? location;
  String? locationName;
  String? deliveryDate;
  int? totalItem;
  String? totalQuantity;
  String? item;
  List<DetailItem>? detail;
  List<DetailDouble>? detailDouble;
  String? isApprove;
  String? isSync;
  String? docType;
  String? clientId;
  String? orgId;
  String? updated;
  String? updatedBy;
  String? documentNo;
  String? matDoc;
  String? flag;
  String? postingDate;

  OutModel({
    this.recordid,
    this.createdat,
    this.created,
    this.createdby,
    this.inventoryGroup,
    this.location,
    this.locationName,
    this.deliveryDate,
    this.totalItem,
    this.totalQuantity,
    this.item,
    this.detail,
    this.detailDouble,
    this.isApprove,
    this.isSync,
    this.docType,
    this.clientId,
    this.orgId,
    this.updated,
    this.updatedBy,
    this.documentNo,
    this.matDoc,
    this.flag,
    this.postingDate,
  });

  /// 🔹 Override dari ImmobileItem
  @override
  String getApprovedat(String user) {
    String maxDate = "";

    if (updatedBy == user) {
      maxDate = updated ?? "";
    }

    if (detail != null) {
      for (var list in detail!.where(
        (e) => e.approveName == user && (e.updatedAt.isNotEmpty),
      )) {
        final updatedAt = DateTime.tryParse(list.updatedAt);
        final maxDateParsed = DateTime.tryParse(maxDate);

        if (updatedAt != null &&
            (maxDateParsed == null || maxDateParsed.isBefore(updatedAt))) {
          maxDate = list.updatedAt;
        }
      }
    }
    return maxDate;
  }

  /// 🔹 Factory untuk parsing JSON mentah
  factory OutModel.fromJson(Map<String, dynamic> data) {
    return OutModel(
      recordid: data['recordid'] ?? "",
      createdat: data['createdat'] ?? "",
      created: data['created'] ?? "",
      createdby: data['createdby'] ?? "",
      inventoryGroup: data['inventory_group'] ?? "",
      location: data['location'] ?? "",
      locationName: data['location_name'] ?? "",
      deliveryDate: data['delivery_date'] ?? "",
      totalItem: data['total_item'] ?? 0,
      totalQuantity: data['total_quantities'] ?? "",
      item: data['item'] ?? "",
      detail:
          (data['detail'] as List?)
              ?.map((e) => DetailItem.fromJson(e))
              .toList() ??
          [],
      detailDouble:
          (data['detaildouble'] as List?)
              ?.map((e) => DetailDouble.fromJson(e))
              .toList() ??
          [],
      isApprove: data['isapprove'] ?? "",
      isSync: data['issync'] ?? "",
      docType: data['doctype'] ?? "",
      clientId: data['clientid'] ?? "",
      orgId: data['orgid'] ?? "",
      updated: data['updated'] ?? "",
      updatedBy: data['updatedby'] ?? "",
      documentNo: data['documentno'] ?? "",
      matDoc: data['matdoc'] ?? "",
      flag: data['flag'] ?? "",
      postingDate: data['postingdate'] ?? "",
    );
  }

  /// 🔹 Factory dari Firestore DocumentSnapshot
  factory OutModel.fromDocumentSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return OutModel.fromJson(data);
  }

  /// 🔹 Clone instance
  OutModel clone() => OutModel.fromJson(toMap());

  /// 🔹 Convert ke Map
  Map<String, dynamic> toMap() {
    return {
      'recordid': recordid,
      'createdat': createdat,
      'created': created,
      'createdby': createdby,
      'inventory_group': inventoryGroup,
      'location': location,
      'location_name': locationName,
      'delivery_date': deliveryDate,
      'total_item': totalItem,
      'total_quantities': totalQuantity,
      'item': item,
      'detail': detail?.map((e) => e.toJson()).toList() ?? [],
      'detaildouble': detailDouble?.map((e) => e.toJson()).toList() ?? [],
      'isapprove': isApprove,
      'issync': isSync,
      'doctype': docType,
      'clientid': clientId,
      'orgid': orgId,
      'updated': updated,
      'updatedby': updatedBy,
      'documentno': documentNo,
      'matdoc': matDoc,
      'flag': flag,
      'postingdate': postingDate,
    };
  }

  /// 🔹 Convert ke JSON String
  String toJsonString() => jsonEncode(toMap());
}
