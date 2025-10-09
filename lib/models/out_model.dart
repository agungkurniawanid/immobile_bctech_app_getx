import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_out_model.dart';
import 'immobileitem_model.dart';
import 'detail_double_out_model.dart';

class OutModel implements ImmobileItem {
  String? recordId;
  String? createdAt;
  String? created;
  String? createdBy;
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
    this.recordId,
    this.createdAt,
    this.created,
    this.createdBy,
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

  @override
  String getApprovedat(String user) {
    String maxDate = '';

    if (updatedBy == user) {
      maxDate = updated ?? '';
    }

    if (detail != null && detail!.isNotEmpty) {
      for (var d in detail!) {
        if (d.approveName == user && d.updatedAt.isNotEmpty) {
          final updatedAt = DateTime.tryParse(d.updatedAt);
          final maxDateParsed = DateTime.tryParse(maxDate);

          if (updatedAt != null &&
              (maxDateParsed == null || maxDateParsed.isBefore(updatedAt))) {
            maxDate = d.updatedAt;
          }
        }
      }
    }

    return maxDate;
  }

  factory OutModel.fromJson(Map<String, dynamic> data) {
    return OutModel(
      recordId: data['recordid'] ?? '',
      createdAt: data['createdat'] ?? '',
      created: data['created'] ?? '',
      createdBy: data['createdby'] ?? '',
      inventoryGroup: data['inventory_group'] ?? '',
      location: data['location'] ?? '',
      locationName: data['location_name'] ?? '',
      deliveryDate: data['delivery_date'] ?? '',
      totalItem: (data['total_item'] is int)
          ? data['total_item']
          : int.tryParse(data['total_item']?.toString() ?? '0') ?? 0,
      totalQuantity: data['total_quantities']?.toString() ?? '',
      item: data['item'] ?? '',
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
      isApprove: data['isapprove'] ?? '',
      isSync: data['issync'] ?? '',
      docType: data['doctype'] ?? '',
      clientId: data['clientid'] ?? '',
      orgId: data['orgid'] ?? '',
      updated: data['updated'] ?? '',
      updatedBy: data['updatedby'] ?? '',
      documentNo: data['documentno'] ?? '',
      matDoc: data['matdoc'] ?? '',
      flag: data['flag'] ?? '',
      postingDate: data['postingdate'] ?? '',
    );
  }

  factory OutModel.fromDocumentSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return OutModel.fromJson(data);
  }

  OutModel clone() => OutModel.fromJson(toMap());

  Map<String, dynamic> toMap() {
    return {
      'recordid': recordId,
      'createdat': createdAt,
      'created': created,
      'createdby': createdBy,
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

  String toJsonString() => jsonEncode(toMap());
}
