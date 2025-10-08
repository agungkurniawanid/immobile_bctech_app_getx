import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:immobile/widget/utils.dart';
import 'dart:convert';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/viewmodel/stockcheckvm.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:immobile/model/stockdetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:immobile/model/stockcheck.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class DetailStockCheckPage extends StatefulWidget {
  final int index;
  final String flag;
  const DetailStockCheckPage(this.index, this.flag);
  @override
  _DetailStockCheckPage createState() => _DetailStockCheckPage();
}

class _DetailStockCheckPage extends State<DetailStockCheckPage> {
  StockCheckVM stockcheckVM = Get.find();
  GlobalVM globalVM = Get.find();
  bool _allow = true;
  int idPeriodSelected = 1;
  List<String> sortList = ['PO Date', 'Vendor'];
  InVM inVM = Get.find();
  final listchoice = <ItemChoice>[
    ItemChoice(1, 'Ambient'),
    ItemChoice(2, 'Chiller'),
    ItemChoice(3, 'Frozen')
  ];
  bool light0 = false;
  bool ontap = true;
  bool pcsctnvalidation = true;
  ValueNotifier<bool> pcsctnnotifier = ValueNotifier(false);
  ValueNotifier<int> pickedctnmain = ValueNotifier(0);
  ValueNotifier<int> pickedctngood = ValueNotifier(0);
  ValueNotifier<int> pickedpcsmain = ValueNotifier(0);
  ValueNotifier<int> pickedpcsgood = ValueNotifier(0);
  int typeIndexmain = 0;
  int typeIndexgood = 0;
  int tabs = 0;
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("CTN"),
    1: Text("PCS"),
  };
  TextEditingController _controllermain;
  TextEditingController _controllergood;
  List<Category> listcategory = [];
  ScrollController controller;
  bool _leading = true;
  GlobalKey srKey = GlobalKey();
  StockModel clone;
  String barcodeScanRes;
  bool fromscan = true;
  bool _isSearching = false;
  TextEditingController _searchQuery;
  String searchQuery;
  List<StockDetail> listdetailstock = new List<StockDetail>();

  static const MethodChannel methodChannel =
      MethodChannel('id.co.cp.immobile/command');
  static const EventChannel scanChannel =
      EventChannel('id.co.cp.immobile/scan');

  //  This example implementation is based on the sample implementation at
  //  https://github.com/flutter/flutter/blob/master/examples/platform_channel/lib/main.dart
  //  That sample implementation also includes how to return data from the method
  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson =
          jsonEncode({"command": command, "parameter": parameter});

      await methodChannel.invokeMethod(
          'sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  String _barcodeString = "Barcode will be shown here";
  String _barcodeSymbology = "Symbology will be shown here";
  String _scanTime = "Scan Time will be shown here";

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    clone = StockModel.clone(stockcheckVM.toliststock.value[widget.index]);
    GlobalVar.choicecategory = "AB";
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _createProfile("DataWedgeFlutterDemo");
    startScan();
  }

  void _onEvent(event) {
    setState(() {
      Map barcodeScan = jsonDecode(event);
      _barcodeString = barcodeScan['scanData'];
      if (widget.flag != "history") {
        if (_barcodeString != null && _barcodeString != "") {
          // pickedctn = TextEditingController();
          // pickedpcs = TextEditingController();

          pcsctnnotifier.value = false;

          pickedctnmain.value = stockcheckVM
              .toliststock.value[widget.index].detail
              .where((element) => element.item_code.contains(_barcodeString))
              .toList()[0]
              .warehouse_stock_main_ctn;
          pickedctngood.value = stockcheckVM
              .toliststock.value[widget.index].detail
              .where((element) => element.item_code.contains(_barcodeString))
              .toList()[0]
              .warehouse_stock_good_ctn;
          pickedpcsmain.value = stockcheckVM
              .toliststock.value[widget.index].detail
              .where((element) => element.item_code.contains(_barcodeString))
              .toList()[0]
              .warehouse_stock_main;
          pickedpcsgood.value = stockcheckVM
              .toliststock.value[widget.index].detail
              .where((element) => element.item_code.contains(_barcodeString))
              .toList()[0]
              .warehouse_stock_good;
          fromscan = false;

          showMaterialModalBottomSheet(
            context: context,
            builder: (context) => modalBottomSheet(stockcheckVM
                .toliststock.value[widget.index].detail
                .where((element) => element.item_code.contains(_barcodeString))
                .toList()[0]),
          );
        }
      }

      // _barcodeSymbology = "Symbology: " + barcodeScan['symbology'];
      // _scanTime = "At: " + barcodeScan['dateTime'];
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

  // @override
  // void initState() {
  //   super.initState();
  //   _searchQuery = new TextEditingController();
  //   clone = StockModel.clone(stockcheckVM.toliststock.value[widget.index]);
  //   GlobalVar.choicecategory = "AB";
  // }

  calculateStock(int mainstock, int goodstock) {
    int totalstock = mainstock + goodstock;
    return totalstock.toString();
  }

  Future _showMyDialogApprove(
      StockModel stockmodel, StockDetail stockdetail, String tanda) async {
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
                            'Are you sure to save all changes made in this Product? ',
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
                                  onTap: () async {
                                    var username =
                                        await DatabaseHelper.db.getUser();

                                    String todaytime =
                                        DateFormat('yyyy-MM-dd HH:mm:ss')
                                            .format(DateTime.now());
                                    List<Map<String, dynamic>> maptdata;
                                    if (fromscan == false) {
                                      stockdetail.is_scanned = "Y";
                                    }
                                    if (tanda == "all") {
                                      if (_isSearching == true) {
                                        stockcheckVM.toliststock
                                            .value[widget.index].detail
                                            .clear();
                                        for (var item in listdetailstock) {
                                          stockcheckVM.toliststock
                                              .value[widget.index].detail
                                              .add(item);
                                        }
                                      }
                                      stockmodel.isapprove = "Y";
                                      stockmodel.updatedby = username;
                                      stockmodel.updated = todaytime;
                                      // stockmodel.update
                                    } else {
                                      stockdetail.warehouse_stock_good =
                                          pickedpcsgood.value;
                                      stockdetail.warehouse_stock_good_ctn =
                                          pickedctngood.value;
                                      stockdetail.warehouse_stock_main =
                                          pickedpcsmain.value;
                                      stockdetail.warehouse_stock_main_ctn =
                                          pickedctnmain.value;
                                      stockdetail.checked = 1;
                                      stockdetail.approvename = username;
                                      stockdetail.updated_at = todaytime;
                                    }
                                    maptdata = stockcheckVM
                                        .toliststock.value[widget.index].detail
                                        .map((person) => person.toMap())
                                        .toList();

                                    Get.back();
                                    Get.back();

                                    if (tanda == "all") {
                                      stockcheckVM.approveall(stockmodel, "Y");
                                      stockcheckVM.sendtohistory(
                                          stockmodel, maptdata);
                                    } else {
                                      stockcheckVM.approvestock(
                                          stockcheckVM
                                              .toliststock.value[widget.index],
                                          maptdata);
                                    }

                                    Fluttertoast.showToast(
                                        fontSize: 22,
                                        gravity: ToastGravity.TOP,
                                        msg: "Document has been approved",
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white);
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

  Future _showMyDialogReject(String flag) async {
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
                            'data/images/mdi-warning-circle-9um.png',
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
                            'Are you sure to discard all changes made in this Area?',
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
                                onTap: () async {
                                  if (flag == "refresh") {
                                    bool hasil = await stockcheckVM
                                        .refreshstock(stockcheckVM
                                            .toliststock.value[widget.index]);
                                    Get.back();
                                  } else {
                                    Get.back();
                                    Get.back();
                                  }

                                  // var backup = inVM.tolistPObackup.value
                                  //     .where(
                                  //         (element) => element.ebeln == ebeln)
                                  //     .toList()[0]
                                  //     .T_DATA;
                                  // if (backup.length == 0) {
                                  // } else {
                                  //   inVM.tolistPO.value[widget.index].T_DATA
                                  //       .clear();
                                  //   for (int i = 0; i < backup.length; i++) {
                                  //     inVM.tolistPO.value[widget.index].T_DATA
                                  //         .add(backup[i]);
                                  //   }
                                  // }
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

  Future _showMyDialog(StockDetail indetail, bool type) async {
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
                    height: MediaQuery.of(context).size.height / 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Text(
                            '${indetail.item_name}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: CupertinoSlidingSegmentedControl(
                              groupValue: tabs,
                              children: myTabs,
                              onValueChanged: (i) {
                                setState(() {
                                  tabs = i;

                                  tabs == 0 ? type = false : type = true;

                                  if (type == true) {
                                    _controllermain = TextEditingController(
                                        text: pickedpcsmain.value.toString());

                                    typeIndexmain =
                                        int.parse(_controllermain.text);

                                    _controllergood = TextEditingController(
                                        text: pickedpcsgood.value.toString());

                                    typeIndexgood =
                                        int.parse(_controllergood.text);
                                  } else {
                                    _controllermain = TextEditingController(
                                        text: pickedctnmain.value.toString());

                                    typeIndexmain =
                                        int.parse(_controllermain.text);

                                    _controllergood = TextEditingController(
                                        text: pickedctngood.value.toString());

                                    typeIndexgood =
                                        int.parse(_controllergood.text);
                                  }
                                });
                              }),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Text(
                            'Main',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
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
                                    if (type == false) {
                                      if (_controllermain.text[0] == '0') {
                                        typeIndexmain = 0;
                                        _controllermain = TextEditingController(
                                            text: typeIndexmain.toString());
                                      } else {
                                        typeIndexmain--;
                                        _controllermain = TextEditingController(
                                            text: typeIndexmain.toString());
                                      }
                                      pickedctnmain.value = typeIndexmain;
                                    } else {
                                      if (_controllermain.text[0] == '0') {
                                        typeIndexmain = 0;
                                        _controllermain = TextEditingController(
                                            text: typeIndexmain.toString());
                                      } else {
                                        typeIndexmain--;
                                        _controllermain = TextEditingController(
                                            text: typeIndexmain.toString());
                                      }
                                      pickedpcsmain.value = typeIndexmain;
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              child: TextField(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _controllermain,
                                onChanged: (i) {
                                  setState(() {
                                    if (type == false && tabs == 0) {
                                      typeIndexmain =
                                          int.parse(_controllermain.text);
                                      pickedctnmain.value = typeIndexmain;
                                    } else if (type == true && tabs == 1) {
                                      typeIndexmain =
                                          int.parse(_controllermain.text);
                                      pickedpcsmain.value = typeIndexmain;
                                    }
                                  });
                                },
                              ),
                            ),
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
                                    if (type == false) {
                                      typeIndexmain++;
                                      _controllermain = TextEditingController(
                                          text: typeIndexmain.toString());

                                      pickedctnmain.value = typeIndexmain;
                                    } else {
                                      typeIndexmain++;
                                      _controllermain = TextEditingController(
                                          text: typeIndexmain.toString());

                                      pickedpcsmain.value = typeIndexmain;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Text(
                            'Good',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
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
                                    if (type == false) {
                                      if (_controllergood.text[0] == '0') {
                                        typeIndexgood = 0;
                                        _controllergood = TextEditingController(
                                            text: typeIndexgood.toString());
                                      } else {
                                        typeIndexgood--;
                                        _controllergood = TextEditingController(
                                            text: typeIndexgood.toString());
                                      }
                                      pickedctngood.value = typeIndexgood;
                                    } else {
                                      if (_controllergood.text[0] == '0') {
                                        typeIndexgood = 0;
                                        _controllergood = TextEditingController(
                                            text: typeIndexgood.toString());
                                      } else {
                                        typeIndexgood--;
                                        _controllergood = TextEditingController(
                                            text: typeIndexgood.toString());
                                      }
                                      pickedpcsgood.value = typeIndexgood;
                                      // indetail.warehouse_stock_good =
                                      //     typeIndexmain;
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              child: TextField(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _controllergood,
                                onChanged: (i) {
                                  setState(() {
                                    if (type == false && tabs == 0) {
                                      typeIndexgood =
                                          int.parse(_controllergood.text);
                                      pickedctngood.value = typeIndexgood;
                                    } else if (type == true && tabs == 1) {
                                      typeIndexgood =
                                          int.parse(_controllergood.text);
                                      pickedpcsgood.value = typeIndexgood;
                                    }
                                  });
                                },
                              ),
                            ),
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
                                    if (type == false) {
                                      typeIndexgood++;
                                      _controllergood = TextEditingController(
                                          text: typeIndexgood.toString());

                                      pickedctngood.value = typeIndexgood;
                                    } else {
                                      typeIndexgood++;
                                      _controllergood = TextEditingController(
                                          text: typeIndexgood.toString());

                                      pickedpcsgood.value = typeIndexgood;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            // autogroupf5ebdRu (UM6eDoseJp3PyzDupvF5EB)

                            width: double.infinity,
                            height: 30 * fem,
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
                                    pickedctnmain.value =
                                        indetail.warehouse_stock_main_ctn;
                                    pickedctngood.value =
                                        indetail.warehouse_stock_good_ctn;
                                    pickedpcsmain.value =
                                        indetail.warehouse_stock_main;
                                    pickedpcsgood.value =
                                        indetail.warehouse_stock_good;
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
                                    onTap: () {
                                      Get.back();
                                      // _refreshBottomSheet(indetail);
                                    })
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ));
  }

  Widget modalBottomSheet(StockDetail detail) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: GlobalVar.height * 0.85,
      child: Container(
        // addqtypickitemoverlaycheckctnj (25:1581)
        padding: EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                // editvitasoylemonteadrink250mlG (11:1249)
                // margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 59 * fem, 10 * fem),
                child: Text(
                  ' ${detail.item_name}',
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
                // editvitasoylemonteadrink250mlG (11:1249)
                // margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 59 * fem, 10 * fem),
                child: GestureDetector(
                  child: Image.asset(
                    'data/images/cancel-viF.png',
                    width: 30 * fem,
                    height: 30 * fem,
                  ),
                  onTap: () {
                    Get.back();
                    // if (indetail.uom
                    //         .where((element) => element.uom == "CTN")
                    //         .toList()
                    //         .length !=
                    //     0) {
                    //   pickedbox.value = int.parse(indetail.uom
                    //       .where((element) => element.uom == "CTN")
                    //       .toList()[0]
                    //       .total_picked);
                    // }
                    // if (indetail.uom
                    //         .where((element) => element.uom == "PCS")
                    //         .toList()
                    //         .length !=
                    //     0) {
                    //   pickedbun.value = int.parse(indetail.uom
                    //       .where((element) => element.uom == "PCS")
                    //       .toList()[0]
                    //       .total_picked);
                    // }
                    // Get.back();
                  },
                ),
              ),
            ]),
            // Container(
            //   // meijifreshmilk450mlQac (25:1582)
            //   margin: EdgeInsets.fromLTRB(1 * fem, 0 * fem, 0 * fem, 9 * fem),
            //   child: Text(
            //     '${detail.item_name}',
            //     textAlign: TextAlign.center,
            //     style: SafeGoogleFont(
            //       'Roboto',
            //       fontSize: 24 * ffem,
            //       fontWeight: FontWeight.w600,
            //       height: 1.1725 * ffem / fem,
            //       color: Color(0xfff44236),
            //     ),
            //   ),
            // ),
            Container(
              // borderJAC (25:1583)
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 5 * fem),
              width: double.infinity,
              height: 1 * fem,
              decoration: BoxDecoration(
                color: Color(0xffa8a8a8),
              ),
            ),
            GestureDetector(
                child: Container(
                  // imagedCU (25:1595)
                  margin: EdgeInsets.fromLTRB(
                      120 * fem, 0 * fem, 120 * fem, 6 * fem),
                  padding:
                      EdgeInsets.fromLTRB(5 * fem, 6 * fem, 5 * fem, 6 * fem),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xfff44236)),
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(8 * fem),
                  ),
                  child: Center(
                    // bdbfad6c1c455b9ccc448655df81b3 (25:1597)
                    child: SizedBox(
                      width: 110 * fem,
                      height: 108 * fem,
                      child: Image.asset(
                        'data/images/cancel-viF.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Get.back();
                }),
            Container(
              // borderdLt (25:1584)
              width: double.infinity,
              height: 1 * fem,
              decoration: BoxDecoration(
                color: Color(0xffa8a8a8),
              ),
            ),
            Container(
              // autogroupmh6gPL4 (Xy4qcxtCLbXzGCKGbFmh6g)
              padding:
                  EdgeInsets.fromLTRB(51 * fem, 11 * fem, 16 * fem, 8 * fem),
              width: double.infinity,
              child: ValueListenableBuilder(
                  valueListenable: pcsctnnotifier,
                  builder: (BuildContext context, bool value, Widget child) {
                    return ValueListenableBuilder(
                        valueListenable: pcsctnnotifier.value == false
                            ? pickedctnmain
                            : pickedpcsmain,
                        builder:
                            (BuildContext context, int value, Widget child) {
                          return ValueListenableBuilder(
                              valueListenable: pcsctnnotifier.value == false
                                  ? pickedctngood
                                  : pickedpcsgood,
                              builder: (BuildContext context, int value,
                                  Widget child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      // buttonupC (25:1598)
                                      margin: EdgeInsets.fromLTRB(69 * fem,
                                          0 * fem, 104 * fem, 8 * fem),
                                      padding: EdgeInsets.fromLTRB(
                                          2 * fem, 2 * fem, 2 * fem, 2 * fem),
                                      width: double.infinity,
                                      height: 30 * fem,
                                      decoration: BoxDecoration(
                                        color: Color(0xffd9d9d9),
                                        borderRadius:
                                            BorderRadius.circular(8 * fem),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                              child: Container(
                                                // ctnbuttonA7r (25:1627)
                                                width: 54 * fem,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: pcsctnnotifier.value ==
                                                          false
                                                      ? Color(0xffffffff)
                                                      : Color(0xffd9d9d9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8 * fem),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'CTN',
                                                    textAlign: TextAlign.center,
                                                    style: SafeGoogleFont(
                                                      'Roboto',
                                                      fontSize: 12 * ffem,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height:
                                                          1.1725 * ffem / fem,
                                                      color: Color(0xff000000),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  pcsctnnotifier.value = false;
                                                });
                                              }),
                                          Container(
                                            // pcsbuttonKN8 (25:1626)
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 2 * fem, 0 * fem),
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  pcsctnnotifier.value = true;
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Container(
                                                width: 54 * fem,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: pcsctnnotifier.value
                                                      ? Color(0xffffffff)
                                                      : Color(0xffd9d9d9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8 * fem),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${detail.uom}',
                                                    textAlign: TextAlign.center,
                                                    style: SafeGoogleFont(
                                                      'Roboto',
                                                      fontSize: 12 * ffem,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height:
                                                          1.1725 * ffem / fem,
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
                                    Container(
                                      // currentquantityFuz (25:1603)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 36 * fem, 6 * fem),
                                      child: Text(
                                        'Current Quantity',
                                        textAlign: TextAlign.center,
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w600,
                                          height: 1.1725 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // autogroupmbp6Zvg (Xy4pUzn7bAHLMDesSKMbP6)
                                      margin: EdgeInsets.fromLTRB(16 * fem,
                                          0 * fem, 51 * fem, 12 * fem),
                                      width: double.infinity,
                                      height: 69 * fem,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            // group7Hbn (25:1613)
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 68 * fem, 0 * fem),
                                            width: 79 * fem,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      6 * fem),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  // autogroupcdvg11z (Xy4pkzKU5GQQGV9WgncDvG)
                                                  margin: EdgeInsets.fromLTRB(
                                                      0 * fem,
                                                      0 * fem,
                                                      0 * fem,
                                                      4 * fem),
                                                  width: double.infinity,
                                                  height: 46 * fem,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffe0e0e0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6 * fem),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      pcsctnnotifier.value
                                                          ? '${detail.stock_main}'
                                                          : '${detail.stock_main_ctn}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: SafeGoogleFont(
                                                        'Roboto',
                                                        fontSize: 24 * ffem,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height:
                                                            1.1725 * ffem / fem,
                                                        color:
                                                            Color(0xff000000),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  // goodstockURN (25:1616)
                                                  'Main',
                                                  textAlign: TextAlign.center,
                                                  style: SafeGoogleFont(
                                                    'Roboto',
                                                    fontSize: 16 * ffem,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.1725 * ffem / fem,
                                                    color: Color(0xff9a9a9a),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            // group8Ddr (25:1605)
                                            width: 79 * fem,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      6 * fem),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  // autogroupovjnMVA (Xy4peABWodxRcddkzAoVjN)
                                                  margin: EdgeInsets.fromLTRB(
                                                      0 * fem,
                                                      0 * fem,
                                                      0 * fem,
                                                      4 * fem),
                                                  width: double.infinity,
                                                  height: 46 * fem,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffe0e0e0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6 * fem),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      pcsctnnotifier.value
                                                          ? '${detail.stock_good}'
                                                          : '${detail.stock_good_ctn}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: SafeGoogleFont(
                                                        'Roboto',
                                                        fontSize: 24 * ffem,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height:
                                                            1.1725 * ffem / fem,
                                                        color:
                                                            Color(0xff000000),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  // badstockEJ4 (25:1608)
                                                  'Good',
                                                  textAlign: TextAlign.center,
                                                  style: SafeGoogleFont(
                                                    'Roboto',
                                                    fontSize: 16 * ffem,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.1725 * ffem / fem,
                                                    color: Color(0xff9a9a9a),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // actualquantityNfA (25:1604)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 32 * fem, 6 * fem),
                                      child: Text(
                                        'Actual Quantity',
                                        textAlign: TextAlign.center,
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w600,
                                          height: 1.1725 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // autogrouponhnJHv (Xy4prEfixBAQeVhZr4oNHN)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 27 * fem, 12 * fem),
                                      width: double.infinity,
                                      height: 69 * fem,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            child: Container(
                                              // group102ji (25:1617)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  32 * fem,
                                                  0 * fem),
                                              width: 117 * fem,
                                              height: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    // autogroupuse8ZUk (Xy4q1jPuJVJEHZTm66UsE8)
                                                    margin: EdgeInsets.fromLTRB(
                                                        0 * fem,
                                                        0 * fem,
                                                        0 * fem,
                                                        4 * fem),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            5 * fem,
                                                            7 * fem,
                                                            2 * fem,
                                                            7 * fem),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Color(
                                                              0xffe0e0e0)),
                                                      color: Color(0xffffffff),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6 * fem),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        // Container(
                                                        //   // subtract2t8 (90:1664)
                                                        //   margin: EdgeInsets.fromLTRB(
                                                        //       0 * fem, 0 * fem, 12 * fem, 0 * fem),
                                                        //   width: 28 * fem,
                                                        //   height: 28 * fem,
                                                        //   child: Image.asset(
                                                        //     'assets/page-1/images/subtract-Woi.png',
                                                        //     fit: BoxFit.contain,
                                                        //   ),
                                                        // ),
                                                        Container(
                                                          // kJL (25:1619)
                                                          margin: EdgeInsets.fromLTRB(
                                                              detail.warehouse_stock_main
                                                                              .toString()
                                                                              .length ==
                                                                          1 ||
                                                                      detail.warehouse_stock_main_ctn
                                                                              .toString()
                                                                              .length ==
                                                                          1
                                                                  ? 45 * fem
                                                                  : 30 * fem,
                                                              1 * fem,
                                                              10 * fem,
                                                              0 * fem),
                                                          child: Text(
                                                            pcsctnnotifier.value
                                                                ? '${pickedpcsmain.value}'
                                                                : '${pickedctnmain.value}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                SafeGoogleFont(
                                                              'Roboto',
                                                              fontSize:
                                                                  24 * ffem,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              height: 1.1725 *
                                                                  ffem /
                                                                  fem,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: Color(
                                                                  0xff000000),
                                                              decorationColor:
                                                                  Color(
                                                                      0xff000000),
                                                            ),
                                                          ),
                                                        ),
                                                        // Container(
                                                        //   // addGGg (90:1661)
                                                        //   width: 32 * fem,
                                                        //   height: 32 * fem,
                                                        //   child: Image.asset(
                                                        //     'assets/page-1/images/add-LDN.png',
                                                        //     width: 32 * fem,
                                                        //     height: 32 * fem,
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    // goodstockzyN (25:1620)
                                                    margin: EdgeInsets.fromLTRB(
                                                        0 * fem,
                                                        0 * fem,
                                                        4 * fem,
                                                        0 * fem),
                                                    child: Text(
                                                      'Main',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: SafeGoogleFont(
                                                        'Roboto',
                                                        fontSize: 16 * ffem,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height:
                                                            1.1725 * ffem / fem,
                                                        color:
                                                            Color(0xff9a9a9a),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              if (pcsctnnotifier.value ==
                                                  true) {
                                                _controllermain =
                                                    TextEditingController(
                                                        text: pickedpcsmain
                                                            .value
                                                            .toString());

                                                typeIndexmain = int.parse(
                                                    _controllermain.text);

                                                _controllergood =
                                                    TextEditingController(
                                                        text: pickedpcsgood
                                                            .value
                                                            .toString());

                                                typeIndexgood = int.parse(
                                                    _controllergood.text);
                                              } else {
                                                _controllermain =
                                                    TextEditingController(
                                                        text: pickedctnmain
                                                            .value
                                                            .toString());

                                                typeIndexmain = int.parse(
                                                    _controllermain.text);

                                                _controllergood =
                                                    TextEditingController(
                                                        text: pickedctngood
                                                            .value
                                                            .toString());

                                                typeIndexgood = int.parse(
                                                    _controllergood.text);
                                              }
                                              if (pcsctnnotifier.value ==
                                                  false) {
                                                tabs = 0;
                                              } else {
                                                tabs = 1;
                                              }
                                              _showMyDialog(
                                                  detail, pcsctnnotifier.value);
                                            },
                                          ),
                                          GestureDetector(
                                            child: Container(
                                              // group11uqS (89:1631)
                                              width: 117 * fem,
                                              height: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    // autogroupyxjgrkg (Xy4qFE1RGpxpQSbceEyXJg)
                                                    margin: EdgeInsets.fromLTRB(
                                                        0 * fem,
                                                        0 * fem,
                                                        0 * fem,
                                                        4 * fem),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            3 * fem,
                                                            7 * fem,
                                                            3 * fem,
                                                            7 * fem),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Color(
                                                              0xffe0e0e0)),
                                                      color: Color(0xffffffff),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6 * fem),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          // s9z (89:1633)
                                                          margin: EdgeInsets.fromLTRB(
                                                              pickedpcsgood.value
                                                                              .toString()
                                                                              .length ==
                                                                          1 ||
                                                                      pickedpcsgood
                                                                              .value
                                                                              .toString()
                                                                              .length ==
                                                                          1
                                                                  ? 50 * fem
                                                                  : 30 * fem,
                                                              1 * fem,
                                                              9 * fem,
                                                              0 * fem),
                                                          child: Text(
                                                            pcsctnnotifier.value
                                                                ? '${pickedpcsgood.value}'
                                                                : '${pickedctngood.value}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                SafeGoogleFont(
                                                              'Roboto',
                                                              fontSize:
                                                                  24 * ffem,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              height: 1.1725 *
                                                                  ffem /
                                                                  fem,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: Color(
                                                                  0xff000000),
                                                              decorationColor:
                                                                  Color(
                                                                      0xff000000),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    // badstock7q2 (89:1634)
                                                    margin: EdgeInsets.fromLTRB(
                                                        0 * fem,
                                                        0 * fem,
                                                        4 * fem,
                                                        0 * fem),
                                                    child: Text(
                                                      'Good',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: SafeGoogleFont(
                                                        'Roboto',
                                                        fontSize: 16 * ffem,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height:
                                                            1.1725 * ffem / fem,
                                                        color:
                                                            Color(0xff9a9a9a),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              if (pcsctnnotifier.value ==
                                                  true) {
                                                _controllermain =
                                                    TextEditingController(
                                                        text: pickedpcsmain
                                                            .value
                                                            .toString());

                                                typeIndexmain = int.parse(
                                                    _controllermain.text);

                                                _controllergood =
                                                    TextEditingController(
                                                        text: pickedpcsgood
                                                            .value
                                                            .toString());

                                                typeIndexgood = int.parse(
                                                    _controllergood.text);
                                              } else {
                                                _controllermain =
                                                    TextEditingController(
                                                        text: pickedctnmain
                                                            .value
                                                            .toString());

                                                typeIndexmain = int.parse(
                                                    _controllermain.text);

                                                _controllergood =
                                                    TextEditingController(
                                                        text: pickedctngood
                                                            .value
                                                            .toString());

                                                typeIndexgood = int.parse(
                                                    _controllergood.text);
                                              }
                                              if (pcsctnnotifier.value ==
                                                  false) {
                                                tabs = 0;
                                              } else {
                                                tabs = 1;
                                              }
                                              _showMyDialog(
                                                  detail, pcsctnnotifier.value);
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // autogroup1r9aScQ (Xy4qRDimKtnjbz2mRY1R9A)
                                      margin: EdgeInsets.fromLTRB(
                                          105 * fem, 0 * fem, 0 * fem, 0 * fem),
                                      width: double.infinity,
                                      height: 40 * fem,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                              child: Container(
                                                // cancelbuttonZS8 (25:1585)
                                                margin: EdgeInsets.fromLTRB(
                                                    0 * fem,
                                                    0 * fem,
                                                    16 * fem,
                                                    0 * fem),
                                                padding: EdgeInsets.fromLTRB(
                                                    24 * fem,
                                                    5 * fem,
                                                    25 * fem,
                                                    5 * fem),
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(0xfff44236)),
                                                  color: Color(0xffffffff),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12 * fem),
                                                ),
                                                child: Center(
                                                  // cancelTXW (25:1587)
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
                                              }),
                                          GestureDetector(
                                              child: Container(
                                                // savebuttonPAG (25:1590)
                                                padding: EdgeInsets.fromLTRB(
                                                    24 * fem,
                                                    5 * fem,
                                                    25 * fem,
                                                    5 * fem),
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xff2cab0c),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12 * fem),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0x3f000000),
                                                      offset: Offset(
                                                          0 * fem, 4 * fem),
                                                      blurRadius: 2 * fem,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  // checkcircleHFe (25:1592)
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
                                              onTap: () async {
                                                _showMyDialogApprove(
                                                    stockcheckVM.toliststock
                                                        .value[widget.index],
                                                    detail,
                                                    "modal");
                                              })
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              });
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget headerCard(StockDetail stockmodel) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
        padding: EdgeInsets.fromLTRB(8 * fem, 8 * fem, 25 * fem, 7 * fem),
        // width: double.infinity,
        // height: 102 * fem,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(8 * fem),
          boxShadow: [
            BoxShadow(
              color: Color(0x3f000000),
              offset: Offset(0 * fem, 4 * fem),
              blurRadius: 5 * fem,
            ),
          ],
        ),
        child: ListTile(
          // contentPadding: EdgeInsets.fromLTRB(7 * fem, 0 * fem, 9 * fem, 0 * fem),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 2 * fem),
                      constraints: BoxConstraints(maxWidth: 160 * fem),
                      child: Text(
                        '${stockmodel.item_name}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff2d2d2d),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 1 * fem),
                      child: Text(
                        'SKU: ${stockmodel.item_code}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 1 * fem),
                      child: Text(
                        stockmodel.checked == 1
                            ? 'Main: ${stockmodel.warehouse_stock_main}      Good: ${stockmodel.warehouse_stock_good} '
                            : 'Main: ${stockmodel.stock_main}      Good: ${stockmodel.stock_good} ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    Text(
                      stockmodel.formatted_updated_at.contains("Today")
                          ? 'Last Stock Check: ${stockmodel.formatted_updated_at}'
                          : stockmodel.formatted_updated_at
                                  .contains("Yesterday")
                              ? 'Last Stock Check: ${stockmodel.formatted_updated_at}'
                              : globalVM.stringToDateWithTime(
                                  stockmodel.formatted_updated_at),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.1725 * ffem / fem,
                        color: Color(0xff9a9a9a),
                      ),
                    ),
                  ],
                ),
              ),
              stockmodel.checked != 0
                  ? Padding(
                      child: Image.asset(
                        'data/images/check-circle-TqJ.png',
                        width: 26 * fem,
                        height: 26 * fem,
                      ),
                      padding: EdgeInsets.only(left: 20),
                    )
                  : SizedBox(),
              Expanded(
                flex: 1,
                child: stockmodel.checked == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 2 * fem),
                            constraints: BoxConstraints(maxWidth: 41 * fem),
                            child: Text(
                              'Total\nStock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xfff44236),
                              ),
                            ),
                          ),
                          Text(
                            calculateStock(stockmodel.warehouse_stock_main,
                                stockmodel.warehouse_stock_good),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff2d2d2d),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 2 * fem),
                            constraints: BoxConstraints(maxWidth: 41 * fem),
                            child: Text(
                              'Total\nStock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xfff44236),
                              ),
                            ),
                          ),
                          Text(
                            calculateStock(stockmodel.warehouse_stock_main,
                                stockmodel.warehouse_stock_good),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff2d2d2d),
                            ),
                          ),
                        ],
                      ),
              ),
              Visibility(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        20 * fem, 0 * fem, 0 * fem, 0 * fem),
                    width: 11 * fem,
                    height: 20 * fem,
                    child: Image.asset(
                      'data/images/vector-1HV.png',
                      width: 11 * fem,
                      height: 20 * fem,
                    ),
                  ),
                  visible: widget.flag != "history")
            ],
          ),
        ));
  }

  Widget headerCard2(StockDetail stockmodel) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Container(
        padding: EdgeInsets.fromLTRB(3 * fem, 0 * fem, 2 * fem, 5 * fem),
        child: Container(
          padding: EdgeInsets.fromLTRB(8 * fem, 8 * fem, 17.5 * fem, 7 * fem),
          width: double.infinity,
          height: 102 * fem,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(8 * fem),
            boxShadow: [
              BoxShadow(
                color: Color(0x3f000000),
                offset: Offset(0 * fem, 4 * fem),
                blurRadius: 5 * fem,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 2 * fem),
                      constraints: BoxConstraints(maxWidth: 160 * fem),
                      child: Text(
                        '${stockmodel.item_name}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff2d2d2d),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 1 * fem),
                      child: Text(
                        'SKU: ${stockmodel.item_code}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 1 * fem),
                      child: Text(
                        stockmodel.checked == 1
                            ? 'Main: ${stockmodel.warehouse_stock_main}      Good: ${stockmodel.warehouse_stock_good} '
                            : 'Main: ${stockmodel.stock_main}      Good: ${stockmodel.stock_good} ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    Text(
                      stockmodel.formatted_updated_at.contains("Today")
                          ? 'Last Stock Check: ${stockmodel.formatted_updated_at}'
                          : stockmodel.formatted_updated_at
                                  .contains("Yesterday")
                              ? 'Last Stock Check: ${stockmodel.formatted_updated_at}'
                              : globalVM.stringToDateWithTime(
                                  stockmodel.formatted_updated_at),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.1725 * ffem / fem,
                        color: Color(0xff9a9a9a),
                      ),
                    ),
                  ],
                ),
              ),
              stockmodel.checked != 0
                  ? Padding(
                      child: Image.asset(
                        'data/images/check-circle-TqJ.png',
                        width: 26 * fem,
                        height: 26 * fem,
                      ),
                      padding: EdgeInsets.only(left: 20),
                    )
                  : SizedBox(),
              Expanded(
                flex: 1,
                child: stockmodel.checked == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 2 * fem),
                            constraints: BoxConstraints(maxWidth: 41 * fem),
                            child: Text(
                              'Total\nStock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xfff44236),
                              ),
                            ),
                          ),
                          Text(
                            calculateStock(stockmodel.warehouse_stock_main,
                                stockmodel.warehouse_stock_good),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff2d2d2d),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 2 * fem),
                            constraints: BoxConstraints(maxWidth: 41 * fem),
                            child: Text(
                              'Total\nStock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xfff44236),
                              ),
                            ),
                          ),
                          Text(
                            calculateStock(stockmodel.warehouse_stock_main,
                                stockmodel.warehouse_stock_good),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 15 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xff2d2d2d),
                            ),
                          ),
                        ],
                      ),
              ),
              Visibility(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                        20 * fem, 0 * fem, 0 * fem, 0 * fem),
                    width: 11 * fem,
                    height: 20 * fem,
                    child: Image.asset(
                      'data/images/vector-1HV.png',
                      width: 11 * fem,
                      height: 20 * fem,
                    ),
                  ),
                  visible: widget.flag != "history")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color of the scan button
      "Cancel", // Text of the cancel button
      true, // Enable flash
      ScanMode.BARCODE, // Type of barcode to scan
    );

    if (barcodeScanRes != null && barcodeScanRes != "") {
      // pickedctn = TextEditingController();
      // pickedpcs = TextEditingController();

      pcsctnnotifier.value = false;

      pickedctnmain.value = stockcheckVM.toliststock.value[widget.index].detail
          .where((element) => element.item_code.contains(barcodeScanRes))
          .toList()[0]
          .warehouse_stock_main_ctn;
      pickedctngood.value = stockcheckVM.toliststock.value[widget.index].detail
          .where((element) => element.item_code.contains(barcodeScanRes))
          .toList()[0]
          .warehouse_stock_good_ctn;
      pickedpcsmain.value = stockcheckVM.toliststock.value[widget.index].detail
          .where((element) => element.item_code.contains(barcodeScanRes))
          .toList()[0]
          .warehouse_stock_main;
      pickedpcsgood.value = stockcheckVM.toliststock.value[widget.index].detail
          .where((element) => element.item_code.contains(barcodeScanRes))
          .toList()[0]
          .warehouse_stock_good;
      fromscan = false;

      showMaterialModalBottomSheet(
        context: context,
        builder: (context) => modalBottomSheet(stockcheckVM
            .toliststock.value[widget.index].detail
            .where((element) => element.item_code.contains(barcodeScanRes))
            .toList()[0]),
      );
    }

    // This will print the scanned barcode value
  }

  List<Widget> _buildActions() {
    return <Widget>[
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: scanBarcode,
          ),
          IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () {
                _showMyDialogReject("refresh");
              }),
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {},
          // ),
        ],
      )
    ];
  }

  List<Widget> _buildActionsHistory() {
    return <Widget>[
      Row(
        children: [
          Switch(
            // activeTrackColor: Colors.amber,
            value: light0,
            onChanged: (bool value) {
              setState(() {
                light0 = value;
              });
            },
          ),
        ],
      )
    ];
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      searchWF(newQuery);
      // }
    });
  }

  void searchWF(String search) async {
    stockcheckVM.toliststock.value[widget.index].detail.clear();

    var locallist2 = listdetailstock
        .where((element) => element.item_code.toLowerCase().contains(search))
        .toList();

    var localsku = listdetailstock
        .where((element) => element.item_name.toLowerCase().contains(search))
        .toList();

    if (locallist2.length > 0) {
      for (var i = 0; i < locallist2.length; i++) {
        stockcheckVM.toliststock.value[widget.index].detail.add(locallist2[i]);
      }
    } else {
      for (var i = 0; i < localsku.length; i++) {
        stockcheckVM.toliststock.value[widget.index].detail.add(localsku[i]);
      }
    }
  }

  void _startSearch() {
    setState(() {
      listdetailstock.clear();
      var locallist = stockcheckVM.toliststock.value[widget.index].detail;
      for (var i = 0; i < locallist.length; i++) {
        listdetailstock.add(locallist[i]);
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

      stockcheckVM.toliststock.value[widget.index].detail.clear();

      for (var item in listdetailstock) {
        stockcheckVM.toliststock.value[widget.index].detail.add(item);
      }
      // Get.to(InDetailPage(index));
    });
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

  List<Widget> _buildActions2() {
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
          Switch(
            // activeTrackColor: Colors.amber,
            value: light0,
            onChanged: (bool value) {
              setState(() {
                light0 = value;
              });
            },
          ),
          IconButton(icon: const Icon(Icons.qr_code), onPressed: scanBarcode),
          IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () {
                _showMyDialogReject("refresh");
              }),
          Visibility(
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _startSearch,
              ),
              visible: light0)
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    actions: widget.flag == "history"
                        ? _buildActionsHistory()
                        : stockcheckVM
                                    .toliststock.value[widget.index].location !=
                                "HQ"
                            ? _buildActions2()
                            : _buildActions(),
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 20.0,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    // leading: IconButton(
                    //   onPressed: () {
                    //     Get.back();
                    //   },
                    //   icon: Icon(Icons.arrow_back, color: kWhiteColor),
                    // ),

                    backgroundColor: Colors.red,

                    // leading: _isSearching ? const BackButton() : null,
                    title: _isSearching
                        ? _buildSearchField()
                        : Container(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextWidget(
                                    text: "${stockcheckVM.toliststock.value[widget.index].location}" +
                                        " - " +
                                        "${stockcheckVM.toliststock.value[widget.index].location_name}",
                                    isBlueTxt: false,
                                    maxLines: 2,
                                    size: 20,
                                    color: Colors.white))),

                    // actions: widget.listTrack != null ? null : _buildActions(),
                    centerTitle: true),
                backgroundColor: kWhiteColor,
                body: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      stockcheckVM.toliststock.value[widget.index].location !=
                                  "HQ" &&
                              light0 == false
                          ? Visibility(
                              visible: light0 == true,
                              child: Container(
                                // outcategoryb44 (63:917)
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 9 * fem),
                                width: double.infinity,
                                height: 50 * fem,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        child: Container(
                                          // weborderbuttonWwi (63:921)
                                          width: 180 * fem,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: ontap == true
                                                    ? Color(0xfff44236)
                                                    : Color(0xffa8a8a8)),
                                            color: ontap == true
                                                ? Color(0xfffeeceb)
                                                : Color(0xffffffff),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Stock List',
                                              textAlign: TextAlign.center,
                                              style: SafeGoogleFont(
                                                'Roboto',
                                                fontSize: 16 * ffem,
                                                fontWeight: FontWeight.w500,
                                                height: 1.1725 * ffem / fem,
                                                color: ontap == true
                                                    ? Color(0xfff44236)
                                                    : Color(0xffa8a8a8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            ontap = true;
                                          });
                                        }),
                                    GestureDetector(
                                        child: Container(
                                          // stockrequestbuttonbTN (63:918)
                                          width: 165 * fem,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: ontap == false
                                                    ? Color(0xfff44236)
                                                    : Color(0xffa8a8a8)),
                                            color: ontap == false
                                                ? Color(0xfffeeceb)
                                                : Color(0xffffffff),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Scanned Stock',
                                              textAlign: TextAlign.center,
                                              style: SafeGoogleFont(
                                                'Roboto',
                                                fontSize: 16 * ffem,
                                                fontWeight: FontWeight.w500,
                                                height: 1.1725 * ffem / fem,
                                                color: ontap == false
                                                    ? Color(0xfff44236)
                                                    : Color(0xffa8a8a8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            ontap = false;
                                          });
                                        })
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              // outcategoryb44 (63:917)
                              margin: EdgeInsets.fromLTRB(
                                  0 * fem, 0 * fem, 0 * fem, 9 * fem),
                              width: double.infinity,
                              height: 50 * fem,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      child: Container(
                                        // weborderbuttonWwi (63:921)
                                        width: 165 * fem,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ontap == true
                                                  ? Color(0xfff44236)
                                                  : Color(0xffa8a8a8)),
                                          color: ontap == true
                                              ? Color(0xfffeeceb)
                                              : Color(0xffffffff),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Stock List',
                                            textAlign: TextAlign.center,
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 16 * ffem,
                                              fontWeight: FontWeight.w500,
                                              height: 1.1725 * ffem / fem,
                                              color: ontap == true
                                                  ? Color(0xfff44236)
                                                  : Color(0xffa8a8a8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          ontap = true;
                                        });
                                      }),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                      child: Container(
                                        // stockrequestbuttonbTN (63:918)
                                        width: 160 * fem,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ontap == false
                                                  ? Color(0xfff44236)
                                                  : Color(0xffa8a8a8)),
                                          color: ontap == false
                                              ? Color(0xfffeeceb)
                                              : Color(0xffffffff),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Scanned Stock',
                                            textAlign: TextAlign.center,
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 16 * ffem,
                                              fontWeight: FontWeight.w500,
                                              height: 1.1725 * ffem / fem,
                                              color: ontap == false
                                                  ? Color(0xfff44236)
                                                  : Color(0xffa8a8a8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          ontap = false;
                                        });
                                      })
                                ],
                              ),
                            ),
                      Visibility(
                          child: Padding(
                              child: Wrap(
                                children: listchoice
                                    .map((e) => ChoiceChip(
                                          padding: EdgeInsets.only(
                                              left: 25, right: 25),
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
                                          label: Text(
                                            e.label,
                                          ),
                                          selected: idPeriodSelected == e.id,
                                          onSelected: (_) {
                                            setState(() {
                                              idPeriodSelected = e.id;
                                              int choice = idPeriodSelected - 1;
                                              if (choice == 0) {
                                                GlobalVar.choicecategory = "AB";
                                              } else if (choice == 1) {
                                                GlobalVar.choicecategory = "CH";
                                              } else {
                                                GlobalVar.choicecategory = "FZ";
                                              }
                                              // inVM.choicein.value =
                                              //     listchoice[choice].label;
                                              // inVM.onReady();
                                            });
                                            // changeSelectedId('Period', e.id);
                                          },
                                          selectedColor: GlobalVar
                                                      .choicecategory ==
                                                  "AB"
                                              ? Colors.red
                                              : GlobalVar.choicecategory == "FZ"
                                                  ? Colors.blue
                                                  : Colors.green,
                                          // ? Colors.white
                                          // : inVM.choicein.value == "FZ"
                                          //     ? Colors.blue
                                          //     : inVM.choicein.value ==
                                          //             "CH"
                                          //         ? Colors.green
                                          //         : Color(0xfff44236),
                                          elevation: 10,
                                        ))
                                    .toList(),
                                spacing: 25,
                              ),
                              padding: EdgeInsets.only(bottom: 10)),
                          visible: stockcheckVM
                                  .toliststock.value[widget.index].location ==
                              "HQ"),
                      Visibility(
                          child: SizedBox(height: 130),
                          visible: light0 == false &&
                              stockcheckVM
                                      .toliststock.value[widget.index].detail
                                      .where((element) =>
                                          element.is_scanned.contains("Y"))
                                      .toList()
                                      .length ==
                                  0),
                      light0 == false &&
                              stockcheckVM
                                      .toliststock.value[widget.index].detail
                                      .where((element) =>
                                          element.is_scanned.contains("Y"))
                                      .toList()
                                      .length ==
                                  0
                          ? Center(
                              child: Container(
                                // undrawnodatarekwbl11XGU (23:995)
                                width: 252 * fem,
                                height: 225 * fem,
                                child: Image.asset(
                                  'data/images/undrawnodatarekwbl-1-1.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Obx(() {
                              return Expanded(
                                child: ListView.builder(
                                    controller: controller,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    // gridDelegate:
                                    //     SliverGridDelegateWithFixedCrossAxisCount(
                                    //         crossAxisCount: 1),
                                    itemCount: ontap == true && light0 == true
                                        ? stockcheckVM.toliststock
                                            .value[widget.index].detail.length
                                        : stockcheckVM
                                                    .toliststock
                                                    .value[widget.index]
                                                    .location ==
                                                "HQ"
                                            ? stockcheckVM.toliststock
                                                .value[widget.index].detail
                                                .where((element) =>
                                                    element.inventory_group
                                                        .contains(GlobalVar
                                                            .choicecategory) &&
                                                    element.is_scanned == "Y")
                                                .toList()
                                                .length
                                            : stockcheckVM.toliststock
                                                .value[widget.index].detail
                                                .where((element) => element
                                                    .is_scanned
                                                    .contains("Y"))
                                                .toList()
                                                .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        child: ontap == true && light0 == true
                                            ? headerCard(stockcheckVM
                                                .toliststock
                                                .value[widget.index]
                                                .detail[index])
                                            : stockcheckVM
                                                        .toliststock
                                                        .value[widget.index]
                                                        .location ==
                                                    "HQ"
                                                ? headerCard2(stockcheckVM
                                                    .toliststock
                                                    .value[widget.index]
                                                    .detail
                                                    .where((element) =>
                                                        element.inventory_group.contains(GlobalVar.choicecategory) &&
                                                        element.is_scanned ==
                                                            "Y")
                                                    .toList()[index])
                                                : headerCard2(stockcheckVM
                                                    .toliststock
                                                    .value[widget.index]
                                                    .detail
                                                    .where(
                                                        (element) => element.is_scanned.contains("Y"))
                                                    .toList()[index]),
                                        onTap: () async {
                                          if (widget.flag == "history") {
                                          } else {
                                            if (ontap == true) {
                                              pcsctnnotifier.value = false;

                                              pickedctnmain.value = stockcheckVM
                                                  .toliststock
                                                  .value[widget.index]
                                                  .detail[index]
                                                  .warehouse_stock_main_ctn;
                                              pickedctngood.value = stockcheckVM
                                                  .toliststock
                                                  .value[widget.index]
                                                  .detail[index]
                                                  .warehouse_stock_good_ctn;
                                              pickedpcsmain.value = stockcheckVM
                                                  .toliststock
                                                  .value[widget.index]
                                                  .detail[index]
                                                  .warehouse_stock_main;
                                              pickedpcsgood.value = stockcheckVM
                                                  .toliststock
                                                  .value[widget.index]
                                                  .detail[index]
                                                  .warehouse_stock_good;

                                              showMaterialModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    modalBottomSheet(
                                                        stockcheckVM
                                                            .toliststock
                                                            .value[widget.index]
                                                            .detail[index]),
                                              );
                                            } else {}
                                          }

                                          // Get.to(InDetailPage(index));
                                        },
                                      );
                                    }),
                              );
                            }),
                      widget.flag == "history"
                          ? Container()
                          : ontap == true && light0 == true
                              ? Container(
                                  // frame11azo (I11:802;11:371)
                                  // margin: EdgeInsets.fromLTRB(
                                  //     7.5 * fem, 0 * fem, 7.5 * fem, 0 * fem),
                                  padding: EdgeInsets.only(left: 22),
                                  width: double.infinity,
                                  height: 40 * fem,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        // cancelbuttonVM5 (I11:802;11:372)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 30 * fem, 0 * fem),
                                        child: TextButton(
                                          onPressed: () {
                                            _showMyDialogReject("reject");
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                52 * fem,
                                                5 * fem,
                                                53 * fem,
                                                5 * fem),
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xfff44236)),
                                              color: Color(0xffffffff),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12 * fem),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x3f000000),
                                                  offset:
                                                      Offset(0 * fem, 4 * fem),
                                                  blurRadius: 2 * fem,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              // cancelUyh (I11:802;11:374)
                                              child: SizedBox(
                                                width: 30 * fem,
                                                height: 30 * fem,
                                                child: Image.asset(
                                                  'data/images/cancel-ecb.png',
                                                  width: 30 * fem,
                                                  height: 30 * fem,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        // yesbuttonPas (I11:802;11:377)
                                        onPressed: () {
                                          setState(() {
                                            _showMyDialogApprove(
                                                stockcheckVM.toliststock
                                                    .value[widget.index],
                                                stockcheckVM
                                                    .toliststock
                                                    .value[widget.index]
                                                    .detail[0],
                                                "all");
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(52 * fem,
                                              5 * fem, 53 * fem, 5 * fem),
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xff2cab0c),
                                            borderRadius:
                                                BorderRadius.circular(12 * fem),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x3f000000),
                                                offset:
                                                    Offset(0 * fem, 4 * fem),
                                                blurRadius: 2 * fem,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            // checkcircleqhm (I11:802;11:379)
                                            child: SizedBox(
                                              width: 30 * fem,
                                              height: 30 * fem,
                                              child: Image.asset(
                                                'data/images/check-circle-LCb.png',
                                                width: 30 * fem,
                                                height: 30 * fem,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : stockcheckVM.toliststock.value[widget.index]
                                          .detail
                                          .where((element) =>
                                              element.is_scanned.contains("Y"))
                                          .toList()
                                          .length !=
                                      0
                                  ? Container(
                                      // frame11azo (I11:802;11:371)
                                      // margin: EdgeInsets.fromLTRB(
                                      //     7.5 * fem, 0 * fem, 7.5 * fem, 0 * fem),
                                      padding: EdgeInsets.only(left: 22),
                                      width: double.infinity,
                                      height: 40 * fem,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            // cancelbuttonVM5 (I11:802;11:372)
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 30 * fem, 0 * fem),
                                            child: TextButton(
                                              onPressed: () {
                                                // _showMyDialogReject(inVM
                                                //     .tolistPO.value[widget.index]);
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    52 * fem,
                                                    5 * fem,
                                                    53 * fem,
                                                    5 * fem),
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(0xfff44236)),
                                                  color: Color(0xffffffff),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12 * fem),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(0x3f000000),
                                                      offset: Offset(
                                                          0 * fem, 4 * fem),
                                                      blurRadius: 2 * fem,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  // cancelUyh (I11:802;11:374)
                                                  child: SizedBox(
                                                    width: 30 * fem,
                                                    height: 30 * fem,
                                                    child: Image.asset(
                                                      'data/images/cancel-ecb.png',
                                                      width: 30 * fem,
                                                      height: 30 * fem,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            // yesbuttonPas (I11:802;11:377)
                                            onPressed: () {
                                              setState(() {
                                                // _showMyDialogApprove(inVM.tolistPO
                                                //     .value[widget.index]);
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  52 * fem,
                                                  5 * fem,
                                                  53 * fem,
                                                  5 * fem),
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0xff2cab0c),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12 * fem),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0x3f000000),
                                                    offset: Offset(
                                                        0 * fem, 4 * fem),
                                                    blurRadius: 2 * fem,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                // checkcircleqhm (I11:802;11:379)
                                                child: SizedBox(
                                                  width: 30 * fem,
                                                  height: 30 * fem,
                                                  child: Image.asset(
                                                    'data/images/check-circle-LCb.png',
                                                    width: 30 * fem,
                                                    height: 30 * fem,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()
                    ],
                  ),
                ))));
  }
}

class ItemChoice {
  final int id;
  final String label;

  ItemChoice(this.id, this.label);
}
