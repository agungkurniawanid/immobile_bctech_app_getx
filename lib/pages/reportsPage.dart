import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:immobile/model/indetail.dart';
import 'package:immobile/model/detailsout.dart';
import 'package:immobile/model/detaildoubleout.dart';
import 'package:immobile/model/outmodel.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/itemchoicemodel.dart' as model;
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/stockrequestvm.dart';
import 'package:immobile/viewmodel/pidvm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/stockcheckvm.dart';
import 'package:immobile/viewmodel/reportsvm.dart';
import 'package:get/get.dart';
import 'package:immobile/config/database.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key key}) : super(key: key);
  @override
  _ReportsPage createState() => _ReportsPage();
}

class _ReportsPage extends State<ReportsPage> {
  int idPeriodSelected = 1;
  List<model.ItemChoice> listchoice = [];
  List<Category> listcategory = [];
  InVM inVM = Get.find();
  StockCheckVM stockcheckVM = Get.find();
  PidVM pidVM = Get.find();
  StockrequestVM stockrequestVM = Get.find();
  GlobalVM globalVM = Get.find();
  ReportsVM reportsVM = Get.find();
  GlobalKey p4Key = GlobalKey();
  GlobalKey srKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name;
  ScrollController controller;
  // String choice;
  List<String> sortList = [];
  // List<dynamic> mylist = [];

  @override
  void initState() {
    super.initState();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // getchoicechip();
    if (sortList.length == 0) {
      getDataCategory();
    }

    reportsVM.choicedate.value = today;
  }

  Future<List<String>> getDataCategory() async {
    reportsVM.choice.value = "";
    listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
    if (listcategory.length != 0) {
      for (int i = 0; i < listcategory.length; i++) {
        if (listcategory[i].inventory_group_id != "ALL") {
          sortList.add(listcategory[i].inventory_group_id);
        }
      }
    }
    sortList.add("OT");
    sortList.add("ALL");
    reportsVM.choice.value = sortList[0];
    reportsVM.onReady();
    return sortList;
  }

  String _CalculTotalpcsbyadmin(String doctype) {
    int total = 0;
    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) =>
              element.doctype == "SR" &&
              element.mblnr != "" &&
              element.mblnr != null)
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _Calcultotalboxbyadmin(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) =>
              element.doctype == "SR" &&
              element.mblnr != "" &&
              element.mblnr != null)
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _CalculTotalpcsreq(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_item);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_item);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _Calcultotalboxreq(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_item);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_item);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _CalculTotalpcsbycategory(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _Calcultotalboxbycategory(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _CalculTotalpcssr(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      // var justout = reportsVM.tolisthistory.value
      //     .where((element) => element.doctype == "SR")
      //     .toList();
      for (var j = 0; j < reportsVM.tolisthistoryout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < reportsVM.tolisthistoryout[j].detail.length; i++) {
          var justforctn = reportsVM.tolisthistoryout[j].detail[i].uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      // var justout = reportsVM.tolisthistory.value
      //     .where((element) => element.doctype == "SR")
      //     .toList();
      for (var j = 0; j < reportsVM.tolisthistoryout.length; j++) {
        var validation = reportsVM.tolisthistoryout[j].detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _Calcultotalboxsr(String doctype) {
    int total = 0;

    if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      // var justout = reportsVM.tolisthistory.value
      //     .where((element) => element.doctype == "SR")
      //     .toList();
      for (var j = 0; j < reportsVM.tolisthistoryout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < reportsVM.tolisthistoryout[j].detail.length; i++) {
          var justforctn = reportsVM.tolisthistoryout[j].detail[i].uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      // var justout = reportsVM.tolisthistory.value
      //     .where((element) => element.doctype == "SR")
      //     .toList();
      for (var j = 0; j < reportsVM.tolisthistoryout.length; j++) {
        var validation = reportsVM.tolisthistoryout[j].detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _CalculTotalpcs(String doctype) {
    double total = 0;

    if (doctype == "IN") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "IN")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        for (var i = 0; i < justout[j].T_DATA.length; i++) {
          // var justforctn = justout[j]
          //     .T_DATA[i]
          //     .uom
          //     .where((element) => element.uom == "CTN")
          //     .toList();
          // if (justforctn.length != 0) {
          total += justout[j].T_DATA[i].qtuom;
          // }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "PCS")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _Calcultotalbox(String doctype) {
    int total = 0;

    if (doctype == "IN") {
      var justout = reportsVM.tolisthistory
          .where((element) => element.doctype == "IN")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        for (var i = 0; i < justout[j].T_DATA.length; i++) {
          // var justforctn = justout[j]
          //     .T_DATA[i]
          //     .uom
          //     .where((element) => element.uom == "CTN")
          //     .toList();
          // if (justforctn.length != 0) {
          total += justout[j].T_DATA[i].qtctn;
          // }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else if (doctype == "OUT" && reportsVM.choice.value == "ALL") {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        // var validation = justout[j]
        //     .detail
        //     .where(
        //         (element) => element.inventory_group == reportsVM.choice.value)
        //     .toList();
        for (var i = 0; i < justout[j].detail.length; i++) {
          var justforctn = justout[j]
              .detail[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    } else {
      var justout = reportsVM.tolisthistory.value
          .where((element) => element.doctype == "SR")
          .toList();
      for (var j = 0; j < justout.length; j++) {
        var validation = justout[j]
            .detail
            .where(
                (element) => element.inventory_group == reportsVM.choice.value)
            .toList();
        for (var i = 0; i < validation.length; i++) {
          var justforctn = validation[i]
              .uom
              .where((element) => element.uom == "CTN")
              .toList();
          if (justforctn.length != 0) {
            total += int.parse(justforctn[0].total_picked);
          }
          //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

          //  }
        }
        //print(widget.controllers[i].text);

      }
    }

    String totalstring = total.toString();
    return totalstring;
  }

  String _Calcultotalboxwithdoc(List<DetailItem> justout) {
    int total = 0;
    var validation = justout
        .where((element) => element.inventory_group == reportsVM.choice.value)
        .toList();
    // var justout = item.value
    //     .where((element) => element.doctype == "SR")
    //     .toList();
    // for (var j = 0; j < justout.length; j++) {
    for (var i = 0; i < validation.length; i++) {
      var justforctn =
          validation[i].uom.where((element) => element.uom == "CTN").toList();
      if (justforctn.length != 0) {
        total += int.parse(justforctn[0].total_picked);
      }
      //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

      //  }
    }
    //print(widget.controllers[i].text);

    // }
    String totalstring = total.toString();
    return totalstring;
  }

  String _CalculTotalpcswithdoc(List<DetailItem> justout) {
    int total = 0;
    var validation = justout
        .where((element) => element.inventory_group == reportsVM.choice.value)
        .toList();
    // var justout = item.value
    //     .where((element) => element.doctype == "SR")
    //     .toList();
    // for (var j = 0; j < justout.length; j++) {
    for (var i = 0; i < validation.length; i++) {
      var justforctn =
          validation[i].uom.where((element) => element.uom == "PCS").toList();
      if (justforctn.length != 0) {
        total += int.parse(justforctn[0].total_picked);
      }
      //  for (var u = 0; u < justout[j].detail[i].uom.length; i++) {

      //  }
    }
    //print(widget.controllers[i].text);

    // }
    String totalstring = total.toString();
    return totalstring;
  }

//   void sumforout(DetailItem outmodel){
// return outmodel.uom.fold(0, (int previousValue, DetailDouble element) {
//                                               return previousValue +
//                                                   int.parse(element.total_picked);
//                                             })
//   }

  void getchoicechip() async {
    try {
      final List<Map<String, String>> data = [
        {
          'id': "0",
          'label': 'IN',
          'labelname': 'IN',
        },
        {
          'id': "1",
          'label': 'OUT',
          'labelname': 'OUT',
        },
      ];
      // listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");

      setState(() {
        for (int i = 0; i < data.length; i++) {
          model.ItemChoice choicelocal = model.ItemChoice(
              id: i + 1,
              label: data[i]["label"],
              labelname: data[i]["labelname"]);
          listchoice.add(choicelocal);
        }
        // if(listcategory[i].)

        reportsVM.choicechip.value = listchoice[0].label;
        // stockrequestVM.choicesr.value = listchoice[0].label;
        reportsVM.onReady();
      });
    } catch (e) {
      print(e);
    }
  }

  List<Widget> _buildActions() {
    return <Widget>[
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              DateTime currentDate = DateTime.now();
              DateTime previousDate = currentDate.subtract(Duration(days: 7));

              DateTime newDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: currentDate.subtract(Duration(
                    days:
                        365)), // Set the first date to 1 year before the current date
                lastDate: currentDate,
              );

              if (newDate == null) return;

              setState(() {
                reportsVM.choicedate.value =
                    DateFormat('yyyy-MM-dd').format(newDate);
                reportsVM.onReady();
              });
            },
          ),
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              // actions: _buildActions(),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.red,

              // leading: _isSearching ? const BackButton() : null,
              title: Container(
                  child: Column(
                children: [
                  TextWidget(
                      text: "Daily Reports",
                      isBlueTxt: false,
                      maxLines: 2,
                      size: 18,
                      color: Colors.white),
                  TextWidget(
                      text:
                          "( ${globalVM.dateToString(reportsVM.choicedate.value)} )",
                      isBlueTxt: false,
                      maxLines: 2,
                      size: 18,
                      color: Colors.white)
                ],
              )),
              actions: _buildActions(),
              centerTitle: true),
          body: DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: SafeArea(child: Obx(() {
                return Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // height: 125,
                      color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10, bottom: 5, top: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              text: 'Total IN',
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: TextWidget(
                                            isBlueTxt: false,
                                            isBlueBackground: true,
                                            text: ':',
                                            size: 13,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              maxLines: 2,
                                              text: _Calcultotalbox("IN") +
                                                  " CTN " +
                                                  " + " +
                                                  _CalculTotalpcs("IN") +
                                                  " PCS ",
                                              size: 13,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              text: 'Total Picker',
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: TextWidget(
                                            isBlueTxt: false,
                                            isBlueBackground: true,
                                            text: ':',
                                            size: 13,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              maxLines: 2,
                                              text: _Calcultotalboxbycategory(
                                                      "OUT") +
                                                  " CTN " +
                                                  " + " +
                                                  _CalculTotalpcsbycategory(
                                                      "OUT") +
                                                  " PCS ",
                                              size: 13,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              text: 'Total ALL',
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: TextWidget(
                                            isBlueTxt: false,
                                            isBlueBackground: true,
                                            text: ':',
                                            size: 13,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              maxLines: 2,
                                              text: _Calcultotalboxbyadmin(
                                                      "OUT") +
                                                  " CTN " +
                                                  " + " +
                                                  _CalculTotalpcsbyadmin(
                                                      "OUT") +
                                                  " PCS ",
                                              size: 13,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              text: 'Total SR',
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: TextWidget(
                                            isBlueTxt: false,
                                            isBlueBackground: true,
                                            text: ':',
                                            size: 13,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: TextWidget(
                                              isBlueTxt: false,
                                              isBlueBackground: true,
                                              maxLines: 2,
                                              text: _Calcultotalboxsr("OUT") +
                                                  " CTN " +
                                                  " + " +
                                                  _CalculTotalpcssr("OUT") +
                                                  " PCS ",
                                              size: 13,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    // Row(
                                    //   children: [
                                    //     Expanded(
                                    //       flex: 5,
                                    //       child: Container(
                                    //         child: TextWidget(
                                    //           isBlueTxt: false,
                                    //           isBlueBackground: true,
                                    //           text: 'Total ALL',
                                    //           size: 13,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     Container(
                                    //       child: TextWidget(
                                    //         isBlueTxt: false,
                                    //         isBlueBackground: true,
                                    //         text: ':',
                                    //         size: 13,
                                    //       ),
                                    //     ),
                                    //     Expanded(
                                    //       flex: 10,
                                    //       child: Container(
                                    //         padding: EdgeInsets.only(left: 10),
                                    //         alignment: Alignment.centerLeft,
                                    //         child: TextWidget(
                                    //           isBlueTxt: false,
                                    //           isBlueBackground: true,
                                    //           maxLines: 2,
                                    //           text: _Calcultotalboxreq("OUT") +
                                    //               " CTN " +
                                    //               " + " +
                                    //               _CalculTotalpcsreq("OUT") +
                                    //               " PCS ",
                                    //           size: 13,
                                    //         ),
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                  ],
                                )),
                                Obx(() {
                                  return Container(
                                    // stockrequestQWP (13:2219)
                                    // width: 125 * fem,
                                    // height: 25 * fem,
                                    child: DropdownButton(
                                      dropdownColor: Colors.red,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                      ),
                                      hint: TextWidget(
                                          isBlueTxt: false,
                                          isBlueBackground: true,
                                          text: 'Sort By ',
                                          size: 16.0),
                                      value: reportsVM.choice.value,
                                      items: sortList.map((value) {
                                        return DropdownMenuItem(
                                          child: TextWidget(
                                              text: value,
                                              color: Colors.white,
                                              // isBlueBackground: true,
                                              isBlueTxt: false),
                                          value: value,
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          reportsVM.choice.value = value;
                                          reportsVM.onReady();
                                          // Add your sorting logic here based on the selected value.
                                          // For example, if you want to sort by "PO Date" or "LIFNR," you can uncomment and implement the sorting logic accordingly.
                                          // if (value == "PO Date") {
                                          //   inVM.tolistPO.value.sort(
                                          //       (a, b) => b.aedat.compareTo(a.aedat));
                                          // } else {
                                          //   inVM.tolistPO.value.sort(
                                          //       (a, b) => a.lifnr.compareTo(b.lifnr));
                                          // }
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: reportsVM.tolisthistory.length == 0
                          ? Center(
                              child: Container(
                                  // undrawnodatarekwbl11XGU (23:995)
                                  width: 250,
                                  height: 250,
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'data/images/undrawnodatarekwbl-1-1.png',
                                        fit: BoxFit.cover,
                                      ),
                                      TextWidget(
                                        isBlueTxt: false,
                                        text: "No Data",
                                        size: 15,
                                      ),
                                    ],
                                  )),
                            )
                          : 
                          Container(
                              // padding: const EdgeInsets.all(5.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Obx(
                                    () => DataTable(
                                      dataRowHeight:
                                          40.0, // Set the height of each row (adjust as needed)
                                      columnSpacing: 13.0,
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.grey[700]),
                                      headingTextStyle:
                                          TextStyle(color: Colors.white),
                                      dataRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.grey[800]),
                                      dataTextStyle:
                                          TextStyle(color: Colors.white),
                                      columns: [
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Type',
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text('    Doc No',
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.right),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'CTN',
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'PCS',
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Received By',
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Received',
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Doc SAP',
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: reportsVM.tolisthistory.map((item) {
                                        // _CalculTotalpcs(
                                        //     reportsVM.choicechip.value);

                                        // _Calcultotalbox(
                                        //     reportsVM.choicechip.value);

                                        return DataRow(cells: [
                                          DataCell(Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item.doctype,
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          )),
                                          DataCell(item.doctype == "IN"
                                              ? Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    item.ebeln,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                )
                                              : Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    item.documentno,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                )),
                                          DataCell(item.doctype == "IN"
                                              ? Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '${item.T_DATA.fold(0, (int previousValue, InDetail element) {
                                                      return previousValue +
                                                          element.qtctn;
                                                    })}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )
                                              : Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    _Calcultotalboxwithdoc(
                                                        item.detail),
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )),
                                          DataCell(item.doctype == "IN"
                                              ? Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '${item.T_DATA.fold<double>(0.0, (double previousValue, InDetail element) {
                                                      return previousValue +
                                                          element.qtuom;
                                                    })}',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )
                                              : Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    _CalculTotalpcswithdoc(
                                                        item.detail),
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                )),
                                          DataCell(Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item.updatedby,
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          )),
                                          DataCell(Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              globalVM.stringToDateWithHour(
                                                  item.updated),
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          )),
                                          DataCell(Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              item.flag == "Y"
                                                  ? item.mblnr
                                                  : "",
                                              style: TextStyle(fontSize: 12),
                                              textAlign: TextAlign.left,
                                            ),
                                          )),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    )
                  ],
                ));
              })))),
    );
  }
}
