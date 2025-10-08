import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/inputstocktake.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:immobile/page/countedPage.dart';
// import 'package:immobile/model/inmodel.dart';
import 'package:immobile/model/stocktake.dart';
import 'package:immobile/model/stocktakedetail.dart';
// import 'package:immobile/viewmodel/// inVM.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/stocktickvm.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/widget/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StockTakeDetail extends StatefulWidget {
  final StocktickModel stocktake;
  final int index;
  final String documentno;
  const StockTakeDetail(this.stocktake, this.index, this.documentno);
  @override
  _StockTakeDetail createState() => _StockTakeDetail();
}

class _StockTakeDetail extends State<StockTakeDetail> {
  bool _allow = true;
  int idPeriodSelected = 1;
  String namechoice;
  ValueNotifier<List<String>> sortListBatch = ValueNotifier([]);
  ValueNotifier<List<String>> sortListSection = ValueNotifier([]);
  GlobalVM globalvm = Get.find();
  StockTickVM stocktickvm = Get.find();
  List<ItemChoice> listchoice = [];
  List<ItemChoice> listchoice2 = [];
  List<Category> listcategory = [];
  ScrollController controller;
  bool _leading = true;
  GlobalKey srKey = GlobalKey();
  bool _isSearching = false;
  TextEditingController _searchQuery;
  String searchQuery, barcodeScanRes;
  List<StockTakeDetailModel> detaillocal = [];
  ValueNotifier<String> selectedSection = ValueNotifier("");
  ValueNotifier<String> selectedBatch = ValueNotifier("");
  int typeIndexbox = 0;
  double typeIndexbun = 0;
    ValueNotifier<double> totalinput = ValueNotifier(0.0);
  ValueNotifier<double> bun = ValueNotifier(0.0);
  ValueNotifier<int> box = ValueNotifier(0);
  ValueNotifier<double> localpcsvalue = ValueNotifier(0.0);
  ValueNotifier<int> localctnvalue = ValueNotifier(0);
  ValueNotifier<double> stockbun = ValueNotifier(0.0);
  ValueNotifier<String> totalbox = ValueNotifier("");
  ValueNotifier<String> totalbun = ValueNotifier("");
  ValueNotifier<double> stockbox = ValueNotifier(0.0);
   ValueNotifier<bool> checkboxvalidation = ValueNotifier(false);
  var choicein = "".obs;
  TextEditingController _controllerbox;
  TextEditingController _controllerbun;
  int tabs = 0;
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("BUN"),
    1: Text("BOX")
  };
  FocusNode _focusNode = FocusNode();
  int localctn = 0;
  double localpcs = 0.0;
  static const MethodChannel methodChannel =
      MethodChannel('id.co.cp.immobile/command');
  static const EventChannel scanChannel =
      EventChannel('id.co.cp.immobile/scan');
  String _barcodeString = "Barcode will be shown here";
  String _barcodeSymbology = "Symbology will be shown here";
  String _scanTime = "Scan Time will be shown here";

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    if (sortListSection.value.length == 0) {
      fetchSectionFromFirestore();
    }
    stocktickvm.document.value = widget.stocktake.documentno;

    stocktickvm.forDetail();

 var testing =   stocktickvm.newListToDocument(namechoice, stocktickvm.document.value).length;
  print(testing);
    _createProfile("DataWedgeFlutterDemo");
  }

Future<void> fetchSectionFromFirestore() async {
  final snapshot = await FirebaseFirestore.instance.collection('stocktakes-section').where('LGORT', arrayContainsAny: widget.stocktake.LGORT).get();

  if (snapshot.docs.isNotEmpty) {
    List<String> tempList = [];

    for (var doc in snapshot.docs) {
      final sectionData = doc['section'];

      if (!sortListSection.value.contains(sectionData)) {
        tempList.add(sectionData);
      }
    }

    tempList.sort();

    sortListSection.value.addAll(tempList);
  }
}

  String _convertphysicaltobox(StockTakeDetailModel item,String validation){
    String stringumrez = "";
    double umrez = 0.0;
    if(validation == "KG"){
 var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR && element.selectedChoice == item.selectedChoice)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH == "KG").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
  }
    } else {
       var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR && element.selectedChoice == item.selectedChoice)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    } else {
       var listumrez = item.MARM;
       stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
   
 
  }
    }
   
     return umrez.toString();
  }

   String _CalculTotalbun(StockTakeDetailModel item, String validation) {
    
   
    double total = 0;
     double parseumren = 0.0;
    String stringumrez = "";
    double umrez = 0.0;
    if(validation != "KG"){
 var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR && element.selectedChoice == item.selectedChoice)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    } else {
       var listumren  = item.MARM;
    stringumrez = listumren[0].UMREN;
      umrez = double.parse(stringumrez);
    }
    parseumren = (calcu[j].count_box * umrez);
      total += parseumren += calcu[j].count_bun;
    }
    } else {
 var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR && element.selectedChoice == item.selectedChoice)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH == "KG").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
    parseumren = (calcu[j].count_box * umrez);
      total += parseumren += calcu[j].count_bun;
    }
    }
   
    String totalstring = total.toString();
    return totalstring;
  }

 
  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
    }
  }

  String conversion(StockTakeDetailModel models,String name,String validation){
    try{
 double parseumren = 0.0;
    String stringumren = "";
    String stringumrez = "";
    double umren = 0.0;
    double umrez = 0.0;
    if(name == "KG"){
    var listumren  = models.MARM.where((element) => element.MEINH == "KG").toList();
    if(listumren.length != 0){
    stringumren = listumren[0].UMREN;
      umren = double.parse(stringumren);
    }

    var listumrez = models.MARM.where((element) => element.MEINH == "KG").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }

    } else {
     if(validation == "Bukan Tampilan"){
    var listumren  = models.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "BOX").toList();
    print(listumren);
    if(listumren.length != 0){
    stringumren = listumren[0].UMREN;
      umren = double.parse(stringumren);
    } else {
       var listumren  = models.MARM;
    stringumren = listumren[0].UMREN;
      umren = double.parse(stringumren);
    }

    var listumrez = models.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    if(listumrez.length != 0){
    stringumrez = listumren[0].UMREZ;
      umrez = double.parse(stringumrez);
    }  else {
       var listumren  = models.MARM;
     stringumrez = listumren[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
     } else {
    var listumren  = models.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    print(listumren);
    if(listumren.length != 0){
    stringumren = listumren[0].UMREN;
      umren = double.parse(stringumren);
    } else {
       var listumren  = models.MARM;
    stringumren = listumren[0].UMREN;
      umren = double.parse(stringumren);
    }

    var listumrez = models.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    if(listumrez.length != 0){
    stringumrez = listumren[0].UMREZ;
      umrez = double.parse(stringumrez);
    }  else {
       var listumren  = models.MARM;
     stringumrez = listumren[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
     }

    }

if(models.selectedChoice == "UU"){
  parseumren = (models.LABST / umrez) * umren.toInt();
} else if(models.selectedChoice == "QI"){
  parseumren = (models.INSME / umrez) * umren.toInt();
} else {
  parseumren = (models.SPEME / umrez) * umren.toInt();
}

return parseumren.toStringAsFixed(1).toString();
   
    }catch(e){
      print(e);
    }
    
  }

  void getchoicechip() async {
    try {
      listcategory = await DatabaseHelper.db.getCategorywithrole("STOCKTAKE");

      setState(() {
        for (int i = 0; i < listcategory.length; i++) {
          ItemChoice choicelocal = ItemChoice(
              id: i + 1,
              label: listcategory[i].inventory_group_id,
              labelname: listcategory[i].inventory_group_name);
          listchoice.add(choicelocal);

        }
        namechoice = listchoice[0].label;
        if (listcategory.length != 0) {
        }
      });
    } catch (e) {
      print(e);
    }
  }

  String _CalculTotalStockPCS(StockTakeDetailModel item, String flag) {
    if (flag == "stock") {
      int total = 0;
      var calcu = stocktickvm.tolistdocument
          .singleWhere((element) => element.documentno == widget.documentno)
          .detail
          .where((element) => element.MATNR == item.MATNR)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].LABST.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    } else {
      int total = 0;
      var calcu = stocktickvm.tolistforinputstocktake
          .where((element) => element.matnr == item.MATNR)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].count_bun.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    }
  }

  String _CalculTotalStockCTN(StockTakeDetailModel item, String flag) {
    if (flag == "stock") {
      int total = 0;
      var calcu = stocktickvm.tolistdocument
          .singleWhere((element) => element.documentno == widget.documentno)
          .detail
          .where((element) => element.MATNR == item.MATNR)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].LABST.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    } else {
      int total = 0;
      var calcu = stocktickvm.tolistforinputstocktake
          .where((element) => element.matnr == item.MATNR)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].count_box.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    }
  }

  String _Calcultotalbox(StockTakeDetailModel item) {
    double total = 0;
    var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.batchid == item.MATNR && element.matnr == item.MATNR)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
      //print(widget.controllers[i].text);
      total += calcu[j].count_box;
    }
    String totalstring = total.toString();
    return totalstring;
  }

  String _CalculTotalpcs(StockTakeDetailModel item) {
    double total = 0;
    var calcu = stocktickvm.tolistforinputstocktake.value
        .where((element) => element.batchid == item.MATNR && element.matnr == item.MATNR)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
      total += calcu[j].count_bun;
    }
    String totalstring = total.toString();
    return totalstring;
  }

  Future _showMyDialog(StockTakeDetailModel indetail, String type) async {
  double baseWidth = 312;
  double fem = MediaQuery.of(context).size.width / baseWidth;
  double ffem = fem * 0.97;
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // user must tap button!
      builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                content: Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Text(
                              '${indetail.NORMT.trim()}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Text(
                              '${indetail.MAKTX}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: CupertinoSlidingSegmentedControl(
                            groupValue: tabs,
                            children: myTabs,
                            onValueChanged: (i) {
                              setState(() {
                                tabs = i;
                                tabs == 0 ? type = "bun" : type = "box";

                                // Reset controllers for box and bun
                                if (type == "box") {
                                  _controllerbox = TextEditingController(
                                      text: typeIndexbox.toString());
                                } else {
                                  _controllerbun = TextEditingController(
                                      text: typeIndexbun.toString());
                                }
                              });
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          // Decrement Button
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              child: Center(
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  if (type == "box" && typeIndexbox > 0) {
                                    typeIndexbox--;
                                    _controllerbox =
                                        TextEditingController(
                                            text: typeIndexbox.toString());
                                  } else if (type == "bun" &&
                                      typeIndexbun > 0) {
                                    typeIndexbun--;
                                    _controllerbun =
                                        TextEditingController(
                                            text: typeIndexbun.toString());
                                  }
                                });
                              },
                            ),
                          ),
                          // Input Field
                          Container(
                            width: 100,
                            height: 50,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              controller: type == "box"
                                  ? _controllerbox
                                  : _controllerbun,
                              onChanged: (i) {
                                try {
                                  setState(() {
                                    if (type == "box") {
                                      typeIndexbox =
                                          int.parse(_controllerbox.text);
                                    } else {
                                      typeIndexbun =
                                          double.parse(_controllerbun.text);
                                    }
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              },
                            ),
                          ),
                          // Increment Button
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              child: Center(
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  if (type == "box") {
                                    typeIndexbox++;
                                    _controllerbox =
                                        TextEditingController(
                                            text: typeIndexbox.toString());
                                  } else {
                                    typeIndexbun++;
                                    _controllerbun =
                                        TextEditingController(
                                            text: typeIndexbun.toString());
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Save and Cancel Buttons
                      Container(
                        width: double.infinity,
                        height: 25 * fem,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    20 * fem, 0 * fem, 16 * fem, 0 * fem),
                                padding: EdgeInsets.fromLTRB(
                                    24 * fem, 5 * fem, 25 * fem, 5 * fem),
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xfff44236)),
                                  color: Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(12 * fem),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 30 * fem,
                                    height: 30 * fem,
                                    child: Image.asset(
                                      'data/images/cancel-viF.png',
                                      width: 30 * fem,
                                      height: 30 * fem,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                Get.back();
                              },
                            ),
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    24 * fem, 5 * fem, 25 * fem, 5 * fem),
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xff2cab0c),
                                  borderRadius: BorderRadius.circular(12 * fem),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x3f000000),
                                      offset: Offset(0 * fem, 4 * fem),
                                      blurRadius: 2 * fem,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 30 * fem,
                                    height: 30 * fem,
                                    child: Image.asset(
                                      'data/images/check-circle-fg7.png',
                                      width: 30 * fem,
                                      height: 30 * fem,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                box.value = typeIndexbox;
                                bun.value = typeIndexbun;
                                double total = 0.0;
                                double totalpcslocal = 0.0;

                                var calcu = stocktickvm.tolistforinputstocktake
                                    .where((element) =>
                                        element.matnr == indetail.MATNR)
                                    .toList();

                                if (calcu.isEmpty) {
                                  totalbox.value = box.value.toString();
                                  totalbun.value = bun.value.toString();
                                } else {
                                  for (var j = 0; j < calcu.length; j++) {
                                    if (calcu[j].section == selectedSection.value) {
                                      // section-specific logic
                                    } else {
                                      total += calcu[j].count_box;
                                    }
                                  }
                                  total += box.value;
                                  totalbox.value = total.toString();

                                  for (var j = 0; j < calcu.length; j++) {
                                    totalpcslocal += calcu[j].count_bun;
                                  }

                                  totalpcslocal += bun.value;
                                  totalbun.value = totalpcslocal.toString();
                                }
                                // totalinput.value = box.value + bun.value;
                                Get.back();
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
}



 
Widget headerCard2(StockTakeDetailModel inmodel) {
  double baseWidth = 360;
  double fem = MediaQuery.of(context).size.width / baseWidth;
  double ffem = fem * 0.97;

  return Container(
    margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 10 * fem, 10 * fem),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10 * fem),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8 * fem),
            boxShadow: [
              BoxShadow(
                color:  Color(0x3f000000),
                offset: Offset(0, 6 * fem),
                blurRadius: 5 * fem,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          inmodel.MAKTX,
                          style: TextStyle(
                            fontSize: 16 * ffem,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5 * fem),
               Container(
                width: Get.width,
                alignment: Alignment.center,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Define a list of choices
                    ...["UU", "QI", "BLOCK"].map((choice) {
                      return ChoiceChip(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        labelStyle: TextStyle(
                          color: (Theme.of(context).backgroundColor == Colors.grey[100]
                              ? (inmodel.selectedChoice == choice
                                  ? Colors.white
                                  : Colors.white)
                              : (inmodel.selectedChoice == choice
                                  ? Colors.white
                                  : Colors.white)),
                        ),
                        backgroundColor: Theme.of(context).backgroundColor == Colors.grey[100]
                            ? Colors.grey
                            : Colors.grey,
                        label: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            choice, // The choice name (e.g., 'UU', 'QI', 'BLOCK')
                            style: TextStyle(fontSize: 16 * ffem),
                          ),
                        ),
                        selected: inmodel.selectedChoice == choice, // Check if this choice is selected
                        onSelected: (isSelected) {
                          if (isSelected) {
                            setState(() {
                              inmodel.selectedChoice = choice; // Update the selected choice for this item
                            });
                          }
                        },
                        selectedColor: choice == "UU"
                            ? Colors.green // Green for "UU"
                            : choice == "QI"
                                ? Colors.orange[500] // Yellow for "QI"
                                : choice == "BLOCK"
                                    ? Colors.red // Red for "BLOCK"
                                    : Color(0xfff44236), // Default color
                        elevation: 10,
                      );
                    }).toList(),
                  ],
                  spacing: 5,
                ),
                padding: EdgeInsets.only(right: 10),
              )
                     ],
                    ),
                  ),
                  SizedBox(width: 10 * fem),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                        'Kode Box: ${inmodel.NORMT}',
                        style: TextStyle(
                          fontSize: 14 * ffem,
                         fontWeight: FontWeight.bold,
                            color: Colors.black,
                        ),
                      ),
                       Text(
                        'SKU: ${inmodel.MATNR}',
                        style: TextStyle(
                          fontSize: 14 * ffem,
                        fontWeight: FontWeight.bold,
                            color: Colors.black,
                        ),
                      ),
                    
                     
                    ],
                  ),
     Container(
  width: 20,
  child: ValueListenableBuilder<bool>(
    valueListenable: inmodel.checkboxvalidation,
    builder: (context, value, child) {
      return Checkbox(
        value: value,
        onChanged: (bool newValue) async {
          inmodel.checkboxvalidation.value = newValue ?? false;
          stocktickvm.updatedetailtick(widget.documentno,stocktickvm.tolistdocumentnosame
                                            .singleWhere((element) =>
                                                element.documentno ==
                                                widget.documentno).detail);

          // DateTime now = DateTime.now();
          // String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

          // InputStockTake input = InputStockTake();
          // input.section = selectedSection.value;
          // input.count_box = box.value;
          // input.count_bun = bun.value;
          // input.created = formattedDate;
          // input.createdby = globalvm.username.value;
          // input.documentno = widget.stocktake.documentno;
          // input.batchid = selectedBatch.value;
          // input.matnr = inmodel.MATNR;
          // input.selectedChoice = inmodel.selectedChoice;

          // DateTime originalTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.stocktake.created);
          // DateTime updatedTime = originalTime.add(Duration(hours: 7));
          // String result = DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedTime);
          // input.DOWNLOADTIME = result;

          // input.SAP_STOCK_BUN = '${conversion(inmodel, "Bun", "Bukan Tampilan")}';
          // input.istick = inmodel.checkboxvalidation.value;

          // var listumrez = inmodel.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
          // if (listumrez.isNotEmpty) {
          //   input.unit_box = listumrez[0].MEINH;
          // } else {
          //   var listpcs = inmodel.MARM.where((element) => element.UMREZ.contains("1")).toList();
          //   input.unit_box = listpcs[0].MEINH;
          // }

          // var listpcs = inmodel.MARM.where((element) => element.MEINH != "KG" && element.UMREZ.contains("1")).toList();
          // if (listpcs.isNotEmpty) {
          //   input.unit_bun = listpcs[0].MEINH;
          // } else {
          //   var fallback = inmodel.MARM.where((element) => element.UMREZ.contains("1")).toList();
          //   input.unit_bun = fallback[0].MEINH;
          // }

          // input.sloc = inmodel.LGORT;
          // input.plant = inmodel.WERKS;

          // String baseSection = selectedSection.value.split('-')[0];
          // var existing = sortListSection.value.where((e) => e.startsWith('$baseSection-')).toList();
          // int nextIndex = existing.length + 1;
          // String newSection = '$baseSection-$nextIndex';
          // sortListSection.value.add(newSection);
          // selectedSection.value = newSection;

          // bun.value = 0;
          // box.value = 0;

          // // Awaited async operations
          // await stocktickvm.sendtohistory(input);
          // await stocktickvm.forcounted(input);
        },
      );
    },
  ),
)


                ],
              ),
              SizedBox(height: 10 * fem),

              // Data Table Section
Container(
  width: Get.width,
  child:   DataTable(
    dataRowHeight: 40.0,
    columnSpacing: 20.0, // Adjust overall column spacing
    horizontalMargin: 0.5,
    dividerThickness: 1, // Divider line thickness
    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[800]),
    headingTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[900]),
    columns: [
      DataColumn(label: Container(padding: EdgeInsets.only(left: 10), child: Text('Unit'))),
      DataColumn(label: Text('Bun')),
      DataColumn(label: Text('Box')),
      DataColumn(label: Text('KG')),
      // DataColumn(label: Text('Total')), // Total column
    ],
   rows: stocktickvm.tolistdocument
    .singleWhere((element) => element.documentno == widget.documentno) // Filter by documentno
    .detail
    .where((element) => element.MATNR == inmodel.MATNR) // Filter by MATNR
    .toList() // Convert to list
    .map((item) {
      return [
        // Stock Row
        DataRow(cells: [
          DataCell(Container(
            color: Colors.grey[800],
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )),
          DataCell(Align(
            alignment: Alignment.centerRight,
            child: Text(inmodel.selectedChoice == "UU"?'${item.LABST}':inmodel.selectedChoice == "QI" ? '${item.INSME}': '${item.SPEME}', style: TextStyle(color: Colors.white)),
          )),
          DataCell(Align(
            alignment: Alignment.centerRight,
            child: Text('${conversion(item, "Box","tampilan")}', style: TextStyle(color: Colors.white)),
          )),
          DataCell(Align(
            alignment: Alignment.centerLeft,
            child: Text('${conversion(item, "KG","tampilan")}', style: TextStyle(color: Colors.white)),
          )),
        ]),

        // Physical Row
        DataRow(cells: [
          DataCell(Container(
            color: Colors.grey[800],
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Physical', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )),
          DataCell(Align(
            alignment: Alignment.centerRight,
            child: Text('${_CalculTotalbun(inmodel,"Bun")}', style: TextStyle(color: Colors.white)),
          )),
       DataCell(Align(
  alignment: Alignment.centerRight,
  child: Text(
    (() {
      final total = double.parse(_CalculTotalbun(inmodel, "Box"));
      final physical = double.parse(_convertphysicaltobox(inmodel, "Box"));
      if (total == 0.0 && physical == 0.0) return '0.0';
      final result = total / physical;
      return result.toStringAsFixed(1); // <-- Tampilkan 1 angka di belakang koma
    })(),
    style: TextStyle(color: Colors.white),
  ),
)),


          // DataCell(Align(
          //   alignment: Alignment.centerRight,
          //   child: Text(double.parse(_CalculTotalbun(inmodel,"Box")) == 0.0 && double.parse(_convertphysicaltobox(inmodel,"Box")) == 0.0 ? '0.0': '${double.parse(_CalculTotalbun(inmodel,"Box")) / double.parse(_convertphysicaltobox(inmodel,"Box"))}', style: TextStyle(color: Colors.white)),
          // )),
          // DataCell(Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(double.parse(_CalculTotalbun(inmodel,"Box")) == 0.0 && double.parse(_convertphysicaltobox(inmodel,"Box")) == 0.0 ? '0.0' :'${double.parse(_CalculTotalbun(inmodel,"Box")) / double.parse(_convertphysicaltobox(inmodel,"KG"))}', style: TextStyle(color: Colors.white)),
          // )),
          DataCell(
  Align(
    alignment: Alignment.centerLeft,
    child: Text(
      (() {
        final total = double.parse(_CalculTotalbun(inmodel, "KG"));
        final physical = double.parse(_convertphysicaltobox(inmodel, "KG")); // "KG" diganti ke "Box"
        if (total == 0.0 && physical == 0.0) return '0.0';
        return (total / physical).toStringAsFixed(1);
      })(),
      style: TextStyle(color: Colors.white),
    ),
  ),
),

        ]),

        // Different Row
        DataRow(cells: [
          DataCell(Container(
            color: Colors.grey[800],
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Different', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )),
         DataCell(Align(
  alignment: Alignment.centerRight,
  child: Text(
    item.selectedChoice == "UU"
      ? '${(double.parse(_CalculTotalbun(inmodel,"Bun")) - item.LABST).toStringAsFixed(2)}'
      : item.selectedChoice == "QI"
        ? '${(double.parse(_CalculTotalbun(inmodel,"Bun")) - item.INSME).toStringAsFixed(2)}'
        : '${(double.parse(_CalculTotalbun(inmodel,"Bun")) - item.SPEME).toStringAsFixed(2)}',
    style: TextStyle(color: Colors.white),
  ),
)),
DataCell(Align(
  alignment: Alignment.centerRight,
  child: Text(
    double.parse(_CalculTotalbun(inmodel,"Box")) == 0.0 && double.parse(_convertphysicaltobox(inmodel,"Box")) == 0.0 
      ? '0.0'
      : '${(double.parse(_CalculTotalbun(inmodel,"Box")) / double.parse(_convertphysicaltobox(inmodel,"Box")) - double.parse(conversion(item, "Box","tampilan"))).toStringAsFixed(2)}',
    style: TextStyle(color: Colors.white),
  ),
)),
DataCell(Align(
  alignment: Alignment.centerLeft,
  child: Text(
    double.parse(_CalculTotalbun(inmodel,"Box")) == 0.0 && double.parse(_convertphysicaltobox(inmodel,"Box")) == 0.0 
      ? '0.0'
      : '${(double.parse(_CalculTotalbun(inmodel,"Box")) / double.parse(_convertphysicaltobox(inmodel,"KG")) - double.parse(conversion(item, "KG","tampilan"))).toStringAsFixed(2)}',
    style: TextStyle(color: Colors.white),
  ),
)),

        ]),
      ];
    }).expand((element) => element).toList(), // Flatten the list of rows
 ),
)
      ]),
        ),
      ],
    ),
  );
}

  Widget modalBottomSheet(
      StockTakeDetailModel indetail, List<StockTakeDetailModel> inDetailList) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    sortListSection.value.sort();
    return SingleChildScrollView(
      child: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        height: Get.height * 0.80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
               child: Text(
                  ' Edit - ${indetail.NORMT.trim()} ${indetail.MAKTX}',
                  style: SafeGoogleFont(
                    'Roboto',
                    fontSize: 16 * ffem,
                    fontWeight: FontWeight.w600,
                    height: 1.1725 * ffem / fem,
                    color: Color(0xfff44236),
                  ),
                ),
              ),
              Container(
                child: GestureDetector(
                  child: Image.asset(
                    'data/images/cancel-viF.png',
                    width: 30 * fem,
                    height: 30 * fem,
                  ),
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
            ]),
            Container(
              // line1Wzw (11:1250)
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
              width: double.infinity,
              height: 1 * fem,
              decoration: BoxDecoration(
                color: Color(0xffa8a8a8),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.fromLTRB(120 * fem, 0 * fem, 120 * fem, 6 * fem),
              padding:
                  EdgeInsets.fromLTRB(5 * fem, 31 * fem, 6.01 * fem, 31 * fem),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(8 * fem),
              ),
              child: Center(
                // image7rxK (13:505)
                child: SizedBox(
                    width: 108.99 * fem,
                    height: 58 * fem,
                    child: Image.asset(
                      'data/images/no_image.png',
                      width: 80 * fem,
                      height: 80 * fem,
                    )),
              ),
            ),
            Container(
              // line2wTy (13:502)
              width: double.infinity,
              height: 1 * fem,
              decoration: BoxDecoration(
                color: Color(0xffa8a8a8),
              ),
            ),
            Container(
              // autogroupnv31UTu (UM6eXdhH31hUxLWjPMnV31)
              padding:
                  EdgeInsets.fromLTRB(16 * fem, 5 * fem, 16 * fem, 8 * fem),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                   width: double.infinity,
                    height: 46 * fem,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          // requestdateRh5 (13:2224)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 16 * fem, 0 * fem),
                          width: 160 * fem,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle175Fq (13:2225)
                                left: 0 * fem,
                                top: 6 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 160 * fem,
                                    height: 40 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4 * fem),
                                        border: Border.all(
                                            color: Color(0xff9c9c9c)),
                                        color: Color(0xffe0e0e0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // rectangle18NeF (13:2226)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 40.77 * fem,
                                    height: 11 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // requestdatemAb (13:2227)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 66 * fem,
                                    height: 13 * fem,
                                    child: Text(
                                      'Material',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 11 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // SAF (13:2228)
                                left: 10.8754882812 * fem,
                                top: 15 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 150 * fem,
                                    height: 19 * fem,
                                    child: Text(
                                      "${indetail.MATNR}",
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // stockrequestQWP (13:2219)
                          width: 150 * fem,
                          height: 45 * fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle17EEX (13:2220)
                                left: 0 * fem,
                                top: 5 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 150 * fem,
                                    height: 40 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4 * fem),
                                        border: Border.all(
                                            color: Color(0xff9c9c9c)),
                                        color: Color(0xffe0e0e0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // rectangale18QoD (13:2221)
                                left: 16 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 60 * fem,
                                    height: 11 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // stockrequestp6F (13:2222)
                                left: 16.6667480469 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 71 * fem,
                                    height: 13 * fem,
                                    child: Text(
                                      'Compatible',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 11 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // bgsr000001Fqm (13:2223)
                                left: 12.2221679688 * fem,
                                top: 15 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 95 * fem,
                                    height: 19 * fem,
                                    child: Text(
                            indetail.MARM.length == 0 ? "1 X 0":indetail.MARM.length == 1 ? "1 X ${indetail.MARM[0].UMREZ.trim()}": "1 X ${indetail.MARM.where((element) => element.MEINH == "KG").toList()[0].UMREZ.trim()}",
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 16 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // materialdescriptioninput9Eb (11:1256)
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 0 * fem, 11 * fem),
                    width: double.infinity,
                    height: 45 * fem,
                    child: Stack(
                      children: [
                        Positioned(
                          // rectangle17RT1 (11:1257)
                          left: 0 * fem,
                          top: 5 * fem,
                          child: Align(
                            child: SizedBox(
                              width: 328 * fem,
                              height: 40 * fem,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4 * fem),
                                  border: Border.all(color: Color(0xff9c9c9c)),
                                  color: Color(0xffe0e0e0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          // rectangle18JWo (11:1258)
                          left: 11 * fem,
                          top: 0 * fem,
                          child: Align(
                            child: SizedBox(
                              width: 105 * fem,
                              height: 11 * fem,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          // materialdescriptionZhd (11:1259)
                          left: 12 * fem,
                          top: 0 * fem,
                          child: Align(
                            child: SizedBox(
                              width: 99 * fem,
                              height: 13 * fem,
                              child: Text(
                                'Material Description',
                                style: SafeGoogleFont(
                                  'Roboto',
                                  fontSize: 11 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1725 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          // vitasoylemonteadrink250mlEHy (11:1260)
                          left: 10 * fem,
                          top: 15 * fem,
                          child: Align(
                            child: SizedBox(
                              width: GlobalVar.width,
                              height: 19 * fem,
                              child: Text(
                                '${indetail.NORMT.trim()} ${indetail.MAKTX}',
                                style: SafeGoogleFont(
                                  'Roboto',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1725 * ffem / fem,
                                  color: Color(0xff2d2d2d),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                   width: double.infinity,
                    height: 46 * fem,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          // requestdateRh5 (13:2224)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 16 * fem, 0 * fem),
                          width: 160 * fem,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle175Fq (13:2225)
                                left: 0 * fem,
                                top: 6 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 160 * fem,
                                    height: 40 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4 * fem),
                                        border: Border.all(
                                            color: Color(0xff9c9c9c)),
                                        color: Color(0xffe0e0e0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // rectangle18NeF (13:2226)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 50.77 * fem,
                                    height: 11 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // requestdatemAb (13:2227)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 80 * fem,
                                    height: 13 * fem,
                                    child: Text(
                                      'Stock Bun',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 11 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // SAF (13:2228)
                                left: 10.8754882812 * fem,
                                top: 15 * fem,
                                child: ValueListenableBuilder(
                                    valueListenable: stockbun,
                                    builder: (BuildContext context, double value,
                                        Widget child) {
                                      return Align(
                                        child: SizedBox(
                                          width: 150 * fem,
                                          height: 19 * fem,
                                          child: Text(
                                            "${value}",
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 16 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.1725 * ffem / fem,
                                              color: Color(0xff000000),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          // stockrequestQWP (13:2219)
                          width: 150 * fem,
                          height: 45 * fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle17EEX (13:2220)
                                left: 0 * fem,
                                top: 5 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 150 * fem,
                                    height: 40 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4 * fem),
                                        border: Border.all(
                                            color: Color(0xff9c9c9c)),
                                        color: Color(0xffe0e0e0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // rectangle18QoD (13:2221)
                                left: 16 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 55 * fem,
                                    height: 11 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // stockrequestp6F (13:2222)
                                left: 16.6667480469 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 90 * fem,
                                    height: 13 * fem,
                                    child: Text(
                                      'Stock BOX',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 11 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // bgsr000001Fqm (13:2223)
                                left: 12.2221679688 * fem,
                                top: 15 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 95 * fem,
                                    height: 19 * fem,
                                    child: ValueListenableBuilder(
                                      valueListenable: stockbox,
                                      builder: (context, value, child) => Text(
                                        "${conversion(indetail,"Box","tampilan")}",
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.1725 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                   width: double.infinity,
                    height: 46 * fem,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                               Expanded(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 10 * fem, 0 * fem),
                                        height: double.infinity,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 0 * fem,
                                              top: 6 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 100 * fem,
                                                  height: 40 * fem,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4 * fem),
                                                      border: Border.all(
                                                          color: Color(
                                                              0xff9c9c9c)),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 15.5844726562 * fem,
                                              top: 0 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 73.77 * fem,
                                                  height: 11 * fem,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffffffff),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 15.5844726562 * fem,
                                              top: 0 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 66 * fem,
                                                  height: 13 * fem,
                                                  child: Text(
                                                    'Section',
                                                    style: TextStyle(
                                                      fontSize: 11 * ffem,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff000000),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                       Positioned(
                                      left: 10.8754882812 * fem,
                                      top: 15 * fem,
                                      child: Align(
                                        child: SizedBox(
                                          width: 150 * fem,
                                          height: 19 * fem,
                                          child: ValueListenableBuilder<String>(
                                            valueListenable: selectedSection,
                                            builder: (BuildContext context, String newValue, Widget child) {
                                              return ValueListenableBuilder<List<String>>(
                                                valueListenable: sortListSection, // Listen for changes in sortListSection
                                                builder: (BuildContext context, List<String> sectionList, Widget child) {
                                                  return DropdownButton<String>(
                                                    value: newValue,
                                                    onChanged: (String newValue) {
                                                      selectedSection.value = newValue;
                                                      var calculate = stocktickvm.tolistforinputstocktake.value
                                                          .where((element) =>
                                                              element.batchid == selectedBatch.value &&
                                                              element.section == selectedSection.value &&
                                                              element.matnr == indetail.MATNR
                                                              && element.selectedChoice == indetail.selectedChoice)
                                                          .toList();
                                                      if (calculate.isEmpty) {
                                                        bun.value = 0;
                                                        box.value = 0;
                                                      } else {
                                                        localpcs = 0;
                                                        localctn = 0;
                                                        for (var input in calculate) {
                                                          localpcs += input.count_bun;
                                                          localctn += input.count_box;
                                                        }
                                                        bun.value = localpcs;
                                                        box.value = localctn;
                                                      }
                                                    },
                                                    items: sectionList.map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    style: TextStyle(
                                                      fontSize: 16 * ffem,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                    underline: Container(),
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black,
                                                    ),
                                                    dropdownColor: Colors.white,
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
),
   ],
                                        ),
                                      ),
                                    ),
                             Container(
                          // requestdateRh5 (13:2224)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 10 * fem, 0 * fem),
                          width: 100 * fem,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle175Fq (13:2225)
                                left: 0 * fem,
                                top: 6 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 100 * fem,
                                    height: 40 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4 * fem),
                                        border: Border.all(
                                            color: Color(0xff9c9c9c)),
                                        color: Color(0xffe0e0e0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // rectangle18NeF (13:2226)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 78.77 * fem,
                                    height: 11 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // requestdatemAb (13:2227)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 100 * fem,
                                    height: 12 * fem,
                                    child: Text(
                                      'Total Physical Bun',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 10 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                  valueListenable: bun,
                                  builder: (BuildContext context, double value,
                                      Widget child) {
                                    return Positioned(
                                      // bgsr000001Fqm (13:2223)
                                      left: 12.2221679688 * fem,
                                      top: 15 * fem,
                                      child: Align(
                                        child: SizedBox(
                                          width: 95 * fem,
                                          height: 19 * fem,
                                          child: Text(
                                            value.toString(),
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 16 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.1725 * ffem / fem,
                                              color: Color(0xff000000),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
                        Container(
                          // requestdateRh5 (13:2224)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 6 * fem, 0 * fem),
                          width: 102 * fem,
                          height: double.infinity,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle175Fq (13:2225)
                                left: 0 * fem,
                                top: 6 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 102 * fem,
                                    height: 40 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4 * fem),
                                        border: Border.all(
                                            color: Color(0xff9c9c9c)),
                                        color: Color(0xffe0e0e0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // rectangle18NeF (13:2226)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 77.77 * fem,
                                    height: 11 * fem,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // requestdatemAb (13:2227)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 100 * fem,
                                    height: 13 * fem,
                                    child: Text(
                                      'Total Physical Box',
                                      style: SafeGoogleFont(
                                        'Roboto',
                                        fontSize: 10 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.1725 * ffem / fem,
                                        color: Color(0xff000000),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // SAF (13:2228)
                                left: 10.8754882812 * fem,
                                top: 15 * fem,
                                child: Align(
                                  child: SizedBox(
                                      width: 150 * fem,
                                      height: 19 * fem,
                                      child: ValueListenableBuilder(
                                          valueListenable: box,
                                          builder: (BuildContext context,
                                              int value, Widget child) {
                                            return Text(
                                              value.toString(),
                                              style: SafeGoogleFont(
                                                'Roboto',
                                                fontSize: 16 * ffem,
                                                fontWeight: FontWeight.w400,
                                                height: 1.1725 * ffem / fem,
                                                color: Color(0xff000000),
                                              ),
                                            );
                                          })),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                
                  Container(
                    width: double.infinity,
                    child: Row(
                     children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Container(
                      width: double.infinity,
                      height: 46 * fem,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                           Container(
                            width: 100 * fem,
                            child: GestureDetector(
                              onTap: () {
                                _controllerbox =
                                    TextEditingController(
                                        text: box.value.toString());
                                _controllerbun =
                                    TextEditingController(
                                        text: bun.value.toString());
                                typeIndexbox = box.value;
                                typeIndexbun = bun.value;
                                tabs = 0;
                                setState(() {
                                  _showMyDialog(indetail, "bun");
                                });
                              },
                              child: Container(
                                height: double.infinity,
                                child: Stack(
                                  children: [
                                    Container(
                                       height: double.infinity,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            // Background
                                            left: 0 * fem,
                                            top: 6 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 100 * fem,
                                                height: 40 * fem,
                                                child: Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                4 * fem),
                                                    border: Border.all(
                                                        color: Color(
                                                            0xff9c9c9c)),
                                                    color:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            // Rectangle
                                            left: 15.5844726562 * fem,
                                            top: 0 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 24.77 * fem,
                                                height: 11 * fem,
                                                child: Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    color:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            // Label
                                            left: 15.5844726562 * fem,
                                            top: 0 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 66 * fem,
                                                height: 13 * fem,
                                                child: Text(
                                                  'BUN',
                                                  style: TextStyle(
                                                    fontSize:
                                                        11 * ffem,
                                                    fontWeight:
                                                        FontWeight
                                                            .w400,
                                                    color: Color(
                                                        0xff000000),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ValueListenableBuilder(
                                              valueListenable: bun,
                                              builder: (BuildContext
                                                      context,
                                                  double value,
                                                  Widget child) {
                                                return Positioned(
                                                  // Value
                                                  left:
                                                      10.8754882812 *
                                                          fem,
                                                  top: 15 * fem,
                                                  child: Align(
                                                    child: SizedBox(
                                                      width:
                                                          150 * fem,
                                                      height:
                                                          19 * fem,
                                                      child: Text(
                                                        "${value}",
                                                        style:
                                                            TextStyle(
                                                          fontSize:
                                                              16 *
                                                                  ffem,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                          color: Color(
                                                              0xff000000),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                         SizedBox(width: 10),
                          // Physical PCS Widget
                          Container(
                            width: 100 * fem,
                            child: GestureDetector(
                              onTap: () async {
                                _controllerbox =
                                    TextEditingController(
                                        text: box.value.toString());
                                _controllerbun =
                                    TextEditingController(
                                        text: bun.value.toString());
                                typeIndexbox = box.value;
                                typeIndexbun = bun.value;
                                tabs = 1;
                                setState(() {
                                  _showMyDialog(indetail, "box");
                                });
                              },
                              child: Container(
                                height: double.infinity,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100 * fem,
                                      height: double.infinity,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            // Background
                                            left: 0 * fem,
                                            top: 6 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 100 * fem,
                                                height: 40 * fem,
                                                child: Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                4 * fem),
                                                    border: Border.all(
                                                        color: Color(
                                                            0xff9c9c9c)),
                                                    color:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            // Rectangle
                                            left: 15.5844726562 * fem,
                                            top: 0 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 25.77 * fem,
                                                height: 11 * fem,
                                                child: Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    color:
                                                        Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            // Label
                                            left: 15.5844726562 * fem,
                                            top: 0 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 66 * fem,
                                                height: 13 * fem,
                                                child: Text(
                                                  'BOX',
                                                  style: TextStyle(
                                                    fontSize:
                                                        11 * ffem,
                                                    fontWeight:
                                                        FontWeight
                                                            .w400,
                                                    color: Color(
                                                        0xff000000),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ValueListenableBuilder(
                                              valueListenable: box,
                                              builder: (BuildContext
                                                      context,
                                                  int value,
                                                  Widget child) {
                                                return Positioned(
                                                  // Value
                                                  left:
                                                      10.8754882812 *
                                                          fem,
                                                  top: 15 * fem,
                                                  child: Align(
                                                    child: SizedBox(
                                                      width:
                                                          150 * fem,
                                                      height:
                                                          19 * fem,
                                                      child: Text(
                                                        "${value}",
                                                        style:
                                                            TextStyle(
                                                          fontSize:
                                                              16 *
                                                                  ffem,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                          color: Color(
                                                              0xff000000),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
 ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            // width: 60 * fem,
                            height: 50 * fem,
                            padding: EdgeInsets.only(right: 10),
                           child: Image.asset(
                              'data/images/add_button.png',
                              // fit: BoxFit.cover,
                            ),
                          ),
                          onDoubleTap: () {},
                          onTap: () async {
                            if (box.value == 0 && bun.value == 0) {
  EasyLoading.showInfo('PCS AND CTN Cannot be 0', dismissOnTap: true);
} else {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

  InputStockTake input = InputStockTake();
  input.section = selectedSection.value;
  input.count_box = box.value;
  input.count_bun = bun.value;
  input.created = formattedDate;
  input.createdby = globalvm.username.value;
  input.documentno = widget.stocktake.documentno;
  input.batchid = selectedBatch.value;
  input.matnr = indetail.MATNR;
  input.selectedChoice = indetail.selectedChoice;
                 DateTime originalTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.stocktake.created);
  
  // Tambah 7 jam
  DateTime updatedTime = originalTime.add(Duration(hours: 7));
  
  // Format kembali ke string
  String result = DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedTime);
  
                                  input.DOWNLOADTIME = result;
  // input.SAP_STOCK_BOX = '${conversion(indetail, "Box")}';
  input.SAP_STOCK_BUN = '${conversion(indetail, "Bun","Bukan Tampilan")}';
input.istick = indetail.checkboxvalidation.value;
   
  var listumrez = indetail.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
  if (listumrez.isNotEmpty) {
     input.unit_box = listumrez[0].MEINH;
  } else {
  var listpcs = indetail.MARM.where((element) => element.UMREZ.contains("1")).toList();
  input.unit_box = listpcs[0].MEINH;
  }

  var listpcs = indetail.MARM.where((element) => element.MEINH != "KG" && element.UMREZ.contains("1")).toList();
  if (listpcs.isNotEmpty) {
  input.unit_bun = listpcs[0].MEINH;
  } else {
   var listpcs = indetail.MARM.where((element) => element.UMREZ.contains("1")).toList();
   input.unit_bun = listpcs[0].MEINH;
  }

  input.sloc = indetail.LGORT;
  input.plant = indetail.WERKS;

  // Logic untuk generate section baru A1-1, A1-2, A1-3 dst
  String baseSection = selectedSection.value.split('-')[0];

  // Cari semua section yang punya prefix A1-
  var existing = sortListSection.value.where((e) => e.startsWith('$baseSection-')).toList();

  // Hitung nomor berikutnya
  int nextIndex = existing.length + 1;

  // Generate nama section baru
  String newSection = '$baseSection-$nextIndex';

  // Tambahkan ke list
  sortListSection.value.add(newSection);

  // Set section barunya
  selectedSection.value = newSection;

  // Reset input box dan bun
  bun.value = 0;
  box.value = 0;

  // Proses ke API / Function
  await stocktickvm.sendtohistory(input);
  await stocktickvm.forcounted(input);
}

                          },
                        )
                   ,
     GestureDetector(
  child: Container(
    height: 50 * fem,
    padding: EdgeInsets.only(right: 5),
    child: Image.asset(
      'data/images/add_button_blue.png',
    ),
  ),
  onDoubleTap: () {},
  onTap: () async {
    if (box.value == 0 && bun.value == 0) {
      EasyLoading.showInfo('PCS AND CTN Cannot be 0', dismissOnTap: true);
    } else {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

      InputStockTake input = InputStockTake();
      input.section = selectedSection.value;
      input.count_box = box.value;
      input.count_bun = bun.value;
      input.created = formattedDate;
      input.createdby = globalvm.username.value;
      input.documentno = widget.stocktake.documentno;
      input.batchid = selectedBatch.value;
      input.matnr = indetail.MATNR;
      input.selectedChoice = indetail.selectedChoice;
      DateTime originalTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.stocktake.created);
  
  // Tambah 7 jam
  DateTime updatedTime = originalTime.add(Duration(hours: 7));
  
  // Format kembali ke string
  String result = DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedTime);
  
                                  input.DOWNLOADTIME = result;
    input.SAP_STOCK_BUN = '${conversion(indetail, "Bun","Bukan Tampilan")}';
input.istick = indetail.checkboxvalidation.value;
      var listumrez = indetail.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
      if (listumrez.isNotEmpty) {
        input.unit_box = listumrez[0].MEINH;
      }else {
  var listpcs = indetail.MARM.where((element) => element.UMREZ.contains("1")).toList();
  input.unit_box = listpcs[0].MEINH;
  }

      var listpcs = indetail.MARM.where((element) => element.MEINH != "KG" && element.UMREZ.contains("1")).toList();
      if (listpcs.isNotEmpty) {
        input.unit_bun = listpcs[0].MEINH;
      } else {
                                   var listpcs = indetail.MARM.where((element) => element.UMREZ.contains("1")).toList();
                                   input.unit_bun = listpcs[0].MEINH;
                                }

      input.sloc = indetail.LGORT;
      input.plant = indetail.WERKS;

      // Ambil prefix dan angka terakhir dari section yang dipilih
      String baseSection = selectedSection.value.split('-')[0];
      int currentNumber = int.tryParse(baseSection.substring(1)) ?? 0;

      // Tambah angka ke base section (misalnya A3 jadi A4)
      int newNumber = currentNumber + 1;

      // Buat section baru dengan angka yang telah ditambahkan
      String newSection = '${baseSection[0]}$newNumber-1';

      // Tambahkan ke list
      sortListSection.value.add(newSection);

      // Set section baru sebagai selected
      selectedSection.value = newSection;

      // Reset input box dan bun
      bun.value = 0;
      box.value = 0;

      // Proses ke API / Function
      await stocktickvm.sendtohistory(input);
      await stocktickvm.forcounted(input);
    }
  },
)

                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  //bates
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        150 * fem, 0 * fem, 0 * fem, 0 * fem),
                    width: double.infinity,
                    height: 40 * fem,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 16 * fem, 0 * fem),
                            padding: EdgeInsets.fromLTRB(
                                24 * fem, 5 * fem, 25 * fem, 5 * fem),
                            height: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xfff44236)),
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(12 * fem),
                            ),
                            child: Center(
                              // cancelnCK (11:1275)
                              child: SizedBox(
                                width: 30 * fem,
                                height: 30 * fem,
                                child: Image.asset(
                                  'data/images/cancel-viF.png',
                                  width: 30 * fem,
                                  height: 30 * fem,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              Get.back();
                            });
                          },
                        ),
                        GestureDetector(
                          child: Container(
                            // savebuttonSnf (11:1278)
                            padding: EdgeInsets.fromLTRB(
                                24 * fem, 5 * fem, 25 * fem, 5 * fem),
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xff2cab0c),
                              borderRadius: BorderRadius.circular(12 * fem),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x3f000000),
                                  offset: Offset(0 * fem, 4 * fem),
                                  blurRadius: 2 * fem,
                                ),
                              ],
                            ),
                            child: Center(
                              // checkcircle7du (11:1280)
                              child: SizedBox(
                                width: 30 * fem,
                                height: 30 * fem,
                                child: Image.asset(
                                  'data/images/check-circle-fg7.png',
                                  width: 30 * fem,
                                  height: 30 * fem,
                                ),
                              ),
                            ),
                          ),
                          onDoubleTap: () {},
                         onTap: () async {
  EasyLoading.show(
    status: 'Loading...',
    maskType: EasyLoadingMaskType.black,
  );

  indetail.isapprove = "Y";

  var detail = stocktickvm.tolistdocument
      .singleWhere((element) => element.documentno == widget.documentno)
      .detail;

  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

  InputStockTake input = InputStockTake();
  input.section = selectedSection.value;
  input.count_box = box.value;
  input.count_bun = bun.value;
  input.created = formattedDate;
  input.createdby = globalvm.username.value;
  input.documentno = widget.stocktake.documentno;
  input.batchid = selectedBatch.value;
  input.matnr = indetail.MATNR;
  input.selectedChoice = indetail.selectedChoice;

  DateTime originalTime = DateFormat("yyyy-MM-dd HH:mm:ss")
      .parse(widget.stocktake.created);
  DateTime updatedTime = originalTime.add(Duration(hours: 7));
  String result = DateFormat("yyyy-MM-dd HH:mm:ss").format(updatedTime);
  input.DOWNLOADTIME = result;
  input.SAP_STOCK_BUN = '${conversion(indetail, "Bun","Bukan Tampilan")}';
input.istick = indetail.checkboxvalidation.value;
  var listumrez = indetail.MARM
      .where((element) => element.MEINH != "KG" && element.MEINH != "PAK")
      .toList();
  if (listumrez.isNotEmpty) {
    input.unit_box = listumrez[0].MEINH;
  } else {
    var listpcs = indetail.MARM.where((element) => element.UMREZ.contains("1")).toList();
    input.unit_box = listpcs[0].MEINH;
  }

  var listpcs = indetail.MARM
      .where((element) => element.MEINH != "KG" && element.UMREZ.contains("1"))
      .toList();
  if (listpcs.isNotEmpty) {
    // var forpak = listpcs.where((element) => element.MEINH)
     var forpak = listpcs.where((element) => element.MEINH == "PAK").toList();
    if(forpak.length != 0){
     input.unit_bun = forpak[0].MEINH;
    } else {
    input.unit_bun = listpcs[0].MEINH;
    }
   
  } else {
    var fallback = indetail.MARM.where((element) => element.UMREZ.contains("1")).toList();
    input.unit_bun = fallback[0].MEINH;
  }

  input.sloc = indetail.LGORT;
  input.plant = indetail.WERKS;

  await stocktickvm.sendtohistory(input);
  await stocktickvm.forcounted(input);
  await stocktickvm.updatedetail(
    input,
    detail,
  );

  setState(() {
    // only sync updates here if needed
  });

  EasyLoading.dismiss();
  Get.back();
}
  )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    print("masuk");
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: updateSearchQuery,
    );
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      stocktickvm.searchValue.value = newQuery;
      searchWF(newQuery);
      // }
    });
  }

  void searchWF(String search) async {
   
    stocktickvm.searchValue.value = search;
  }

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson =
          jsonEncode({"command": command, "parameter": parameter});

      await methodChannel.invokeMethod(
          'sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      print("asd");
      //  Error invoking Android method
    }
  }

  void _onEvent(event) {
    setState(() async {
      Map barcodeScan = jsonDecode(event);
      _barcodeString = barcodeScan['scanData'];
      if (_barcodeString != null && _barcodeString != "") {
        List<StockTakeDetailModel> barcode = [];

        // descriptioninput = TextEditingController();
        barcode = stocktickvm.tolistdocument.value
            .singleWhere((element) => element.documentno == widget.documentno)
            .detail
            .where((element) => element.NORMT.contains(_barcodeString))
            .toList();
        if (barcode.length == 0) {
          barcode = stocktickvm.tolistdocument.value
              .singleWhere((element) => element.documentno == widget.documentno)
              .detail
              .where((element) => element.MATNR.contains(_barcodeString))
              .toList();
        }

           List<StockTakeDetailModel> list = [];
                                      sortListBatch.value.clear();
                                    
                                   list = stocktickvm.tolistdocument
                .singleWhere(
                    (element) => element.documentno == widget.documentno)
                .detail
                .where((element) =>
                    element.MATNR ==
                    stocktickvm.tolistdocument
                        .singleWhere((element) =>
                            element.documentno == widget.documentno)
                        .detail
                        .toList()[0]
                        .MATNR)
                .toList();
                      stockbun.value = list[0].selectedChoice == "BLOCK" ? list[0].SPEME : list[0].selectedChoice == "QI" ? list[0].INSME: list[0].LABST;

                                      sortListSection.value.clear();
                                      if (stocktickvm.tolistforinputstocktake
                                              .value.length ==
                                          0) {
                                        bun.value = 0;
                                        box.value = 0;
                                        // sortListSection.value.add("A1-1");
                                       await fetchSectionFromFirestore();
                                        selectedSection.value = sortListSection
                                            .value
                                            .singleWhere((element) =>
                                                element.contains("A1-1"));
                                      } else {
                                      List<InputStockTake> calculate = [];
                                       
                                     // Ambil dokumen spesifik berdasarkan documentno
var targetDocument = stocktickvm.tolistdocument
    .where((element) => element.documentno == widget.documentno)
    .toList();

if (targetDocument.isNotEmpty) {
  var targetDetails = targetDocument[0].detail
      .where((element) => element.NORMT.contains(_barcodeString) || element.MATNR.contains(_barcodeString))
      .toSet()
      .toList();

  if (targetDetails.isNotEmpty) {
    var selectedChoice = targetDetails[0].selectedChoice;
    var matnr = targetDetails[0].MATNR;

    // Filter input stocktake list berdasarkan kondisi
    var calculate = stocktickvm.tolistforinputstocktake.value
        .where((element2) =>
            element2.selectedChoice == selectedChoice &&
            element2.section == "A1-1" &&
            element2.matnr == matnr)
        .toList();

    // Gunakan `calculate` di sini
    print(calculate);
  } else {
    print("Detail tidak ditemukan untuk kondisi yang diberikan.");
  }
} else {
  print("Dokumen tidak ditemukan untuk documentno yang diberikan.");
}

                                           
                                        
                                       
                                        if (calculate.length == 0) {
                                          bun.value = 0;
                                          box.value = 0;
                                         await fetchSectionFromFirestore();
                                          selectedSection.value =
                                              sortListSection.value.singleWhere(
                                                  (element) =>
                                                      element.contains("A1-1"));
                                        } else {
                                          if (calculate.length > 1) {
                                            localpcs = 0;
                                            localctn = 0;
                                            for (var input in calculate) {
                                              localpcs += input.count_bun;
                                              localctn += input.count_box;
                                            }
                                            bun.value = localpcs;
                                            box.value = localctn;
                                          } else {
                                            for (var input in calculate) {
                                              bun.value = input.count_bun;
                                              box.value = input.count_box;
                                            }
                                          }

                                          print(bun.value);
                                          print(box.value);
                                          var calculate2 = stocktickvm
                                              .tolistforinputstocktake.value
                                              .where((element) =>
                                                  element.batchid ==
                                                  selectedBatch.value)
                                              .toList();
                                          calculate2.sort((a, b) =>
                                              b.created.compareTo(a.created));
                                          for (var input in calculate2) {
                                            if (sortListSection.value.any(
                                                (element) => element
                                                    .contains(input.section))) {
                                            } else {
                                              sortListSection.value
                                                  .add(input.section);
                                            }
                                          }
                                       
                                        }

                                        selectedSection.value = sortListSection
                                            .value
                                            .singleWhere((element) =>
                                                element.contains("A1-1"));
                                        print(selectedSection.value);
                                      }
                                     
                                      totalbox.value = _Calcultotalbox(
                                       stocktickvm.tolistdocumentnosame.where((element) => element.documentno == widget.documentno).toList()[0]
                .detail.where((element) => element.LABST != 0 && element.INSME != 0 && element.SPEME != 0)
                .toSet()
                .toList()[0]);
                                   
                                      totalbun.value = _CalculTotalpcs(
                                         stocktickvm.tolistdocumentnosame.where((element) => element.documentno == widget.documentno).toList()[0]
                .detail.where((element) => element.LABST != 0 && element.INSME != 0 && element.SPEME != 0)
                .toSet()
                .toList()[0]);
                                    
                                      localpcsvalue.value = bun.value;
                                      localctnvalue.value = box.value;
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) =>modalBottomSheet(barcode[0], barcode)
                                      );
      }
      ;
    });
  }

  void _onError(Object error) {
    setState(() {
      _barcodeString = "Barcode: error";
      _barcodeSymbology = "Symbology: error";
      _scanTime = "At: error";
    });
  }

  void startScan() {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
    });
  }

  void stopScan() {
    setState(() {
      _sendDataWedgeCommand(
          "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
    });
  }

  void _startSearch() {
    setState(() {
     
      detaillocal.clear();
      var locallist =
          stocktickvm.tolistdocumentnosame.value[widget.index].detail;
      for (var i = 0; i < locallist.length; i++) {
        detaillocal.add(locallist[i]);
      }
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _isSearching = false;
      _searchQuery.clear();
      _isSearching = false;
      detaillocal.clear();
      stocktickvm.searchValue.value = '';

      for (var item in detaillocal) {
        stocktickvm.tolistdocumentnosame.value
            .singleWhere((element) => element.documentno == widget.documentno)
            .detail
            .add(item);
      }

      // Get.to(InDetailPage(index));
    });
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              setState(() {
                _stopSearching();
              });
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }
    return <Widget>[
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () async {
              await stocktickvm.listcounted();
              await Get.to(CountedPage(widget.index));
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: scanBarcode,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        ],
      )
    ];
  }

  Future<void> scanBarcode() async {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color of the scan button
      "Cancel", // Text of the cancel button
      true, // Enable flash
      ScanMode.BARCODE, // Type of barcode to scan
    );

    if (barcodeScanRes != null && barcodeScanRes != "") {
   
      var barcode = stocktickvm.tolistdocument.value
          .singleWhere((element) => element.documentno == widget.documentno)
          .detail
          .where((element) => element.NORMT.contains(barcodeScanRes))
          .toList();
     
      List<StockTakeDetailModel> list = [];
      sortListBatch.value.clear();
      namechoice != "ALL"
          ? list = stocktickvm.tolistdocument
              .singleWhere((element) => element.documentno == widget.documentno)
              .detail
              .where((element) =>
                  element.MATNR ==
                  stocktickvm.tolistdocument
                      .singleWhere(
                          (element) => element.documentno == widget.documentno)
                      .detail
                      .toList()[0]
                      .MATNR)
              .toList()
          : list = stocktickvm.tolistdocument
              .singleWhere((element) => element.documentno == widget.documentno)
              .detail
              .where((element) =>
                  element.MATNR ==
                  stocktickvm.tolistdocument
                      .singleWhere(
                          (element) => element.documentno == widget.documentno)
                      .detail[0]
                      .MATNR)
              .toList();
      for (var liststock in list) {
        sortListBatch.value.add(liststock.MATNR);
      }

      // }
      selectedBatch.value = sortListBatch.value[0];
      sortListSection.value.clear();
      if (stocktickvm.tolistforinputstocktake.value.length == 0) {
        bun.value = 0;
        box.value = 0;
        // sortListSection.value.add("A1-1");
       await fetchSectionFromFirestore();
        selectedSection.value = sortListSection.value
            .singleWhere((element) => element.contains("A1-1"));
      } else {
        var calculate = stocktickvm.tolistforinputstocktake.value
            .where((element) =>
                element.batchid == selectedBatch.value &&
                element.section == "A1-1")
            .toList();
        if (calculate.length == 0) {
          bun.value = 0;
          box.value = 0;
        await  fetchSectionFromFirestore();
          selectedSection.value = sortListSection.value
              .singleWhere((element) => element.contains("A1-1"));
        } else {
          for (var input in calculate) {
            bun.value = input.count_bun;
            box.value = input.count_box;
          }
          var calculate2 = stocktickvm.tolistforinputstocktake.value
              .where((element) => element.batchid == selectedBatch.value)
              .toList();
          calculate2.sort((a, b) => b.created.compareTo(a.created));
          for (var input in calculate2) {
            sortListSection.value.add(input.section);
          }
         
        }

        selectedSection.value = sortListSection.value
            .singleWhere((element) => element.contains("A1-1"));
      }
      totalbox.value = _Calcultotalbox(stocktickvm.tolistdocument
          .singleWhere((element) => element.documentno == widget.documentno)
          .detail
          .toList()[0]);
      totalbun.value = _CalculTotalpcs(stocktickvm.tolistdocument
          .singleWhere((element) => element.documentno == widget.documentno)
          .detail
          .toList()[0]);
      namechoice != "ALL"
          ? showMaterialModalBottomSheet(
              context: context,
              builder: (context) => WillPopScope(
                onWillPop: () async {
                  Navigator.of(context).pop(); // Close the modal bottom sheet
                  // checkingscan = false;
                  return true; // Allow the back button press
                },
                child: modalBottomSheet(barcode[0], barcode),
              ),
            )
          : showMaterialModalBottomSheet(
              context: context,
              builder: (context) => WillPopScope(
                onWillPop: () async {
                  Navigator.of(context).pop(); // Close the modal bottom sheet
                  // checkingscan = false;
                  return true; // Allow the back button press
                },
                child: modalBottomSheet(barcode[0], barcode),
              ),
            );

    }
    ;

    // This will print the scanned barcode value
  }

// Future _showMyDialogApprove(StocktickModel stockmodel) async {
//   double baseWidth = 312;
//   double fem = MediaQuery.of(context).size.width / baseWidth;
//   double ffem = fem * 0.97;

//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext dialogContext) => StatefulBuilder(
//       builder: (context, setState) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(15)),
//           ),
//           content: Container(
//             height: MediaQuery.of(dialogContext).size.height / 2.5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   margin: EdgeInsets.only(bottom: 15.5 * fem),
//                   width: 35 * fem,
//                   height: 35 * fem,
//                   child: Image.asset(
//                     'data/images/mdi-warning-circle-vJo.png',
//                     width: 35 * fem,
//                     height: 35 * fem,
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(bottom: 48 * fem),
//                   constraints: BoxConstraints(maxWidth: 256 * fem),
//                   child: Text(
//                     'Are you sure to save this stock take document?',
//                     textAlign: TextAlign.center,
//                     style: SafeGoogleFont(
//                       'Roboto',
//                       fontSize: 16 * ffem,
//                       fontWeight: FontWeight.w600,
//                       height: 1.1725 * ffem / fem,
//                       color: Color(0xff2d2d2d),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   height: 25 * fem,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // CANCEL BUTTON
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(dialogContext).pop();
//                         },
//                         child: Container(
//                           margin: EdgeInsets.fromLTRB(20 * fem, 0, 16 * fem, 0),
//                           padding: EdgeInsets.symmetric(horizontal: 24 * fem, vertical: 5 * fem),
//                           height: double.infinity,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Color(0xfff44236)),
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12 * fem),
//                           ),
//                           child: Center(
//                             child: SizedBox(
//                               width: 30 * fem,
//                               height: 30 * fem,
//                               child: Image.asset('data/images/cancel-viF.png'),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // SAVE BUTTON
//                       GestureDetector(
//                         onTap: () async {
//                           EasyLoading.show(status: 'Saving...');

//                           List<InputStockTake> listlocal = [];

//                           // FILTER YANG CENTANG
//                           var stockyes = stockmodel.detail
//                               .where((element) => element.checkboxvalidation.value == true)
//                               .toList();

//                           for (var stocklist in stockyes) {
//                             var liststock = stocktickvm.tolistforinputstocktake
//                                 .where((element) => element.matnr == stocklist.MATNR)
//                                 .toList();

//                             // CEGAH ERROR "No element"
//                             if (liststock.isEmpty) {
//                               debugPrint('❗ Data MATNR tidak ditemukan: ${stocklist.MATNR}');
//                               continue;
//                             }

//                             listlocal.addAll(liststock);
//                           }

//                           if (listlocal.isEmpty) {
//                             EasyLoading.dismiss();
//                             Get.snackbar('Warning', 'No stock selected to save.');
//                             return;
//                           }

//                           // PERSIAPKAN PAYLOAD
//                           Map<String, dynamic> payload = {
//                             "topic": "immobile-cp-stocktake",
//                             "key": "myUniqueKey",
//                             "message": {
//                               "data": InputStockTake.toMapWithMultipleInputs(listlocal),
//                             },
//                           };

//                           var forreturn = await stocktickvm.producekafka(payload);
//                           EasyLoading.dismiss();

//                           if (forreturn == "Message produced successfully") {
//                             DateTime now = DateTime.now();
//                             String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
//                             stockmodel.updated = formattedDate;
//                             stockmodel.updatedby = globalvm.username.value;

//                             await stocktickvm.approveall(stockmodel);

//                             Navigator.of(dialogContext).pop(); // ✅ Tutup dialog
//                             Get.snackbar('Success', 'Stock take approved successfully.');
//                           } else {
//                             Get.snackbar('Error', 'Failed to produce stock data.');
//                           }
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(horizontal: 24 * fem, vertical: 5 * fem),
//                           height: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Color(0xff2cab0c),
//                             borderRadius: BorderRadius.circular(12 * fem),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Color(0x3f000000),
//                                 offset: Offset(0, 4 * fem),
//                                 blurRadius: 2 * fem,
//                               ),
//                             ],
//                           ),
//                           child: Center(
//                             child: SizedBox(
//                               width: 30 * fem,
//                               height: 30 * fem,
//                               child: Image.asset('data/images/check-circle-fg7.png'),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }


  Future _showMyDialogApprove(StocktickModel stockmodel) async {
    double baseWidth = 312;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        // user must tap button!
        builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  content: Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // mdiwarningcircleut4 (11:1225)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 1 * fem, 15.5 * fem),
                          width: 35 * fem,
                          height: 35 * fem,
                          child: Image.asset(
                            'data/images/mdi-warning-circle-vJo.png',
                            width: 35 * fem,
                            height: 35 * fem,
                          ),
                        ),
                        Container(
                          // areyousuretodiscardallchangesm (11:1227)
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 48 * fem),
                          constraints: BoxConstraints(
                            maxWidth: 256 * fem,
                          ),
                          child: Text(
                            'Are you sure to save this stock take document?',
                            textAlign: TextAlign.center,
                            style: SafeGoogleFont(
                              'Roboto',
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff2d2d2d),
                            ),
                          ),
                        ),
                        Container(
                          // autogroupf5ebdRu (UM6eDoseJp3PyzDupvF5EB)

                          width: double.infinity,
                          height: 25 * fem,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Container(
                                  // cancelbutton8Nf (11:1273)
                                  margin: EdgeInsets.fromLTRB(
                                      20 * fem, 0 * fem, 16 * fem, 0 * fem),
                                  padding: EdgeInsets.fromLTRB(
                                      24 * fem, 5 * fem, 25 * fem, 5 * fem),
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xfff44236)),
                                    color: Color(0xffffffff),
                                    borderRadius:
                                        BorderRadius.circular(12 * fem),
                                  ),
                                  child: Center(
                                    // cancelnCK (11:1275)
                                    child: SizedBox(
                                      width: 30 * fem,
                                      height: 30 * fem,
                                      child: Image.asset(
                                        'data/images/cancel-viF.png',
                                        width: 30 * fem,
                                        height: 30 * fem,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Get.back();
                                },
                              ),
                              GestureDetector(
                                  child: Container(
                                    // savebuttonSnf (11:1278)
                                    padding: EdgeInsets.fromLTRB(
                                        24 * fem, 5 * fem, 25 * fem, 5 * fem),
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xff2cab0c),
                                      borderRadius:
                                          BorderRadius.circular(12 * fem),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x3f000000),
                                          offset: Offset(0 * fem, 4 * fem),
                                          blurRadius: 2 * fem,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      // checkcircle7du (11:1280)
                                      child: SizedBox(
                                        width: 30 * fem,
                                        height: 30 * fem,
                                        child: Image.asset(
                                          'data/images/check-circle-fg7.png',
                                          width: 30 * fem,
                                          height: 30 * fem,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onDoubleTap: () {},
                                  onTap: () async {
                                    List<InputStockTake> listlocal = [];
                                var stockyes = stockmodel.detail.where((element) => element.checkboxvalidation.value == true).toList();
                                for (var stocklist in stockyes){
                            var liststock = stocktickvm.tolistforinputstocktake.where((element) => element.matnr == stocklist.MATNR).toList();
                                                         for (var listinput in liststock){
                                                           listlocal.add(listinput); 
                                                         }
                                                         
                                }
                                 if (listlocal.isEmpty) {
                            EasyLoading.dismiss();
                            Get.snackbar('Warning', 'No stock selected to save.');
                            return;
                          }
                                     Map<String, dynamic> payload = {
                                      "topic": "immobile-cp-stocktake",
                                      "key": "myUniqueKey",
                                      "message": {
                                        "data":  InputStockTake.toMapWithMultipleInputs(listlocal)
                                      }
                                    };
                                  var forreturn = await stocktickvm.producekafka(payload);
                                  if(forreturn == "Message produced successfully"){
                                      DateTime now = DateTime.now();
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd kk:mm:ss')
                                              .format(now);
                                      stockmodel.updated = formattedDate;
                                      stockmodel.updatedby =
                                          globalvm.username.value;
                                      await stocktickvm.approveall(stockmodel);
                                     
                                   
                               
                             
                                    Get.back();
                                  }  else {
                                    
                                  }
                                  EasyLoading.dismiss();
                                            Get.back();
                                  }) // )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ));
  }

  @override
  Widget build(BuildContext context) {

    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return WillPopScope(
        onWillPop: () => Future.value(_allow),
        child: SafeArea(
            child: Scaffold(
            floatingActionButton: Visibility(
  visible: stocktickvm.tolistdocument
      .singleWhere((element) => element.documentno == widget.documentno)
      .isapprove == "N",
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      FloatingActionButton(
        onPressed: () async {
          var result = await stocktickvm.sendemail(widget.documentno);
             EasyLoading.dismiss();
          Get.snackbar("INFO", "Email Success Terkirim");
        },
        child: Icon(Icons.email_outlined),
        backgroundColor: Colors.blue,
        heroTag: "emailBtn", // Tambahkan heroTag jika ada lebih dari satu FAB
      ),
      SizedBox(width: 16), // Jarak antar tombol
      FloatingActionButton(
        onPressed: () async {
          var stock = stocktickvm.tolistdocument
              .singleWhere((element) => element.documentno == widget.documentno);
          _showMyDialogApprove(stock);
        },
        child: Icon(Icons.check),
        backgroundColor: namechoice == "FZ"
            ? Colors.blue
            : namechoice == "CH"
                ? Colors.green
                : namechoice == "ALL"
                    ? Colors.orange
                    : Color(0xfff44236),
        heroTag: "approveBtn", // Tambahkan heroTag berbeda
      ),
    ],
  ),
),
         // : null,
                appBar: AppBar(
                    // toolbarHeight: 1/12*Get.height,
                    elevation: 0,
                    actions: _buildActions(),
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 20.0,
                      onPressed: () {
                        GlobalVar.choicecategory =
                            globalvm.choicecategory.value;
                        if (GlobalVar.choicecategory == "ALL") {
                       
                        } else {
                          if (listcategory.length != 0) {
                           
                          }
                        
                        }

                        Get.back();
                      },
                    ),
                  
                    backgroundColor: Colors.red,

                    title: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: _isSearching
                          ? _buildSearchField()
                          : Container(
                              child: TextWidget(
                                  text: "${widget.stocktake.documentno}",
                                  isBlueTxt: false,
                                  maxLines: 2,
                                  size: 17 * ffem,
                                  color: Colors.white)),
                    ),
                    // actions: widget.listTrack != null ? null : _buildActions(),
                    centerTitle: false),
                backgroundColor: kWhiteColor,
                body: Container(
                  padding: EdgeInsets.only(
                    bottom: 25,
                    //  left: 5, right: 5
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(height: 5),
                            Container(
                              height: Get.height * 1 / 20,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextWidget(
                                    text:
                                        '${stocktickvm.newListToDocument(namechoice, stocktickvm.document.value).where((element) => element.isapprove == "Y").toList().length} of ${stocktickvm.newListToDocument(namechoice, stocktickvm.document.value).length} data shown',
                                     isBlueTxt: false,
                                    maxLines: 2,
                                    color: Colors.white,
                                    size: 16 * ffem,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: TextWidget(
                                        text: '${globalvm.username.value}',
                                        isBlueTxt: false,
                                        color: Colors.white,
                                        maxLines: 2,
                                        size: 16 * ffem),
                                  )
                                ],
                              ),
                              color: Colors.grey[700],
                            ),
                            Container(
                                width: Get.width,
                                alignment: Alignment.center,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: listchoice
                                      .map((e) => ChoiceChip(
                                            padding: EdgeInsets.only(
                                                left: 5, right: 5),
                                            labelStyle: (Theme.of(context)
                                                        .backgroundColor ==
                                                    Colors.grey[100]
                                                ? (idPeriodSelected == e.id
                                                    ? TextStyle(
                                                        color: Colors.white)
                                                    : TextStyle(
                                                        color: Colors.white))
                                                : (idPeriodSelected == e.id
                                                    ? TextStyle(
                                                        color: Colors.white)
                                                    : TextStyle(
                                                        color: Colors.white))),
                                            backgroundColor: Theme.of(context)
                                                        .backgroundColor ==
                                                    Colors.grey[100]
                                                ? Colors.grey
                                                : Colors.grey,
                                            label: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                e.labelname,
                                                // maxFontSize: 40,
                                                style: TextStyle(
                                                  fontSize: 16 * ffem,
                                                ),   ),
                                            ),
                                            selected: idPeriodSelected == e.id,
                                            onSelected: (_) {
                                              setState(() {
                                                idPeriodSelected = e.id;
                                                int choice =
                                                    idPeriodSelected - 1;
                                                namechoice =
                                                    listchoice[choice].label;
                                                if (namechoice != "ALL") {
                                                  stocktickvm.forDetail();
                                                } else {
                                                  stocktickvm.forDetailAll();
                                                }
                                              
                                              });
                                              // changeSelectedId('Period', e.id);
                                            },
                                            selectedColor: namechoice == "FZ"
                                                ? Colors.blue
                                                : namechoice == "CH"
                                                    ? Colors.green
                                                    : namechoice == "ALL"
                                                        ? Colors.orange
                                                        : Color(0xfff44236),
                                            elevation: 10,
                                          ))
                                      .toList(),
                                  spacing: 25,
                                ),
                                padding: EdgeInsets.only(bottom: 10)),
                          ],
                        );
                      }),
                      Obx(() {
                        return  
                            Expanded(
                          child: ListView.builder(
                            // padding: EdgeInsets.all(20),
                              controller: controller,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: stocktickvm
                                  .newListToDocument(namechoice, stocktickvm.document.value)
                                  .length,
                             
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child: Obx(
                                    () => headerCard2(
                                        stocktickvm.newListToDocument(
                                            namechoice, stocktickvm.document.value)[index]),
                                  ),
                                 
                                  onTap: () async {
                                    if (stocktickvm.tolistdocument
                                            .singleWhere((element) =>
                                                element.documentno ==
                                                widget.documentno)
                                            .isapprove ==
                                        "Y") {
                                    } else {
                                      List<StockTakeDetailModel> list = [];
                                      sortListBatch.value.clear();
                                    
                                      list = stocktickvm.tolistdocument
                                          .singleWhere((element) =>
                                              element.documentno ==
                                              widget.documentno)
                                          .detail
                                          .where((element) =>
                                              element.MATNR ==
                                              stocktickvm
                                                  .newListToDocument(namechoice,
                                                      stocktickvm.document.value)[index]
                                                  .MATNR)
                                          .toList();
                                      for (var liststock in stocktickvm
                                              .tolistdocument
                                              .singleWhere((element) =>
                                                  element.documentno ==
                                                  widget.documentno)
                                              .detail
                                              .where((element) =>
                                                  element.MATNR ==
                                                  stocktickvm
                                                      .newListToDocument(
                                                          namechoice,
                                                          stocktickvm.document.value)[index]
                                                      .MATNR)
                                              .toList()

                                          // list
                                          ) {
                                      }
                                      stockbun.value = list[0].selectedChoice == "BLOCK" ? list[0].SPEME : list[0].selectedChoice == "QI" ? list[0].INSME: list[0].LABST;
                                      sortListSection.value.clear();
                                      if (stocktickvm.tolistforinputstocktake
                                              .value.length ==
                                          0) {
                                        bun.value = 0;
                                        box.value = 0;
                                        // sortListSection.value.add("A1-1");
                                    await    fetchSectionFromFirestore();
                                        selectedSection.value = sortListSection
                                            .value
                                            .singleWhere((element) =>
                                                element.contains("A1-1"));
                                      } else {
                                      List<InputStockTake> calculate = [];
                                        if(namechoice == "ALL"){
  calculate = stocktickvm
                                            .tolistforinputstocktake.value
                                            .where((element) =>
                                                element.batchid ==
                                                    selectedBatch.value &&
                                                element.section == "A1-1" && element.matnr == stocktickvm.tolistdocument.where((element) => element.documentno == widget.documentno).toList()[0].detail[index].MATNR)
                                            .toList();
                                        } else {
                                          // print();
                                         
                                      calculate = stocktickvm
                                            .tolistforinputstocktake.value
                                            .where((element) =>
                                            element.selectedChoice ==  stocktickvm.newListToDocument(
                                            namechoice, stocktickvm.document.value)[index].selectedChoice &&
                                                element.section == "A1-1"
                                                 && element.matnr == stocktickvm.newListToDocument(
                                            namechoice, stocktickvm.document.value)[index].MATNR
                                         
                                          )
                                            .toList();
                                           
                                            print(calculate);
                                        }
                                       
                                        if (calculate.length == 0) {
                                          bun.value = 0;
                                          box.value = 0;
                                        await  fetchSectionFromFirestore();
                                          selectedSection.value =
                                              sortListSection.value.singleWhere(
                                                  (element) =>
                                                      element.contains("A1-1"));
                                        } else {
                                          if (calculate.length > 1) {
                                            localpcs = 0;
                                            localctn = 0;
                                            for (var input in calculate) {
                                              localpcs += input.count_bun;
                                              localctn += input.count_box;
                                            }
                                            bun.value = localpcs;
                                            box.value = localctn;
                                          } else {
                                            for (var input in calculate) {
                                              bun.value = input.count_bun;
                                              box.value = input.count_box;
                                            }
                                          }

                                          print(bun.value);
                                          print(box.value);
                                          var calculate2 = stocktickvm
                                              .tolistforinputstocktake.value
                                              .where((element) =>
                                                  element.batchid ==
                                                  selectedBatch.value && element.matnr == stocktickvm.newListToDocument(
                                            namechoice, stocktickvm.document.value)[index].MATNR && element.selectedChoice == 
                                              stocktickvm.newListToDocument(
                                            namechoice, stocktickvm.document.value)[index].selectedChoice )
                                              .toList();
                                          calculate2.sort((a, b) =>
                                              b.created.compareTo(a.created));
                                          for (var input in calculate2) {
                                            if (sortListSection.value.any(
                                                (element) => element
                                                    .contains(input.section))) {
                                            } else {
                                           
                                              sortListSection.value
                                                  .add(input.section);
                                                    await fetchSectionFromFirestore();
                                            }
                                          }
                                       
                                        }

                                        selectedSection.value = sortListSection
                                            .value
                                            .singleWhere((element) =>
                                                element.contains("A1-1"));
                                        print(selectedSection.value);
                                      }
                                     
                                      totalbox.value = _Calcultotalbox(
                                          stocktickvm.newListToDocument(
                                              namechoice, stocktickvm.document.value)[index]);
                                     
                                      totalbun.value = _CalculTotalpcs(
                                       
                                          stocktickvm.newListToDocument(
                                              namechoice, stocktickvm.document.value)[index]);
                                    
                                      localpcsvalue.value = bun.value;
                                      localctnvalue.value = box.value;
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => modalBottomSheet(
                                          
                                            stocktickvm.newListToDocument(
                                                namechoice,
                                                stocktickvm.document.value)[index],
                                           
                                            stocktickvm.newListToDocument(
                                                namechoice, stocktickvm.document.value)),
                                      );
                                    }
                                   
                                  },
                                );
                              }),
                        );
                      }),
                    ],
                  ),
                ))));
  }
}

class TableCellWidget extends StatelessWidget {
  final String value;

  TableCellWidget({this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      width: 70.0, // Set the width of the TableCellWidget
      height: 40.0, // Set the height of the TableCellWidget
      child: Center(
        child: Text(
          value,
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
