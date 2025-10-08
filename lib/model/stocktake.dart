import 'dart:convert';
import 'itemout.dart';
import 'stocktakedetail.dart';
import 'immobileitem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StocktickModel {
  List<StockTakeDetailModel> detail;
  List<String> LGORT;
  String updated;
  String updatedby;
  String created;
  String createdby;
  String isapprove;
  String doctype;
  String documentno;
  // List<StockDetail> detail;

  // @override
  // String getApprovedat(String user) {
  //   String maxdate = "2000-01-01";

  //   for (var list in detail
  //       .where((element) =>
  //           element.approvename == user && element.updated_at != "")
  //       .toList()) {
  //     DateTime updatedat = DateTime.parse(list.updated_at);

  //     DateTime maxdatestring = DateTime.parse(maxdate);
  //     if (maxdatestring.isBefore(updatedat)) {
  //       maxdate = list.updated_at;
  //     }
  //   }

  //   return maxdate;
  // }

  StocktickModel(
      {this.LGORT,
      this.detail,
      this.updated,
      this.updatedby,
      this.created,
      this.createdby,
      this.isapprove,
      this.doctype,
      this.documentno});

  StocktickModel clone() {
    return StocktickModel.clone(this);
  }

  StocktickModel.clone(StocktickModel documentSnapshot) {
    try {
      LGORT = documentSnapshot.LGORT == null ? [] : documentSnapshot.LGORT;
      updated =
          documentSnapshot.updated == null ? "" : documentSnapshot.updated;
      updatedby =
          documentSnapshot.updatedby == null ? "" : documentSnapshot.updatedby;
      created =
          documentSnapshot.created == null ? "" : documentSnapshot.created;
      createdby =
          documentSnapshot.createdby == null ? "" : documentSnapshot.createdby;
      isapprove = documentSnapshot.isapprove ?? "";
      doctype = "stocktick";
      documentno = documentSnapshot.documentno ?? "";
    } catch (e) {
      print(e);
    }
  }

  factory StocktickModel.fromJson(Map<String, dynamic> data) {
    try {
      return StocktickModel(
        detail: (data['detail'] as List<dynamic>)
                ?.map((e) =>
                    StockTakeDetailModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
       LGORT : List<String>.from(data['LGORT'] ?? []),
        updated: data['updated'] == null ? "" : data['updated'],
        updatedby: data['updatedby'] == null ? "" : data['updatedby'],
        created: data['created'] == null ? "" : data['created'],
        createdby: data['createdby'] == null ? "" : data['createdby'],
        isapprove: data['isapprove'] == null ? "" : data['isapprove'],
        doctype: data['doctype'] == null ? "" : data['doctype'],
        documentno: data['documentno'] == null ? "" : data['documentno'],
      );
    } catch (e) {
      print(e);
    }
  }
  StocktickModel.fromDocumentSnapshotDetail({DocumentSnapshot documentSnapshot}) {
    try {
      final data = documentSnapshot.data() as Map<String, dynamic>;

      // LGORT = data['LGORT'] == null ? "" : data['LGORT'];
       LGORT = List<String>.from(data['LGORT'] ?? []);
       detail = (data['detail'] as List<dynamic>)
              ?.map((itemWord) => StockTakeDetailModel.fromJson(itemWord))
              .toList() ??
          [];
      updated = data['updated'] == null ? "" : data['updated'];

      updatedby = data['updatedby'] == null ? "" : data['updatedby'];
      created = data['created'] == null ? "" : data['created'];

      createdby = data['createdby'] == null ? "" : data['createdby'];
      isapprove = data['isapprove'] == null ? "" : data['isapprove'];
      doctype = "stocktick";
      documentno = data['documentno'] == null ? "" : data['documentno'];
    } catch (e) {
      print(e);
    }
  }

  StocktickModel.fromDocumentSnapshot({DocumentSnapshot documentSnapshot}) {
    try {
      final data = documentSnapshot.data() as Map<String, dynamic>;

      // LGORT = data['LGORT'] == null ? "" : data['LGORT'];
       LGORT = List<String>.from(data['LGORT'] ?? []);
      //  detail = (data['detail'] as List<dynamic>)
      //         ?.map((itemWord) => StockTakeDetailModel.fromJson(itemWord))
      //         .toList() ??
      //     [];
      updated = data['updated'] == null ? "" : data['updated'];

      updatedby = data['updatedby'] == null ? "" : data['updatedby'];
      created = data['created'] == null ? "" : data['created'];

      createdby = data['createdby'] == null ? "" : data['createdby'];
      isapprove = data['isapprove'] == null ? "" : data['isapprove'];
      doctype = "stocktick";
      documentno = data['documentno'] == null ? "" : data['documentno'];
    } catch (e) {
      print(e);
    }
  }
}
