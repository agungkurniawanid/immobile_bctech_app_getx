import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/theme.dart';
import 'dart:convert';
import 'package:immobile/widget/text_field.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/indetail.dart';
import 'package:immobile/model/inmodel.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:immobile/page/mydialogPage.dart';

class InDetailPage extends StatefulWidget {
  final int index;
  final String from;
  final InModel flag;
  const InDetailPage(this.index, this.from, this.flag);
  @override
  _InDetailPage createState() => _InDetailPage();
}

class _InDetailPage extends State<InDetailPage> with TickerProviderStateMixin {
  AnimationController _controller;
  bool _allow = true;
  int idPeriodSelected = 1;
  List<String> sortList = ['PO Date', 'Vendor'];
  InVM inVM = Get.find();
  List<ItemChoice> listchoice = [];
  List<Category> listcategory = [];
  ScrollController controller;
  InModel cloned;
  InModel forclose;
  bool _leading = true;
  bool checkingscan = false;
  GlobalKey srKey = GlobalKey();
  final GlobalKey<FormState> keypcs = GlobalKey<FormState>();
  final pcsFieldKey = GlobalKey<FormFieldState<String>>();
  TextEditingController pcsinput = TextEditingController();
  TextEditingController ctninput = TextEditingController();
  TextEditingController expiredinput = TextEditingController();
  TextEditingController palletinput = TextEditingController();
  TextEditingController descriptioninput = TextEditingController();
  TextEditingController containerinput = TextEditingController();
  final _descriptioninputkey = GlobalKey<FormFieldState<String>>();
  // String ctn, pcs, pallet, expired, description;
  final formKey = GlobalKey<FormState>();
  TextEditingController _controllerctn;
  TextEditingController _controllerpcs;
  TextEditingController _controllerkg;
  int typeIndexctn = 0;
  int typeIndexpcs = 0;
  double typeIndexkg = 0.0;
  String datetime = "";
  List<TextEditingController> listpcsinput = new List();
  List<TextEditingController> listctninput = new List();
  List<TextEditingController> listpallet = new List();
  List<TextEditingController> listexpired = new List();
  List<TextEditingController> listdesc = new List();
  int tabs = 0;
  bool anyum = false;
  List<InDetail> listindetaillocal = new List<InDetail>();
  InModel listinmodel = new InModel();
  ValueNotifier<String> expireddate = ValueNotifier("");
  ValueNotifier<int> pcs = ValueNotifier(0);
  ValueNotifier<int> ctn = ValueNotifier(0);
  ValueNotifier<double> kg = ValueNotifier(0);
  bool _isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchQuery;
  String searchQuery;
  final currency = NumberFormat("#,###", "en_US");
  final currencydecimal = NumberFormat("#,###.##", "en_US");
  DateTime date;
  final SlidableController slidableController = SlidableController();
  String ebeln, barcodeScanRes;
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("CTN"),
    1: Text("PCS"),
    2: Text("KG")
  };
  final Map<int, Widget> myTabs2 = const <int, Widget>{0: Text("KG")};
  GlobalVM globalVM = Get.find();

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
    // _controller = AnimationController(
    //   duration: Duration(seconds: 3),
    //   vsync: this,
    // );

    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     Navigator.pop(context);
    //     _controller.reset();
    //   }
    // });

    _searchQuery = new TextEditingController();
    containerinput = new TextEditingController();
    if (widget.from == "sync") {
      ebeln = widget.flag.ebeln;
      cloned = InModel.clone(widget.flag);
      forclose = InModel.clone(widget.flag);
      scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      containerinput.text = widget.flag.truck;
    } else {
      ebeln = inVM.tolistPO.value[widget.index].ebeln;
      cloned = InModel.clone(inVM.tolistPO.value[widget.index]);
      forclose = InModel.clone(inVM.tolistPO.value[widget.index]);
      scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      containerinput.text = inVM.tolistPO.value[widget.index].truck;
    }

    _createProfile("DataWedgeFlutterDemo");
    startScan();
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  void _onEvent(event) {
    setState(() {
      Map barcodeScan = jsonDecode(event);
      _barcodeString = barcodeScan['scanData'];
      if (checkingscan == false) {
        if (widget.from == "history") {
        } else if (widget.from == "sync") {
          if (_barcodeString != null && _barcodeString != "") {
            pcsinput = TextEditingController();
            ctninput = TextEditingController();
            expiredinput = TextEditingController();
            palletinput = TextEditingController();

            descriptioninput = TextEditingController();
            var barcode = widget.flag.T_DATA
                .where((element) => element.barcode.contains(_barcodeString))
                .toList();
            // if (inVM.tolistPO.value[widget.index]
            //     .T_DATA[index].group
            //     .contains("UM")) {
            // } else {
            // pcs.value =
            // var anyumlocal = inVM.tolistPO
            //     .value[widget.index].T_DATA
            //     .where((element) =>
            //         element.group == "UM")
            //     .toList()
            //     .length;
            // if (anyumlocal > 0) {
            //   anyum = true;
            // } else {
            //   anyum = false;
            // }
            pcs.value = barcode[0].qtuom.toInt();
            ctn.value = barcode[0].qtctn;
            kg.value = barcode[0].qtuom;

            typeIndexctn = ctn.value;
            typeIndexpcs = pcs.value;
            typeIndexkg = kg.value;
            expireddate.value = barcode[0].vfdat;
            checkingscan = true;
            return showMaterialModalBottomSheet(
              context: context,
              builder: (context) => WillPopScope(
                onWillPop: () async {
                  Navigator.of(context).pop(); // Close the modal bottom sheet
                  checkingscan = false;
                  return true; // Allow the back button press
                },
                child: modalBottomSheet(barcode[0]),
              ),
            );
          }
          ;
        } else {
          if (_barcodeString != null && _barcodeString != "") {
            pcsinput = TextEditingController();
            ctninput = TextEditingController();
            expiredinput = TextEditingController();
            palletinput = TextEditingController();

            descriptioninput = TextEditingController();
            var barcode = inVM.tolistPO.value[widget.index].T_DATA
                .where((element) => element.barcode.contains(_barcodeString))
                .toList();
            // if (inVM.tolistPO.value[widget.index]
            //     .T_DATA[index].group
            //     .contains("UM")) {
            // } else {
            // pcs.value =
            // var anyumlocal = inVM.tolistPO
            //     .value[widget.index].T_DATA
            //     .where((element) =>
            //         element.group == "UM")
            //     .toList()
            //     .length;
            // if (anyumlocal > 0) {
            //   anyum = true;
            // } else {
            //   anyum = false;
            // }
            pcs.value = barcode[0].qtuom.toInt();
            ctn.value = barcode[0].qtctn;
            kg.value = barcode[0].qtuom;

            typeIndexctn = ctn.value;
            typeIndexpcs = pcs.value;
            typeIndexkg = kg.value;
            expireddate.value = barcode[0].vfdat;
            checkingscan = true;
            return showMaterialModalBottomSheet(
              context: context,
              builder: (context) => WillPopScope(
                onWillPop: () async {
                  Navigator.of(context).pop(); // Close the modal bottom sheet
                  checkingscan = false;
                  return true; // Allow the back button press
                },
                child: modalBottomSheet(barcode[0]),
              ),
            );
          }
          ;
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
  //   ebeln = inVM.tolistPO.value[widget.index].ebeln;
  // }

  Future<void> scanBarcode() async {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", // Color of the scan button
      "Cancel", // Text of the cancel button
      true, // Enable flash
      ScanMode.BARCODE, // Type of barcode to scan
    );

    if (barcodeScanRes != null && barcodeScanRes != "") {
      pcsinput = TextEditingController();
      ctninput = TextEditingController();
      expiredinput = TextEditingController();
      palletinput = TextEditingController();

      descriptioninput = TextEditingController();
      var barcode = inVM.tolistPO.value[widget.index].T_DATA
          .where((element) => element.barcode.contains(barcodeScanRes))
          .toList();
      // if (inVM.tolistPO.value[widget.index]
      //     .T_DATA[index].group
      //     .contains("UM")) {
      // } else {
      // pcs.value =
      // var anyumlocal = inVM.tolistPO
      //     .value[widget.index].T_DATA
      //     .where((element) =>
      //         element.group == "UM")
      //     .toList()
      //     .length;
      // if (anyumlocal > 0) {
      //   anyum = true;
      // } else {
      //   anyum = false;
      // }
      pcs.value = barcode[0].qtuom.toInt();
      ctn.value = barcode[0].qtctn;
      kg.value = barcode[0].qtuom;

      typeIndexctn = ctn.value;
      typeIndexpcs = pcs.value;
      typeIndexkg = kg.value;
      expireddate.value = barcode[0].vfdat;
      checkingscan = true;
      return showMaterialModalBottomSheet(
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(); // Close the modal bottom sheet
            checkingscan = false;
            return true; // Allow the back button press
          },
          child: modalBottomSheet(barcode[0]),
        ),
      );
    }
    ;

    // This will print the scanned barcode value
  }

  String _CalculTotalpcs() {
    if (widget.from == "sync") {
      double total = 0;
      for (var j = 0; j < widget.flag.T_DATA.length; j++) {
        //print(widget.controllers[i].text);
        total += widget.flag.T_DATA[j].qtuom;
      }
      String totalstring = total.toString();
      return totalstring;
    } else {
      double total = 0;
      for (var j = 0;
          j < inVM.tolistPO.value[widget.index].T_DATA.length;
          j++) {
        //print(widget.controllers[i].text);
        total += inVM.tolistPO.value[widget.index].T_DATA[j].qtuom;
      }
      String totalstring = total.toString();
      return totalstring;
    }
  }

  String _CalculTotalctn() {
    if (widget.from == "sync") {
      int total = 0;
      for (var j = 0; j < widget.flag.T_DATA.length; j++) {
        //print(widget.controllers[i].text);
        total += widget.flag.T_DATA[j].qtctn;
      }
      String totalstring = total.toString();
      return totalstring;
    } else {
      int total = 0;
      for (var j = 0;
          j < inVM.tolistPO.value[widget.index].T_DATA.length;
          j++) {
        //print(widget.controllers[i].text);
        total += inVM.tolistPO.value[widget.index].T_DATA[j].qtctn;
      }
      String totalstring = total.toString();
      return totalstring;
    }
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
      searchWF(newQuery);
      // }
    });
  }

  void searchWF(String search) async {
    if (widget.from == "sync") {
      widget.flag.T_DATA.clear();

      var locallist2 = listindetaillocal
          .where((element) => element.maktx.toLowerCase().contains(search))
          .toList();

      var localsku = listindetaillocal
          .where((element) => element.matnr.toLowerCase().contains(search))
          .toList();

      if (locallist2.length > 0) {
        for (var i = 0; i < locallist2.length; i++) {
          widget.flag.T_DATA.add(locallist2[i]);
        }
      } else {
        for (var i = 0; i < localsku.length; i++) {
          widget.flag.T_DATA.add(localsku[i]);
        }
      }
    } else {
      inVM.tolistPO.value[widget.index].T_DATA.clear();

      var locallist2 = listindetaillocal
          .where((element) => element.maktx.toLowerCase().contains(search))
          .toList();

      var localsku = listindetaillocal
          .where((element) => element.matnr.toLowerCase().contains(search))
          .toList();

      if (locallist2.length > 0) {
        for (var i = 0; i < locallist2.length; i++) {
          inVM.tolistPO.value[widget.index].T_DATA.add(locallist2[i]);
        }
      } else {
        for (var i = 0; i < localsku.length; i++) {
          inVM.tolistPO.value[widget.index].T_DATA.add(localsku[i]);
        }
      }
    }

    // for (var item in locallist) {
    //   inVM.tolistPO.value[widget.index].T_DATA.add(item);
    // }

    // var lengthmaktx = inVM.tolistPO.value[widget.index].T_DATA
    //     .where((element) => element.maktx.contains(search))
    //     .toList()
    //     .length;
    // var lengthskhu = inVM.tolistPO.value[widget.index].T_DATA
    //     .where((element) => element.matnr.contains(search))
    //     .toList()
    //     .length;
  }

  void _startSearch() {
    setState(() {
      if (widget.from == "sync") {
        listindetaillocal.clear();
        var locallist = widget.flag.T_DATA;
        for (var i = 0; i < locallist.length; i++) {
          listindetaillocal.add(locallist[i]);
        }
        _isSearching = true;
      } else {
        listindetaillocal.clear();
        var locallist = inVM.tolistPO.value[widget.index].T_DATA;
        for (var i = 0; i < locallist.length; i++) {
          listindetaillocal.add(locallist[i]);
        }
        _isSearching = true;
      }
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
      if (widget.from == "sync") {
        widget.flag.T_DATA.clear();

        for (var item in listindetaillocal) {
          widget.flag.T_DATA.add(item);
        }
      } else {
        inVM.tolistPO.value[widget.index].T_DATA.clear();

        for (var item in listindetaillocal) {
          inVM.tolistPO.value[widget.index].T_DATA.add(item);
        }
      }
      // Get.to(InDetailPage(index));
    });
  }

  Future _showMyDialogReject(InModel indetail) async {
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
                            'Are you sure to discard all changes made in this purchase order?',
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
                                onTap: () {
                                  // var backup = cloned
                                  //     .where(
                                  //         (element) => element.ebeln == ebeln)
                                  //     .toList()[0]
                                  //     .T_DATA;
                                  if (cloned.T_DATA.length == 0) {
                                  } else if (widget.flag == "sync") {
                                  } else {
                                    inVM.tolistPO.value[widget.index].T_DATA
                                        .clear();
                                    // var testing = inVM.tolistPObackup.value
                                    //     .where(
                                    //         (element) => element.ebeln == ebeln)
                                    //     .toList()[0];
                                    // print(testing);
                                    // for (int i = 0;
                                    //     i < cloned.T_DATA.length;
                                    //     i++) {
                                    // cloned.T_DATA[i].qtctn = 0;
                                    // cloned.T_DATA[i].qtuom = 0;
                                    // cloned.T_DATA[i].vfdat = "";
                                    // forclose = InModel.clone(cloned);
                                    // if (GlobalVar.choicecategory !=
                                    //     forclose.group) {
                                    //   inVM.tolistPO.removeWhere((element) =>
                                    //       element.ebeln == forclose.ebeln);
                                    // } else {
                                    // if (widget.flag == "sync") {
                                    //   GlobalVar.flag = "";
                                    //   inVM.tolistPO.removeWhere(
                                    //       (element) => element.ebeln == ebeln);
                                    // } else {
                                    for (int i = 0;
                                        i < forclose.T_DATA.length;
                                        i++) {
                                      inVM.tolistPO.value[widget.index].T_DATA
                                          .add(forclose.T_DATA[i]);
                                    }
                                    // }

                                    // }
                                  }
                                  Get.back();
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

  Future<void> _showMyDialogApprove(InModel indetail) async {
    double baseWidth = 312;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        content: Container(
          height: MediaQuery.of(context).size.height / 2.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 0 * fem, 1 * fem, 15.5 * fem),
                width: 35 * fem,
                height: 35 * fem,
                child: Image.asset(
                  'data/images/mdi-warning-circle-vJo.png',
                  width: 35 * fem,
                  height: 35 * fem,
                ),
              ),
              Container(
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 48 * fem),
                constraints: BoxConstraints(
                  maxWidth: 256 * fem,
                ),
                child: Text(
                  'Are you sure to save all changes made in this purchase order? ',
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
                        // height: double infinity,
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
                      onTap: () async {
                        // Your asynchronous code here
                        if (GlobalVar.choicecategory != "ALL") {
                          DateTime now = DateTime.now();
                          String formattedDate =
                              DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

                          indetail.approvedate = formattedDate;

                          indetail.truck = containerinput.text;
                          for (int i = 0; i < indetail.T_DATA.length; i++) {
                            indetail.T_DATA[i].app_user =
                                globalVM.username.value;
                            indetail.T_DATA[i].app_version =
                                globalVM.version.value;
                          }

                          List<Map<String, dynamic>> maptdata = indetail.T_DATA
                              .map((person) => person.toMap())
                              .toList();
                          print(maptdata);
                          Get.back();
                          Get.back();
                          indetail.dlv_comp = "I";
                          var sukses = inVM.approveIn(indetail, maptdata);

                          inVM.isapprove.value = true;
                          if (sukses == false) {
                            Get.dialog(MyDialogAnimation("reject"));
                            //      Get.back();
                            // Get.back();
                            // _showMyDialogAnimation("reject");
                            // Fluttertoast.showToast(
                            //     fontSize: 22,
                            //     gravity: ToastGravity.TOP,
                            //     msg:
                            //         "Failed Approved This Document",
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.red);
                          } else {
                            // indetail.dlv_comp = "I";
                            Get.dialog(MyDialogAnimation("approve"));
                            // _showMyDialogAnimation("approve");
                            await inVM.sendHistory(indetail, maptdata);
                            var check =
                                await inVM.savenodocument(indetail, "ALL");

                            // Fluttertoast.showToast(
                            //     fontSize: 22,
                            //     gravity: ToastGravity.TOP,
                            //     msg:
                            //         "Success Approved This Document",
                            //     backgroundColor: Colors.green,
                            //     textColor: Colors.green);
                          }
                        } else {
                          DateTime now = DateTime.now();
                          String formattedDate =
                              DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

                          indetail.approvedate = formattedDate;

                          indetail.truck = containerinput.text;
                          for (int i = 0; i < indetail.T_DATA.length; i++) {
                            indetail.T_DATA[i].app_user =
                                indetail.T_DATA[i].updatedbyusername;
                            indetail.T_DATA[i].app_version =
                                globalVM.version.value;
                          }
                          List<Map<String, dynamic>> maptdata = indetail.T_DATA
                              .map((person) => person.toMap())
                              .toList();
                          print(maptdata);
                          Get.back();
                          Get.back();

                          inVM.approveIn(indetail, maptdata);

                          var check = await inVM.approveWF(indetail, "ALL");
                          if (check == "true") {
                            // indetail.dlv_comp = "X";
                            // await inVM.sendHistory(
                            //     indetail, maptdata);
                            // _showMyDialogAnimation("approve");
                            Get.dialog(MyDialogAnimation("approve"));
                            // inVM.onReady();
                            if (widget.from != "sync") {
                              // if (inVM.tolistPO.value.length == 1) {
                              // } else {
                              inVM.tolistPO.removeWhere(
                                  (element) => element.ebeln == ebeln);
                              // }
                            }
                            inVM.isapprove.value = true;
                            // Fluttertoast.showToast(
                            //     fontSize: 22,
                            //     gravity: ToastGravity.TOP,
                            //     msg:
                            //         "Success Approved This Document",
                            //     backgroundColor: Colors.green,
                            //     textColor: Colors.green);
                            // inVM.isapprove.value = true;
                            //      Get.back();
                            // Get.back();
                            // _showMyDialogAnimation("reject");

                            // Fluttertoast.showToast(
                            //     fontSize: 22,
                            //     gravity: ToastGravity.TOP,
                            //     msg:
                            //         "Failed Approved This Document",
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.red);
                          } else {
                            Get.dialog(MyDialogAnimation("reject"));
                          }

                          // _isSearching = false;
                          // if (_isSearching) {
                          // _stopSearching();
                          // }

                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialogAnimation(String type) async {
    AnimationController _controller = AnimationController(
      vsync: this, // You should use the appropriate TickerProvider
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: AlertDialog(
            content: Lottie.asset(
              type == "reject"
                  ? 'data/images/success_animation.json'
                  : 'data/images/success_animation.json',
              controller: _controller,
              onLoaded: (composition) {
                // Configure the AnimationController with the duration of the
                // Lottie file and start the animation.
                _controller.duration = composition.duration;
                _controller.forward();

                _controller.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    // Animation has completed, close the dialog after a delay
                    Future.delayed(Duration(seconds: 2), () {
                      // if (!_controller.isDisposed) {
                      _controller.dispose(); // Dispose the controller
                      // }
                      Navigator.of(context).pop(); // Close the dialog
                    });
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future _showMyDialog(InDetail indetail, String type) async {
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Text(
                            '${indetail.maktx}',
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
                                  if (type == "kg") {
                                  } else {
                                    tabs = i;

                                    tabs == 0
                                        ? type = "ctn"
                                        : tabs == 1
                                            ? type = "pcs"
                                            : type = "kg";

                                    type == "ctn"
                                        ? _controllerctn =
                                            TextEditingController(
                                                text: typeIndexctn.toString())
                                        : type == "kg"
                                            ? _controllerkg =
                                                TextEditingController(
                                                    text:
                                                        typeIndexkg.toString())
                                            : _controllerpcs =
                                                TextEditingController(
                                                    text: typeIndexpcs
                                                        .toString());
                                    // GlobalVar.segmentedControlGroupValue = i;
                                    // if (i == 0) {
                                    //   GlobalVar.typePrcSelected = 'PRC1';
                                    //   typeIndex = 0;
                                    //   _controller.text =
                                    //       GlobalVar.cartQtyPRC1.toString() == "0"
                                    //           ? ""
                                    //           : GlobalVar.cartQtyPRC1.toString();
                                    // } else if (i == 1) {
                                    //   GlobalVar.typePrcSelected = 'FOC';
                                    //   typeIndex = 1;
                                    //   _controller.text =
                                    //       GlobalVar.cartQtyFOC.toString() == "0"
                                    //           ? ""
                                    //           : GlobalVar.cartQtyFOC.toString();
                                    // } else {
                                    //   GlobalVar.typePrcSelected = 'XCHG';
                                    //   typeIndex = 2;
                                    //   _controller.text =
                                    //       GlobalVar.cartQtyXCHG.toString() == "0"
                                    //           ? ""
                                    //           : GlobalVar.cartQtyXCHG.toString();
                                    // }
                                  }
                                });
                              }),
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
                                    if (type == "ctn") {
                                      if (typeIndexctn == 0) {
                                        _controllerctn = TextEditingController(
                                            text: typeIndexctn.toString());
                                      } else {
                                        // int hasil = indetail.menge.toInt() -
                                        //     ((typeIndexctn * indetail.umrez) +
                                        //         typeIndexpcs);
                                        // if (hasil > indetail.umrez) {
                                        typeIndexctn--;
                                        _controllerctn = TextEditingController(
                                            text: typeIndexctn.toString());
                                        // } else {}
                                      }
                                    } else if (type == "pcs") {
                                      if (typeIndexpcs == 0) {
                                        _controllerpcs = TextEditingController(
                                            text: typeIndexpcs.toString());
                                      } else {
                                        // int hasil = indetail.menge.toInt() -
                                        //     ((typeIndexctn * indetail.umrez));
                                        // if (typeIndexpcs < hasil) {
                                        typeIndexpcs--;
                                        _controllerpcs = TextEditingController(
                                            text: typeIndexpcs.toString());
                                        // } else {}
                                      }
                                    } else {
                                      // if (typeIndexkg <
                                      //     inVM.tolistPO.value[widget.index]
                                      //         .T_DATA
                                      //         .where((element) =>
                                      //             element.group == "UM")
                                      //         .toList()[0]
                                      //         .menge) {
                                      if (typeIndexkg == 0) {
                                        _controllerkg = TextEditingController(
                                            text: typeIndexkg.toString());
                                      } else {
                                        typeIndexkg--;

                                        _controllerkg = TextEditingController(
                                            text: typeIndexkg.toString());
                                      }

                                      // } else {
                                      //   _controllerkg.text =
                                      //       typeIndexkg.toString();
                                      // }
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 50,
                              child: TextField(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                keyboardType: type == "kg"
                                    ? TextInputType.numberWithOptions(
                                        decimal: true)
                                    : TextInputType.number,
                                inputFormatters: [
                                  type == "kg"
                                      ? FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'))
                                      : FilteringTextInputFormatter.digitsOnly
                                ],
                                focusNode: _focusNode,
                                controller: type == "ctn"
                                    ? _controllerctn
                                    : type == "kg"
                                        ? _controllerkg
                                        : _controllerpcs,
                                onChanged: (i) {
                                  try {
                                    setState(() {
                                      if (type == "ctn" && tabs == 0) {
                                        int check = inVM
                                            .tolistPO.value[widget.index].T_DATA
                                            .where((element) =>
                                                element.matnr == indetail.matnr)
                                            .toList()
                                            .length;
                                        if (check > 1) {
                                          var listpo = inVM.tolistPO
                                              .value[widget.index].T_DATA
                                              .where((element) => element.matnr
                                                  .contains(indetail.matnr))
                                              .where((element) => !element
                                                  .cloned
                                                  .contains(indetail.cloned))
                                              .toList();
                                          int hasilctn = listpo.fold(0,
                                              (int previousValue,
                                                  InDetail element) {
                                            return previousValue +
                                                element.qtctn;
                                          });
                                          double hasilpcs = listpo.fold(0,
                                              (double previousValue,
                                                  InDetail element) {
                                            return previousValue +
                                                element.qtuom;
                                          });
                                          double hasil = indetail.menge
                                                  .toInt() -
                                              ((hasilctn * indetail.umrez) +
                                                  (int.parse(
                                                          _controllerctn.text) *
                                                      indetail.umrez) +
                                                  int.parse(_controllerpcs ==
                                                          null
                                                      ? _controllerpcs =
                                                          TextEditingController(
                                                              text: "0")
                                                      : _controllerpcs.text)) +
                                              hasilpcs;

                                          if (!hasil.toString().contains("-") &&
                                              hasil <= indetail.menge.toInt()) {
                                            typeIndexctn =
                                                int.parse(_controllerctn.text);
                                          } else {
                                            int hasil2 = ((indetail.menge
                                                            .toInt() -
                                                        ((hasilctn *
                                                                indetail
                                                                    .umrez) +
                                                            int.parse(
                                                                _controllerpcs
                                                                    .text) +
                                                            hasilpcs)) /
                                                    indetail.umrez)
                                                .toInt();

                                            typeIndexctn = hasil2;

                                            _controllerctn.text =
                                                hasil2.toString();
                                            _focusNode.unfocus();
                                          }
                                        } else {
                                          int hasil =
                                              int.parse(_controllerctn.text) *
                                                      indetail.umrez +
                                                  int.parse(_controllerpcs ==
                                                          null
                                                      ? _controllerpcs =
                                                          TextEditingController(
                                                              text: "0")
                                                      : _controllerpcs.text);

                                          if (hasil <= indetail.menge.toInt() &&
                                              indetail.menge.toInt() >
                                                  indetail.umrez) {
                                            typeIndexctn =
                                                int.parse(_controllerctn.text);
                                          } else {
                                            int hasil2 =
                                                ((indetail.menge.toInt() -
                                                            (int.parse(
                                                                _controllerpcs
                                                                    .text))) /
                                                        indetail.umrez)
                                                    .toInt();
                                            typeIndexctn = hasil2;

                                            _controllerctn.text =
                                                hasil2.toString();
                                            _focusNode.unfocus();
                                          }
                                        }
                                      } else if (type == "pcs" && tabs == 1) {
                                        int check = inVM
                                            .tolistPO.value[widget.index].T_DATA
                                            .where((element) =>
                                                element.matnr == indetail.matnr)
                                            .toList()
                                            .length;
                                        if (check > 1) {
                                          var listpo = inVM.tolistPO
                                              .value[widget.index].T_DATA
                                              .where((element) =>
                                                  element.matnr ==
                                                  indetail.matnr)
                                              .where((element) =>
                                                  element.cloned !=
                                                  indetail.cloned)
                                              .toList();
                                          int hasilctn = listpo.fold(0,
                                              (int previousValue,
                                                  InDetail element) {
                                            return previousValue +
                                                element.qtctn;
                                          });
                                          int hasilpcs = listpo.fold(0,
                                              (int previousValue,
                                                  InDetail element) {
                                            return previousValue +
                                                element.qtuom.toInt();
                                          });
                                          int hasil = indetail.menge.toInt() -
                                              ((hasilctn * indetail.umrez) +
                                                  int.parse(
                                                          _controllerctn.text) *
                                                      indetail.umrez +
                                                  int.parse(
                                                      _controllerpcs.text) +
                                                  hasilpcs);
                                          if (!hasil.toString().contains("-") &&
                                              hasil <= indetail.menge.toInt()) {
                                            typeIndexpcs =
                                                int.parse(_controllerpcs.text);
                                          } else {
                                            int hasil2 = indetail.menge
                                                    .toInt() -
                                                ((hasilctn * indetail.umrez) +
                                                    (int.parse(_controllerctn
                                                            .text) *
                                                        indetail.umrez) +
                                                    hasilpcs);
                                            typeIndexpcs = hasil2;
                                            _controllerpcs.text =
                                                hasil2.toString();
                                            // if (!hasil
                                            //     .toString()
                                            //     .contains("-")) {
                                            //   _controllerpcs.text =
                                            //       hasil.toString();
                                            // } else {
                                            //   _controllerpcs.text =
                                            //       0.toString();
                                            // }

                                            _focusNode.unfocus();
                                          }
                                        } else {
                                          int hasil = int.parse(
                                                      _controllerctn.text) *
                                                  indetail.umrez +
                                              int.parse(_controllerpcs.text);
                                          if (hasil <= indetail.menge.toInt()) {
                                            typeIndexpcs =
                                                int.parse(_controllerpcs.text);
                                          } else {
                                            int hasil2 = indetail.menge
                                                    .toInt() -
                                                ((int.parse(
                                                        _controllerctn.text) *
                                                    indetail.umrez));
                                            typeIndexpcs = hasil2;
                                            _controllerpcs.text =
                                                hasil2.toString();
                                            _focusNode.unfocus();
                                          }
                                        }
                                      } else {
                                        // if (indetail.group != "UM") {
                                        //   typeIndexkg =
                                        //       double.parse(_controllerkg.text);
                                        // } else {
                                        // if (double.parse(_controllerkg.text) <
                                        //     inVM.tolistPO.value[widget.index]
                                        //         .T_DATA
                                        //         .where((element) =>
                                        //             element.group == "UM")
                                        //         .toList()[0]
                                        //         .menge) {
                                        //   typeIndexkg =
                                        //       double.parse(_controllerkg.text);
                                        // } else {
                                        // if (type == "kg") {
                                        // var testing = double.parse();
                                        typeIndexkg =
                                            double.parse(_controllerkg.text);
                                        if (indetail.menge <= typeIndexkg) {
                                          _controllerkg.text =
                                              indetail.menge.toString();
                                          typeIndexkg =
                                              double.parse(_controllerkg.text);
                                          _focusNode.unfocus();
                                        }
                                        // Adjust to display up to 2 decimal places
                                        //   print(_controllerkg.text);
                                        //   // _focusNode.unfocus(); // You may decide whether to unfocus or not
                                        // }
                                        // _focusNode.unfocus();
                                        // }
                                        // }
                                      }
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
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
                                    // typeIndex++;
                                    int check = inVM
                                        .tolistPO.value[widget.index].T_DATA
                                        .where((element) =>
                                            element.matnr == indetail.matnr)
                                        // .where((element) => element.cloned != indetail.cloned)
                                        .toList()
                                        .length;
                                    if (check > 1) {
                                      if (type == "ctn") {
                                        var listpo = inVM
                                            .tolistPO.value[widget.index].T_DATA
                                            .where((element) =>
                                                element.matnr == indetail.matnr)
                                            .where((element) =>
                                                element.cloned !=
                                                indetail.cloned)
                                            .toList();
                                        int hasilctn = listpo.fold(0,
                                            (int previousValue,
                                                InDetail element) {
                                          return previousValue + element.qtctn;
                                        });
                                        double hasilpcs = listpo.fold(0,
                                            (double previousValue,
                                                InDetail element) {
                                          return previousValue + element.qtuom;
                                        });
                                        double hasil = indetail.menge.toInt() -
                                            ((hasilctn * indetail.umrez) +
                                                (typeIndexctn *
                                                    indetail.umrez) +
                                                typeIndexpcs +
                                                hasilpcs);
                                        if (hasil >= indetail.umrez) {
                                          typeIndexctn++;
                                          _controllerctn =
                                              TextEditingController(
                                                  text:
                                                      typeIndexctn.toString());
                                        } else {}
                                      } else if (type == "pcs") {
                                        var listpo = inVM
                                            .tolistPO.value[widget.index].T_DATA
                                            .where((element) =>
                                                element.matnr == indetail.matnr)
                                            .where((element) =>
                                                element.cloned !=
                                                indetail.cloned)
                                            .toList();
                                        int hasilctn = listpo.fold(0,
                                            (int previousValue,
                                                InDetail element) {
                                          return previousValue + element.qtctn;
                                        });
                                        double hasilpcs = listpo.fold(0,
                                            (double previousValue,
                                                InDetail element) {
                                          return previousValue + element.qtuom;
                                        });
                                        double hasil = indetail.menge.toInt() -
                                            ((hasilctn * indetail.umrez) +
                                                (typeIndexctn *
                                                    indetail.umrez) +
                                                hasilpcs);
                                        if (typeIndexpcs < hasil) {
                                          typeIndexpcs++;
                                          _controllerpcs =
                                              TextEditingController(
                                                  text:
                                                      typeIndexpcs.toString());
                                        } else {}
                                      } else {
                                        // if (typeIndexkg <
                                        //     inVM.tolistPO.value[widget.index]
                                        //         .T_DATA
                                        //         .where((element) =>
                                        //             element.group == "UM")
                                        //         .toList()[0]
                                        //         .menge) {

                                        typeIndexkg =
                                            double.parse(_controllerkg.text);
                                        if (indetail.menge <= typeIndexkg) {
                                          _controllerkg.text =
                                              indetail.menge.toString();
                                          typeIndexkg =
                                              double.parse(_controllerkg.text);
                                          _focusNode.unfocus();
                                        } else {
                                          typeIndexkg++;
                                        }
                                        // } else {
                                        //   _controllerkg.text =
                                        //       typeIndexkg.toString();
                                        // }
                                      }
                                    } else {
                                      if (type == "ctn") {
                                        int hasil = indetail.menge.toInt() -
                                            ((typeIndexctn * indetail.umrez) +
                                                typeIndexpcs);
                                        if (hasil >= indetail.umrez) {
                                          typeIndexctn++;
                                          _controllerctn =
                                              TextEditingController(
                                                  text:
                                                      typeIndexctn.toString());
                                        } else {}
                                      } else if (type == "pcs") {
                                        int hasil = indetail.menge.toInt() -
                                            ((typeIndexctn * indetail.umrez));
                                        if (typeIndexpcs < hasil) {
                                          typeIndexpcs++;
                                          _controllerpcs =
                                              TextEditingController(
                                                  text:
                                                      typeIndexpcs.toString());
                                        } else {}
                                      } else {
                                        // if (typeIndexkg <
                                        //     inVM.tolistPO.value[widget.index]
                                        //         .T_DATA
                                        //         .where((element) =>
                                        //             element.group == "UM")
                                        //         .toList()[0]
                                        //         .menge) {
                                        typeIndexkg =
                                            double.parse(_controllerkg.text);
                                        if (indetail.menge <= typeIndexkg) {
                                          _controllerkg.text =
                                              indetail.menge.toString();
                                          typeIndexkg =
                                              double.parse(_controllerkg.text);
                                          _focusNode.unfocus();
                                        } else {
                                          typeIndexkg++;
                                        }

                                        // } else {
                                        //   _controllerkg.text =
                                        //       typeIndexkg.toString();
                                        // }
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
                                  // var listpo = inVM
                                  //     .tolistPObackup.value[widget.index].T_DATA
                                  //     .where((element) =>
                                  //         element.ebelp == indetail.ebelp)
                                  //     .toList();
                                  // for (int i = 0; i < listpo.length; i++) {
                                  //   inVM.tolistPO.value[widget.index].T_DATA[i]
                                  //       .qtctn = listpo[i].qtctn;
                                  //   inVM.tolistPO.value[widget.index].T_DATA[i]
                                  //       .qtuom = listpo[i].qtuom;
                                  //   inVM.tolistPO.value[widget.index].T_DATA[i]
                                  //       .qtuom = listpo[i].qtuom;
                                  // }
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
                                  ctn.value = typeIndexctn;
                                  pcs.value = typeIndexpcs;
                                  kg.value = typeIndexkg;
                                  // indetail.qtuom = kg.value;
                                  // indetail.qtctn = ctn.value;
                                  // indetail.qtuom = pcs.value;

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

  Widget modalBottomSheet(InDetail indetail) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SingleChildScrollView(
      child: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        height: GlobalVar.height * 0.95,
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
                  ' Edit - ${indetail.maktx}',
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
                    var listpo = inVM.tolistPO.value[widget.index].T_DATA
                        .where((element) => element.ebelp == indetail.ebelp)
                        .toList();
                    for (int i = 0; i < listpo.length; i++) {
                      typeIndexkg = listpo[i].qtuom;
                      typeIndexctn = listpo[i].qtctn;
                      typeIndexpcs = listpo[i].qtuom.toInt();
                      ctn.value = typeIndexctn;
                      pcs.value = typeIndexpcs;
                      kg.value = typeIndexkg;
                    }

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
                  child: indetail.image == "kosong"
                      ? Image.asset(
                          'data/images/no_image.png',
                          width: 80 * fem,
                          height: 80 * fem,
                        )
                      : Image.network('${indetail.image}',
                          width: 30 * fem, height: 30 * fem,
                          errorBuilder: (context, error, stackTrace) {
                          return Container(
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: Image.asset(
                                'data/images/no_image.png',
                                width: 80 * fem,
                                height: 80 * fem,
                              ));
                        }),
                ),
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
                    // materialinputy9m (11:1251)
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 7 * fem),
                    width: double.infinity,
                    height: 45 * fem,
                    child: Stack(
                      children: [
                        Positioned(
                          // rectangle17GPm (11:1252)
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
                          // rectangle187fH (11:1253)
                          left: 11 * fem,
                          top: 0 * fem,
                          child: Align(
                            child: SizedBox(
                              width: 46 * fem,
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
                          // materialDCX (11:1254)
                          left: 11.7142333984 * fem,
                          top: 0 * fem,
                          child: Align(
                            child: SizedBox(
                              width: 41 * fem,
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
                          // 4iw (11:1255)
                          left: 10 * fem,
                          top: 15 * fem,
                          child: Align(
                            child: SizedBox(
                              width: GlobalVar.width,
                              height: 19 * fem,
                              child: Text(
                                '${indetail.matnr}',
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
                                '${indetail.maktx}',
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
                    // group2QGB (13:2218)
                    // margin:
                    //     EdgeInsets.fromLTRB(12 * fem, 0 * fem, 12 * fem, 8 * fem),
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
                                // requestdatemAb (13:2227)
                                left: 15.5844726562 * fem,
                                top: 0 * fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 66 * fem,
                                    height: 13 * fem,
                                    child: Text(
                                      'PO QTY',
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
                                      indetail.pounitori == "KG"
                                          ? "${currencydecimal.format(indetail.menge)}" +
                                              " " +
                                              "${indetail.pounitori}"
                                          : "${currency.format(indetail.menge.toInt())}" +
                                              " " +
                                              "${indetail.pounitori}",
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
                                // rectangle18QoD (13:2221)
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
                                      "1 X ${indetail.umrez}",
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
                  SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        child: Container(
                          // stockrequestQWP (13:2219)
                          width: 100 * fem,
                          height: 45 * fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle17EEX (13:2220)
                                left: 0 * fem,
                                top: 5 * fem,
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
                                        color:
                                            indetail.maktx.contains("Pallet") ||
                                                    indetail.pounitori == "KG"
                                                ? Color(0xffe0e0e0)
                                                : Colors.white,
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
                                    width: 23 * fem,
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
                                      'CTN',
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
                              ValueListenableBuilder(
                                  valueListenable: ctn,
                                  builder: (BuildContext context, int value,
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
                                            "${ctn.value}",
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
                        onTap: () {
                          if (indetail.maktx.contains("Pallet") ||
                              indetail.pounitori == "KG") {
                          } else {
                            _controllerctn = TextEditingController(
                                text: ctn.value.toString());
                            typeIndexctn = ctn.value;

                            _controllerpcs = TextEditingController(
                                text: pcs.value.toString());
                            typeIndexpcs = pcs.value;
                            // ctn.value = indetail.qtctn;
                            // ctn.value = _controllerctn.text;
                            setState(() {
                              tabs = 0;

                              _showMyDialog(indetail, "ctn");
                            });
                          }
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          // stockrequestQWP (13:2219)
                          width: 100 * fem,
                          height: 45 * fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle17EEX (13:2220)
                                left: 0 * fem,
                                top: 5 * fem,
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
                                        color: indetail.pounitori == "KG"
                                            ? Color(0xffe0e0e0)
                                            : Colors.white,
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
                                    width: 23 * fem,
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
                                      'PCS',
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
                              ValueListenableBuilder(
                                valueListenable: pcs,
                                builder: (BuildContext context, int value,
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
                                          "${pcs.value.toInt()}",
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
                                },
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (indetail.pounitori == "KG") {
                            } else {
                              tabs = 1;
                              _controllerctn = TextEditingController(
                                  text: ctn.value.toString());
                              typeIndexctn = ctn.value;
                              _controllerpcs = TextEditingController(
                                  text: pcs.value.toString());
                              typeIndexpcs = pcs.value;
                              _showMyDialog(indetail, "pcs");
                            }
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          // stockrequestQWP (13:2219)
                          width: 100 * fem,
                          height: 45 * fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle17EEX (13:2220)
                                left: 0 * fem,
                                top: 5 * fem,
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
                                        color: indetail.maktx.contains("Pallet")
                                            ? Color(0xffe0e0e0)
                                            : Colors.white,
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
                                    width: 40 * fem,
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
                                      'KG',
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
                              ValueListenableBuilder(
                                  valueListenable: kg,
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
                                            "${kg.value}",
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
                        onTap: () {
                          if (indetail.maktx.contains("Pallet")) {
                          } else {
                            // tabs = 2;
                            // _controllerkg = TextEditingController(
                            //     text: kg.value.toString());
                            // typeIndexkg = kg.value;

                            // _showMyDialog(indetail, "kg");
                            setState(() {
                              // if (anyum == true) {
                              tabs = 2;
                              // _controllerctn = TextEditingController(
                              //     text: ctn.value.toString());
                              // typeIndexctn = ctn.value;
                              // _controllerpcs = TextEditingController(
                              //     text: pcs.value.toString());
                              // typeIndexpcs = pcs.value;
                              _controllerkg = TextEditingController(
                                  text: kg.value.toString());
                              typeIndexkg = kg.value;
                              _showMyDialog(indetail, "kg");
                              // } else {}
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // GestureDetector(
                  //   child: Container(
                  //     // expireddateYE7 (11:1267)
                  //     margin: EdgeInsets.fromLTRB(
                  //         0 * fem, 0 * fem, 0 * fem, 10 * fem),
                  //     padding: EdgeInsets.fromLTRB(
                  //         10 * fem, 5 * fem, 5 * fem, 5 * fem),
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Color(0xff9c9c9c)),
                  //       color: Color(0xffffffff),
                  //       borderRadius: BorderRadius.circular(4 * fem),
                  //     ),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: [
                  //         Container(
                  //           // expireddateYdR (11:1269)
                  //           margin: EdgeInsets.fromLTRB(
                  //               0 * fem, 0 * fem, 193 * fem, 1 * fem),
                  //           child: ValueListenableBuilder(
                  //             valueListenable: expireddate,
                  //             builder: (BuildContext context, String value,
                  //                 Widget child) {
                  //               return Text(
                  //                 expireddate.value == "0000-00-00"
                  //                     ? 'Expired Date'
                  //                     : inVM.dateToString(
                  //                         expireddate.value, "tes"),
                  //                 style: SafeGoogleFont(
                  //                   'Roboto',
                  //                   fontSize: 16 * ffem,
                  //                   fontWeight: FontWeight.w400,
                  //                   height: 1.1725 * ffem / fem,
                  //                   color: expireddate.value == "0000-00-00"
                  //                       ? Color(0xff9c9c9c)
                  //                       : Colors.black,
                  //                 ),
                  //               );
                  //             },
                  //           ),
                  //         ),
                  //         Container(
                  //             // tearoffcalendarqsR (39:952)
                  //             width: 30 * fem,
                  //             height: 30 * fem,
                  //             child: Icon(Icons.calendar_today)),
                  //       ],
                  //     ),
                  //   ),
                  //   onTap: () async {
                  //     DateTime newDate = await showDatePicker(
                  //         context: context,
                  //         initialDate: DateTime.now(),
                  //         firstDate: DateTime.now(),
                  //         lastDate: DateTime(2100));
                  //     if (newDate == null) return;

                  //     setState(() {
                  //       expireddate.value =
                  //           DateFormat('yyyyMMdd').format(newDate);
                  //     });
                  //   },
                  // ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 13 * fem),
                      width: double.infinity,
                      height: 45 * fem,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0 * fem,
                            top: 5 * fem,
                            child: SizedBox(
                              width: 327 * fem,
                              height: 40 * fem,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4 * fem),
                                  border: Border.all(color: Color(0xff9c9c9c)),
                                  color: indetail.maktx.contains("Pallet")
                                      ? Color(0xffe0e0e0)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14 * fem,
                            top: 0 * fem,
                            child: SizedBox(
                              width: 70 * fem,
                              height: 11 * fem,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 15 * fem,
                            top: 0 * fem,
                            child: SizedBox(
                              width: 100 * fem,
                              height: 13 * fem,
                              child: Text(
                                'Expired Date',
                                style: TextStyle(
                                  fontSize: 11 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1725 * ffem / fem,
                                  color: Color(0xff000000),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 11 * fem, // Position the icon to the right
                            top: 10 * fem,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Add this line
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  // expireddateYdR (11:1269)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 193 * fem, 1 * fem),
                                  child: ValueListenableBuilder(
                                    valueListenable: expireddate,
                                    builder: (BuildContext context,
                                        String value, Widget child) {
                                      return Text(
                                        expireddate.value == "0000-00-00"
                                            ? ''
                                            : inVM.dateToString(
                                                expireddate.value, "tes"),
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w400,
                                          height: 1.1725 * ffem / fem,
                                          color:
                                              expireddate.value == "0000-00-00"
                                                  ? Color(0xff9c9c9c)
                                                  : Colors.black,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  // tearoffcalendarqsR (39:952)
                                  width: 30 * fem,
                                  height: 30 * fem,
                                  child: Icon(Icons.calendar_today),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      if (indetail.maktx.contains("Pallet")) {
                      } else {
                        DateTime newDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100));
                        if (newDate == null) return;

                        setState(() {
                          expireddate.value =
                              DateFormat('yyyyMMdd').format(newDate);
                        });
                      }
                    },
                  ),
                  // TextFieldWidget(
                  //   keyboardType: TextInputType.text,
                  //   isPasswordField: false,
                  //   labelText: 'Description',
                  //   onSaved: (input) => descriptioninput.text = input,
                  //   fieldKey: _descriptioninputkey,
                  // ),

                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 0 * fem, 13 * fem),
                    width: double.infinity,
                    height: 45 * fem,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0 * fem,
                          top: 5 * fem,
                          child: SizedBox(
                            width: 327 * fem,
                            height: 40 * fem,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4 * fem),
                                border: Border.all(color: Color(0xff9c9c9c)),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14 * fem,
                          top: 0 * fem,
                          child: SizedBox(
                            width: 70 * fem,
                            height: 11 * fem,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 15 * fem,
                          top: 0 * fem,
                          child: SizedBox(
                            width: 100 * fem,
                            height: 13 * fem,
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 11 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xff000000),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 11 * fem,
                          // top: 15 * fem,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, bottom: 10),
                            child: SizedBox(
                              width: 300 *
                                  fem, // Adjust the width as per your requirement
                              height: 30 *
                                  fem, // Adjust the height as per your requirement
                              child: TextFormField(
                                key: Key('description'),
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 15, left: 8),
                                  isDense: true,
                                  labelText: "",
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                controller: descriptioninput,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Container(
                  //     // grinpcsGEf (11:1261)
                  //     margin: EdgeInsets.fromLTRB(
                  //         0 * fem, 0 * fem, 0 * fem, 11 * fem),
                  //     // padding:
                  //     //     EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
                  //     height: GlobalVar.height * 0.055,
                  //     width: double.infinity,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(color: Color(0xff9c9c9c)),
                  //       // color: Color(0xffffffff),
                  //       borderRadius: BorderRadius.circular(4 * fem),
                  //     ),
                  //     child: Padding(
                  //         padding: EdgeInsets.only(left: 5, bottom: 10),
                  //         child: TextFormField(
                  //           key: Key('description'),
                  //           decoration: InputDecoration(
                  //             contentPadding: EdgeInsets.only(top: 15, left: 8),
                  //             isDense: true,
                  //             labelText: descriptioninput.text == "" &&
                  //                     indetail.descr == ""
                  //                 ? "Description"
                  //                 : descriptioninput.text != "" &&
                  //                         indetail.descr != ""
                  //                     ? ""
                  //                     : indetail.descr,
                  //             fillColor: Colors.white,
                  //             enabledBorder: UnderlineInputBorder(
                  //               borderSide:
                  //                   BorderSide(color: Colors.white, width: 2.0),
                  //             ),
                  //             labelStyle: TextStyle(
                  //               color: descriptioninput.text == "" &&
                  //                       indetail.descr == ""
                  //                   ? Colors.grey
                  //                   : descriptioninput.text != "" &&
                  //                           indetail.descr != ""
                  //                       ? Colors.grey
                  //                       : Colors.black,
                  //             ),
                  //           ),
                  //           keyboardType: TextInputType.text,
                  //           controller: descriptioninput,
                  //         ))),

                  //bates
                  Container(
                    // autogroupf5ebdRu (UM6eDoseJp3PyzDupvF5EB)
                    margin: EdgeInsets.fromLTRB(
                        150 * fem, 0 * fem, 0 * fem, 0 * fem),
                    width: double.infinity,
                    height: 40 * fem,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Container(
                            // cancelbutton8Nf (11:1273)
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
                              if (widget.from == "sync") {
                                var listpo = widget.flag.T_DATA
                                    .where((element) =>
                                        element.ebelp == indetail.ebelp)
                                    .toList();
                                for (int i = 0; i < listpo.length; i++) {
                                  typeIndexkg = listpo[i].qtuom;
                                  typeIndexctn = listpo[i].qtctn;
                                  typeIndexpcs = listpo[i].qtuom.toInt();
                                  ctn.value = typeIndexctn;
                                  pcs.value = typeIndexpcs;
                                  kg.value = typeIndexkg;
                                }
                              } else {
                                var listpo = inVM
                                    .tolistPO.value[widget.index].T_DATA
                                    .where((element) =>
                                        element.ebelp == indetail.ebelp)
                                    .toList();
                                for (int i = 0; i < listpo.length; i++) {
                                  typeIndexkg = listpo[i].qtuom;
                                  typeIndexctn = listpo[i].qtctn;
                                  typeIndexpcs = listpo[i].qtuom.toInt();
                                  ctn.value = typeIndexctn;
                                  pcs.value = typeIndexpcs;
                                  kg.value = typeIndexkg;
                                }
                              }

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
                          onTap: () {
                            setState(() {
                              if (expireddate.value == "0000-00-00" ||
                                  expireddate.value == "" ||
                                  expireddate.value == null) {
                                Fluttertoast.showToast(
                                    fontSize: 22,
                                    gravity: ToastGravity.TOP,
                                    msg: "Please Input Expired Date",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white);
                              } else {
                                DateTime now = DateTime.now();
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd kk:mm:ss')
                                        .format(now);
                                indetail.updatedbyusername =
                                    globalVM.username.value;
                                indetail.updated = formattedDate;
                                ctn.value = typeIndexctn;
                                pcs.value = typeIndexpcs;
                                kg.value = typeIndexkg;
                                indetail.qtuom = kg.value;
                                indetail.qtctn = ctn.value;
                                if (indetail.pounitori == "KG") {
                                  indetail.qtuom = kg.value.toDouble();
                                } else {
                                  indetail.qtuom = pcs.value.toDouble();
                                }

                                indetail.vfdat = expireddate.value;
                                indetail.descr = descriptioninput.text;
                                Get.back();
                              }
                            });
                          },
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

  Widget headerCard2History(InDetail indetail) {
    double baseWidth = 360.0028076172;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      // itemlistex35WQ (11:701)
      padding: EdgeInsets.fromLTRB(8 * fem, 8 * fem, 17.88 * fem, 12 * fem),
      margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 10 * fem, 10 * fem),
      width: double.infinity,
      height: indetail.updated != "" ? 170 * fem : 100 * fem,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // autogroupwkaxGKz (Xy3MKcM3EUdCzQduMGwKAx)
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 17 * fem, 0 * fem),
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // vitasoypuresoyabeanextract1000 (11:703)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 4 * fem),
                  constraints: BoxConstraints(
                    maxWidth: 145 * fem,
                  ),
                  child: Text(
                    '${indetail.maktx}',
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 13 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff2d2d2d),
                    ),
                  ),
                ),
                Text(
                  // sku292214NGY (11:704)
                  'SKU: ${indetail.matnr}',
                  style: SafeGoogleFont(
                    'Roboto',
                    fontSize: 13 * ffem,
                    fontWeight: FontWeight.w600,
                    height: 1.1725 * ffem / fem,
                    color: Color(0xff9a9a9a),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  // sku292214NGY (11:704)
                  'PO QTY : ${currency.format(indetail.poqtyori)}' +
                      '${indetail.pounitori}',
                  style: SafeGoogleFont(
                    'Roboto',
                    fontSize: 13 * ffem,
                    fontWeight: FontWeight.w600,
                    height: 1.1725 * ffem / fem,
                    color: Color(0xff9a9a9a),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Visibility(
                  visible: indetail.descr != "",
                  child: Text(
                    // sku292214NGY (11:704)
                    'Description : ${indetail.descr}',
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 13 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff9a9a9a),
                    ),
                  ),
                ),

                SizedBox(
                  height: 5,
                ),
                Visibility(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 145 * fem,
                      ),
                      child: Text(
                        // sku292214NGY (11:704)
                        'Update By: ${indetail.updatedbyusername}',
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 13 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    visible: indetail.updatedbyusername != ""),
                SizedBox(
                  height: 5,
                ),
                Visibility(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 145 * fem,
                      ),
                      child: Text(
                        // sku292214NGY (11:704)
                        indetail.updated != ""
                            ? 'Updated: ${globalVM.stringToDateWithTime(indetail.updated)}'
                            : 'Updated: ${indetail.updated}',
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 13 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    visible: indetail.updated != ""),
                SizedBox(
                  height: 5,
                ),
                Visibility(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 145 * fem,
                      ),
                      child: Text(
                        // sku292214NGY (11:704)
                        indetail.vfdat != ""
                            ? 'Exp Date: ${globalVM.dateToString(indetail.vfdat)}'
                            : 'Exp Date: ${indetail.vfdat}',
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 13 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                    visible: indetail.vfdat != ""),
                SizedBox(
                  height: 5,
                ),
                // ExpansionTile(
                //   title: Text('ExpansionTile 1'),
                //   subtitle: Text('Trailing expansion arrow icon'),
                //   children: <Widget>[
                //     ListTile(title: Text('This is tile number 1')),
                //   ],
                // ),
                // GestureDetector(
                //   child: Container(
                //     // mdiwarningcircleut4 (11:1225)
                //     margin: EdgeInsets.fromLTRB(
                //         0 * fem, 0 * fem, 1 * fem, 15.5 * fem),
                //     width: 20 * fem,
                //     height: 20 * fem,
                //     child: Image.asset(
                //       'data/images/add.png',
                //       width: 20 * fem,
                //       height: 20 * fem,
                //     ),
                //   ),
                //   onTap: () {
                //     setState(() {
                //       indetail.qtctn = 0;
                //       indetail.qtuom = 0;
                //       indetail.qtuom = 0;
                //       inVM.tolistPO.value[widget.index].T_DATA.add(indetail);
                //     });
                //   },
                // ),
              ],
            ),
          ),
          Visibility(
            visible: !indetail.maktx.contains("Pallet"),
            child: Container(
              // autogrouppeu8H8c (Xy3MRwVpoMP65nUhWdPeU8)
              margin: EdgeInsets.fromLTRB(0 * fem, 20 * fem, 12 * fem, 0 * fem),
              width: 56 * fem,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // autogroupmcekWXA (Xy3MWrXJYRgN69FSyjMCEk)
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 4 * fem),
                    width: double.infinity,
                    height: 28 * fem,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffa8a8a8)),
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(8 * fem),
                    ),
                    child: Center(
                      child: Text(
                        '${indetail.qtctn}',
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff2d2d2d),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    // pcsgpx (11:705)
                    'CTN',
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 10 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff2d2d2d),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            // autogroupdy3iCYQ (Xy3McMN9GiHRFPdyueDY3i)
            margin: EdgeInsets.fromLTRB(0 * fem, 20 * fem, 16 * fem, 0 * fem),
            width: 56 * fem,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // autogroupqgqpTDS (Xy3MhbiQ9d3RdQC34vQgQp)
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 4 * fem),
                  width: double.infinity,
                  height: 28 * fem,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffa8a8a8)),
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(8 * fem),
                  ),
                  child: Center(
                    child: Text(
                      '${indetail.qtuom}',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Roboto',
                        fontSize: 14 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.1725 * ffem / fem,
                        color: Color(0xff2d2d2d),
                      ),
                    ),
                  ),
                ),
                Text(
                  // ctnpTJ (11:706)
                  'PCS',
                  textAlign: TextAlign.center,
                  style: SafeGoogleFont(
                    'Roboto',
                    fontSize: 10 * ffem,
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
              // vectorswN (11:707)
              // margin: EdgeInsets.fromLTRB(0 * fem, 3 * fem, 0 * fem, 0 * fem),
              width: 11.57 * fem,
              height: 17 * fem,
              child: Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'data/images/vector-1HV.png',
                  width: 11.57 * fem,
                  height: 17 * fem,
                ),
              ),
            ),
            visible: widget.from != "history",
          ),
        ],
      ),
    );
  }

  Widget headerCard2(InDetail indetail) {
    double baseWidth = 360.0028076172;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      // key: Key(orderedCart.orderId.toString()),
      controller: slidableController,
      actionExtentRatio: 0.20,
      child: Container(
        // itemlistex35WQ (11:701)
        padding: EdgeInsets.fromLTRB(8 * fem, 8 * fem, 17.88 * fem, 12 * fem),
        margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 10 * fem, 10 * fem),
        width: double.infinity,
        height: indetail.updated != "" ? 185 * fem : 100 * fem,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // autogroupwkaxGKz (Xy3MKcM3EUdCzQduMGwKAx)
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 17 * fem, 0 * fem),
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // vitasoypuresoyabeanextract1000 (11:703)
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 4 * fem),
                    constraints: BoxConstraints(
                      maxWidth: 145 * fem,
                    ),
                    child: Text(
                      '${indetail.maktx}',
                      style: SafeGoogleFont(
                        'Roboto',
                        fontSize: 13 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.1725 * ffem / fem,
                        color: Color(0xff2d2d2d),
                      ),
                    ),
                  ),
                  Text(
                    // sku292214NGY (11:704)
                    'SKU: ${indetail.matnr}',
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 13 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff9a9a9a),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    // sku292214NGY (11:704)
                    'PO QTY : ${currency.format(indetail.poqtyori)}' +
                        ' ${indetail.pounitori}',
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 13 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff9a9a9a),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                    visible: indetail.descr != "",
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 145 * fem,
                      ),
                      child: Text(
                        // sku292214NGY (11:704)
                        'Description : ${indetail.descr}',
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 13 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff9a9a9a),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: 145 * fem,
                        ),
                        child: Text(
                          // sku292214NGY (11:704)
                          'Update By: ${indetail.updatedbyusername}',
                          style: SafeGoogleFont(
                            'Roboto',
                            fontSize: 13 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.1725 * ffem / fem,
                            color: Color(0xff9a9a9a),
                          ),
                        ),
                      ),
                      visible: indetail.updatedbyusername != ""),
                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: 145 * fem,
                        ),
                        child: Text(
                          // sku292214NGY (11:704)
                          indetail.updated != ""
                              ? 'Updated: ${globalVM.stringToDateWithTime(indetail.updated)}'
                              : 'Updated: ${indetail.updated}',
                          style: SafeGoogleFont(
                            'Roboto',
                            fontSize: 13 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.1725 * ffem / fem,
                            color: Color(0xff9a9a9a),
                          ),
                        ),
                      ),
                      visible: indetail.updated != ""),
                  SizedBox(
                    height: 5,
                  ),
                  Visibility(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: 145 * fem,
                        ),
                        child: Text(
                          // sku292214NGY (11:704)
                          indetail.vfdat != ""
                              ? 'Exp Date: ${globalVM.dateToString(indetail.vfdat)}'
                              : 'Exp Date: ${indetail.vfdat}',
                          style: SafeGoogleFont(
                            'Roboto',
                            fontSize: 13 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.1725 * ffem / fem,
                            color: Color(0xff9a9a9a),
                          ),
                        ),
                      ),
                      visible: indetail.vfdat != ""),
                  SizedBox(
                    height: 5,
                  ),
                  // ExpansionTile(
                  //   title: Text('ExpansionTile 1'),
                  //   subtitle: Text('Trailing expansion arrow icon'),
                  //   children: <Widget>[
                  //     ListTile(title: Text('This is tile number 1')),
                  //   ],
                  // ),
                  // GestureDetector(
                  //   child: Container(
                  //     // mdiwarningcircleut4 (11:1225)
                  //     margin: EdgeInsets.fromLTRB(
                  //         0 * fem, 0 * fem, 1 * fem, 15.5 * fem),
                  //     width: 20 * fem,
                  //     height: 20 * fem,
                  //     child: Image.asset(
                  //       'data/images/add.png',
                  //       width: 20 * fem,
                  //       height: 20 * fem,
                  //     ),
                  //   ),
                  //   onTap: () {
                  //     setState(() {
                  //       indetail.qtctn = 0;
                  //       indetail.qtuom = 0;
                  //       indetail.qtuom = 0;
                  //       inVM.tolistPO.value[widget.index].T_DATA.add(indetail);
                  //     });
                  //   },
                  // ),
                ],
              ),
            ),
            Visibility(
              visible: indetail.pounitori != "KG" &&
                  !indetail.maktx.contains("Pallet"),
              child: Container(
                // autogrouppeu8H8c (Xy3MRwVpoMP65nUhWdPeU8)
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 20 * fem, 12 * fem, 0 * fem),
                width: 56 * fem,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // autogroupmcekWXA (Xy3MWrXJYRgN69FSyjMCEk)
                      margin: EdgeInsets.fromLTRB(
                          0 * fem, 0 * fem, 0 * fem, 4 * fem),
                      width: double.infinity,
                      height: 28 * fem,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffa8a8a8)),
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(8 * fem),
                      ),
                      child: Center(
                        child: Text(
                          '${indetail.qtctn}',
                          textAlign: TextAlign.center,
                          style: SafeGoogleFont(
                            'Roboto',
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w600,
                            height: 1.1725 * ffem / fem,
                            color: Color(0xff2d2d2d),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      // pcsgpx (11:705)
                      'CTN',
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'Roboto',
                        fontSize: 10 * ffem,
                        fontWeight: FontWeight.w600,
                        height: 1.1725 * ffem / fem,
                        color: Color(0xff2d2d2d),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              // autogroupdy3iCYQ (Xy3McMN9GiHRFPdyueDY3i)
              margin: EdgeInsets.fromLTRB(0 * fem, 20 * fem, 16 * fem, 0 * fem),
              width: 56 * fem,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // autogroupqgqpTDS (Xy3MhbiQ9d3RdQC34vQgQp)
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 4 * fem),
                    width: double.infinity,
                    height: 28 * fem,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffa8a8a8)),
                      color: Color(0xffffffff),
                      borderRadius: BorderRadius.circular(8 * fem),
                    ),
                    child: Center(
                      child: Text(
                        indetail.pounitori == "KG"
                            ? '${indetail.qtuom}'
                            : '${indetail.qtuom.toInt()}',
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'Roboto',
                          fontSize: 14 * ffem,
                          fontWeight: FontWeight.w600,
                          height: 1.1725 * ffem / fem,
                          color: Color(0xff2d2d2d),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    // ctnpTJ (11:706)
                    indetail.pounitori == "KG" ? 'KG' : 'PCS',
                    textAlign: TextAlign.center,
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 10 * ffem,
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
                // vectorswN (11:707)
                // margin: EdgeInsets.fromLTRB(0 * fem, 3 * fem, 0 * fem, 0 * fem),
                width: 11.57 * fem,
                height: 17 * fem,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'data/images/vector-1HV.png',
                    width: 11.57 * fem,
                    height: 17 * fem,
                  ),
                ),
              ),
              visible: widget.from != "history",
            ),
          ],
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Add',
          color: Colors.green,
          icon: Icons.add,
          onTap: () {
            setState(() {
              if (widget.from == "sync") {
                int check = widget.flag.T_DATA
                    .where((element) => element.matnr == indetail.matnr)
                    .toList()
                    .length;
                var clone2 = InModel.clone(cloned);
                var clone = clone2.T_DATA
                    .where((element) => element.matnr == indetail.matnr)
                    .toList();
                for (int i = 0; i < clone.length; i++) {
                  clone[i].qtctn = 0;
                  clone[i].qtuom = 0;
                  clone[i].qtuom = 0;
                  clone[i].cloned = "cloned ${i}";
                  widget.flag.T_DATA.add(clone[i]);
                }
              } else {
                int check = inVM.tolistPO.value[widget.index].T_DATA
                    .where((element) => element.matnr == indetail.matnr)
                    .toList()
                    .length;
                var clone2 = InModel.clone(cloned);
                var clone = clone2.T_DATA
                    .where((element) => element.matnr == indetail.matnr)
                    .toList();
                for (int i = 0; i < clone.length; i++) {
                  clone[i].qtctn = 0;
                  clone[i].qtuom = 0;
                  clone[i].qtuom = 0;
                  clone[i].cloned = "cloned ${i}";
                  inVM.tolistPO.value[widget.index].T_DATA.add(clone[i]);
                }
              }
            });
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            setState(() {
              if (widget.from == "sync") {
                widget.flag.T_DATA.remove(indetail);
              } else {
                inVM.tolistPO.value[widget.index].T_DATA.remove(indetail);
              }
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360.0028076172;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  actions: widget.from == "history" ? null : _buildActions(),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: 20.0,
                    onPressed: () {
                      if (widget.from == "history") {
                        Get.back();
                      } else if (widget.from == "sync") {
                        _showMyDialogReject(widget.flag);
                      } else {
                        _showMyDialogReject(inVM.tolistPO.value[widget.index]);
                      }
                    },
                  ),
                  backgroundColor: Colors.red,
                  title: _isSearching
                      ? _buildSearchField()
                      : Container(
                          child: TextWidget(
                              text: widget.from == "sync"
                                  ? "${widget.flag.ebeln}"
                                  : "${inVM.tolistPO.value[widget.index].ebeln}",
                              isBlueTxt: false,
                              maxLines: 2,
                              size: 20,
                              color: Colors.white)),
                  // actions: widget.listTrack != null ? null : _buildActions(),
                ),
                backgroundColor: kWhiteColor,
                body: Container(
                  height: GlobalVar.height,
                  // indetailpageambientVi3 (11:774)
                  padding: EdgeInsets.only(top: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                  ),
                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          Container(
                            // headerdatajJs (11:786)
                            margin: EdgeInsets.fromLTRB(
                                12 * fem, 0 * fem, 12 * fem, 8 * fem),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  // purchasingdate2om (I11:786;11:395)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 0 * fem, 8 * fem),
                                  width: double.infinity,
                                  height: 45 * fem,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned(
                                        // rectangle17jy5 (I11:786;11:396)
                                        left: 0 * fem,
                                        top: 5 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 336 * fem,
                                            height: 40 * fem,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4 * fem),
                                                border: Border.all(
                                                    color: Color(0xff9c9c9c)),
                                                color: Color(0xffe0e0e0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        // rectangle18Crf (I11:786;11:397)
                                        left: 11 * fem,
                                        top: 0 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 104 * fem,
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
                                        // purchaseorderdate3cP (I11:786;11:398)
                                        left: 11 * fem,
                                        top: 0 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 101 * fem,
                                            height: 13 * fem,
                                            child: Text(
                                              'Purchase Order Date',
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
                                        // iTd (I11:786;11:399)
                                        left: 12.4677734375 * fem,
                                        top: 15 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 81 * fem,
                                            height: 19 * fem,
                                            child: Text(
                                              widget.from == "sync"
                                                  ? '${inVM.dateToString(widget.flag.aedat, "tes")}'
                                                  : '${inVM.dateToString(inVM.tolistPO.value[widget.index].aedat, "tes")}',
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
                                  // vendorC7u (I11:786;11:390)
                                  margin: EdgeInsets.fromLTRB(
                                      0 * fem, 0 * fem, 0 * fem, 13 * fem),
                                  width: double.infinity,
                                  height: 45 * fem,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        // rectangle17uo1 (I11:786;11:391)
                                        left: 0 * fem,
                                        top: 5 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 336 * fem,
                                            height: 40 * fem,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4 * fem),
                                                border: Border.all(
                                                    color: Color(0xff9c9c9c)),
                                                color: Color(0xffe0e0e0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        // rectangle18Cn7 (I11:786;11:392)
                                        left: 14 * fem,
                                        top: 0 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 39 * fem,
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
                                        // vendor6Mh (I11:786;11:393)
                                        left: 15 * fem,
                                        top: 0 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 35 * fem,
                                            height: 13 * fem,
                                            child: Text(
                                              'Vendor',
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
                                        // crownpacificinvesmentXxo (I11:786;11:394)
                                        left: 11 * fem,
                                        top: 15 * fem,
                                        child: Align(
                                          child: SizedBox(
                                            width: 279 * fem,
                                            height: 19 * fem,
                                            child: Text(
                                              widget.from == "sync"
                                                  ? '${widget.flag.lifnr}'
                                                  : '${inVM.tolistPO.value[widget.index].lifnr}',
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
                                widget.from == "history"
                                    ? Container(
                                        // vendorC7u (I11:786;11:390)
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 13 * fem),
                                        width: double.infinity,
                                        height: 45 * fem,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              // rectangle17uo1 (I11:786;11:391)
                                              left: 0 * fem,
                                              top: 5 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 336 * fem,
                                                  height: 40 * fem,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4 * fem),
                                                      border: Border.all(
                                                          color: Color(
                                                              0xff9c9c9c)),
                                                      color: Color(0xffe0e0e0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              // rectangle18Cn7 (I11:786;11:392)
                                              left: 14 * fem,
                                              top: 0 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 70 * fem,
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
                                              // vendor6Mh (I11:786;11:393)
                                              left: 15 * fem,
                                              top: 0 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 100 * fem,
                                                  height: 13 * fem,
                                                  child: Text(
                                                    'Container No',
                                                    style: SafeGoogleFont(
                                                      'Roboto',
                                                      fontSize: 11 * ffem,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height:
                                                          1.1725 * ffem / fem,
                                                      color: Color(0xff000000),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              // crownpacificinvesmentXxo (I11:786;11:394)
                                              left: 11 * fem,
                                              top: 15 * fem,
                                              child: Align(
                                                child: SizedBox(
                                                  width: 279 * fem,
                                                  height: 19 * fem,
                                                  child: Text(
                                                    '${inVM.tolistPO.value[widget.index].truck}',
                                                    style: SafeGoogleFont(
                                                      'Roboto',
                                                      fontSize: 16 * ffem,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height:
                                                          1.1725 * ffem / fem,
                                                      color: Color(0xff000000),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.fromLTRB(0 * fem,
                                            0 * fem, 0 * fem, 13 * fem),
                                        width: double.infinity,
                                        height: 45 * fem,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              left: 0 * fem,
                                              top: 5 * fem,
                                              child: SizedBox(
                                                width: 336 * fem,
                                                height: 40 * fem,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .zero, // Set borderRadius to zero
                                                    border: Border.all(
                                                      color: Colors
                                                          .red, // Border color is red
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 14 * fem,
                                              top: 0 * fem,
                                              child: SizedBox(
                                                width: 70 * fem,
                                                height: 11 * fem,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffffffff),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 15 * fem,
                                              top: 0 * fem,
                                              child: SizedBox(
                                                width: 100 * fem,
                                                height: 13 * fem,
                                                child: Text(
                                                  'Container No',
                                                  style: TextStyle(
                                                    fontSize: 11 * ffem,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.1725 * ffem / fem,
                                                    color: Color(0xff000000),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 11 * fem,
                                              // top: 15 * fem,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 5, bottom: 10),
                                                child: SizedBox(
                                                  width: 300 *
                                                      fem, // Adjust the width as per your requirement
                                                  height: 30 *
                                                      fem, // Adjust the height as per your requirement
                                                  child: TextFormField(
                                                    key: Key('description'),
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              top: 15, left: 8),
                                                      isDense: true,
                                                      labelText: "",
                                                      fillColor: Colors.white,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                      ),
                                                      labelStyle: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    controller: containerinput,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                Visibility(
                                    child: Container(
                                      // vendorC7u (I11:786;11:390)
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 0 * fem, 13 * fem),
                                      width: double.infinity,
                                      height: 45 * fem,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            // rectangle17uo1 (I11:786;11:391)
                                            left: 0 * fem,
                                            top: 5 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 336 * fem,
                                                height: 40 * fem,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4 * fem),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xff9c9c9c)),
                                                    color: Color(0xffe0e0e0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            // rectangle18Cn7 (I11:786;11:392)
                                            left: 14 * fem,
                                            top: 0 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 50 * fem,
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
                                            // vendor6Mh (I11:786;11:393)
                                            left: 15 * fem,
                                            top: 0 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 50 * fem,
                                                height: 13 * fem,
                                                child: Text(
                                                  'Doc No SAP',
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
                                            // crownpacificinvesmentXxo (I11:786;11:394)
                                            left: 11 * fem,
                                            top: 15 * fem,
                                            child: Align(
                                              child: SizedBox(
                                                width: 279 * fem,
                                                height: 19 * fem,
                                                child: Text(
                                                  '${inVM.tolistPO.value[widget.index].mblnr}',
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
                                    visible: widget.from == "history" &&
                                        inVM.tolistPO.value[widget.index]
                                                .mblnr !=
                                            null)
                              ],
                            ),
                          ),
                          Container(
                            // line10TEB (11:819)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 7 * fem),
                            width: double.infinity,
                            height: 1 * fem,
                            decoration: BoxDecoration(
                              color: Color(0xff9c9c9c),
                            ),
                          ),
                          //listview
                          Container(
                            child: Obx(() {
                              if (inVM.tolistPO.value.length != 0) {
                                inVM.tolistPO.value[widget.index].T_DATA
                                    .sort((a, b) => b.matnr.compareTo(a.matnr));
                              }

                              return Expanded(
                                child: ListView.builder(
                                    controller: controller,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    // gridDelegate:
                                    //     SliverGridDelegateWithFixedCrossAxisCount(
                                    //         crossAxisCount: 1),
                                    itemCount: widget.from == "sync"
                                        ? widget.flag.T_DATA.length
                                        : inVM.tolistPO.value[widget.index]
                                            .T_DATA.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (widget.from == "history") {
                                        return GestureDetector(
                                            child: headerCard2History(inVM
                                                .tolistPO
                                                .value[widget.index]
                                                .T_DATA[index]),
                                            onTap: () async {
                                              if (widget.from == "history") {
                                              } else {
                                                pcsinput =
                                                    TextEditingController();
                                                ctninput =
                                                    TextEditingController();
                                                expiredinput =
                                                    TextEditingController();
                                                palletinput =
                                                    TextEditingController();

                                                descriptioninput =
                                                    TextEditingController();
                                                // if (inVM.tolistPO.value[widget.index]
                                                //     .T_DATA[index].group
                                                //     .contains("UM")) {
                                                // } else {
                                                // pcs.value =
                                                // var anyumlocal = inVM.tolistPO
                                                //     .value[widget.index].T_DATA
                                                //     .where((element) =>
                                                //         element.group == "UM")
                                                //     .toList()
                                                //     .length;
                                                // if (anyumlocal > 0) {
                                                //   anyum = true;
                                                // } else {
                                                //   anyum = false;
                                                // }
                                                pcs.value = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .qtuom
                                                    .toInt();
                                                ctn.value = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .qtctn;
                                                kg.value = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .qtuom;
                                                descriptioninput.text = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .descr;

                                                typeIndexctn = ctn.value;
                                                typeIndexpcs = pcs.value;
                                                typeIndexkg = kg.value;
                                                inVM
                                                        .tolistPO
                                                        .value[widget.index]
                                                        .T_DATA[index]
                                                        .maktx
                                                        .contains("Pallet")
                                                    ? expireddate.value =
                                                        "99991231"
                                                    : expireddate.value = inVM
                                                        .tolistPO
                                                        .value[widget.index]
                                                        .T_DATA[index]
                                                        .vfdat;

                                                return showMaterialModalBottomSheet(
                                                  context: context,
                                                  builder: (context) =>
                                                      modalBottomSheet(inVM
                                                          .tolistPO
                                                          .value[widget.index]
                                                          .T_DATA[index]),
                                                );
                                              }
                                            }

                                            // Get.to(InDetailPage(index));
                                            // },
                                            );
                                      } else if (widget.from == "sync") {
                                        return GestureDetector(
                                            child: headerCard2(
                                                widget.flag.T_DATA[index]),
                                            onTap: () async {
                                              pcsinput =
                                                  TextEditingController();
                                              ctninput =
                                                  TextEditingController();
                                              expiredinput =
                                                  TextEditingController();
                                              palletinput =
                                                  TextEditingController();

                                              descriptioninput =
                                                  TextEditingController();
                                              // if (inVM.tolistPO.value[widget.index]
                                              //     .T_DATA[index].group
                                              //     .contains("UM")) {
                                              // } else {
                                              // pcs.value =
                                              // var anyumlocal = inVM.tolistPO
                                              //     .value[widget.index].T_DATA
                                              //     .where((element) =>
                                              //         element.group == "UM")
                                              //     .toList()
                                              //     .length;
                                              // if (anyumlocal > 0) {
                                              //   anyum = true;
                                              // } else {
                                              //   anyum = false;
                                              // }
                                              pcs.value = widget
                                                  .flag.T_DATA[index].qtuom
                                                  .toInt();
                                              ctn.value = widget
                                                  .flag.T_DATA[index].qtctn;
                                              kg.value = widget
                                                  .flag.T_DATA[index].qtuom;
                                              descriptioninput.text = widget
                                                  .flag.T_DATA[index].descr;

                                              typeIndexctn = ctn.value;
                                              typeIndexpcs = pcs.value;
                                              typeIndexkg = kg.value;
                                              widget.flag.T_DATA[index].maktx
                                                      .contains("Pallet")
                                                  ? expireddate.value =
                                                      "99991231"
                                                  : expireddate.value = widget
                                                      .flag.T_DATA[index].vfdat;

                                              return showMaterialModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    modalBottomSheet(widget
                                                        .flag.T_DATA[index]),
                                              );
                                            }

                                            // Get.to(InDetailPage(index));
                                            // },
                                            );
                                      } else {
                                        return GestureDetector(
                                            child: headerCard2(inVM
                                                .tolistPO
                                                .value[widget.index]
                                                .T_DATA[index]),
                                            onTap: () async {
                                              if (widget.from == "history") {
                                              } else {
                                                pcsinput =
                                                    TextEditingController();
                                                ctninput =
                                                    TextEditingController();
                                                expiredinput =
                                                    TextEditingController();
                                                palletinput =
                                                    TextEditingController();

                                                descriptioninput =
                                                    TextEditingController();
                                                // if (inVM.tolistPO.value[widget.index]
                                                //     .T_DATA[index].group
                                                //     .contains("UM")) {
                                                // } else {
                                                // pcs.value =
                                                // var anyumlocal = inVM.tolistPO
                                                //     .value[widget.index].T_DATA
                                                //     .where((element) =>
                                                //         element.group == "UM")
                                                //     .toList()
                                                //     .length;
                                                // if (anyumlocal > 0) {
                                                //   anyum = true;
                                                // } else {
                                                //   anyum = false;
                                                // }
                                                pcs.value = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .qtuom
                                                    .toInt();
                                                ctn.value = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .qtctn;
                                                kg.value = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .qtuom;
                                                descriptioninput.text = inVM
                                                    .tolistPO
                                                    .value[widget.index]
                                                    .T_DATA[index]
                                                    .descr;

                                                typeIndexctn = ctn.value;
                                                typeIndexpcs = pcs.value;
                                                typeIndexkg = kg.value;
                                                inVM
                                                        .tolistPO
                                                        .value[widget.index]
                                                        .T_DATA[index]
                                                        .maktx
                                                        .contains("Pallet")
                                                    ? expireddate.value =
                                                        "99991231"
                                                    : expireddate.value = inVM
                                                        .tolistPO
                                                        .value[widget.index]
                                                        .T_DATA[index]
                                                        .vfdat;

                                                return showMaterialModalBottomSheet(
                                                  context: context,
                                                  builder: (context) =>
                                                      modalBottomSheet(inVM
                                                          .tolistPO
                                                          .value[widget.index]
                                                          .T_DATA[index]),
                                                );
                                              }
                                            }

                                            // Get.to(InDetailPage(index));
                                            // },
                                            );
                                      }
                                    }),
                              );
                            }),
                          ),
                        ],
                      )),
                      Container(
                        // buttonvalidationT3h (11:802)
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 0 * fem, 0 * fem),
                        padding: EdgeInsets.fromLTRB(
                            22.5 * fem, 6 * fem, 22.5 * fem, 6 * fem),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8 * fem),
                            topRight: Radius.circular(8 * fem),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3f000000),
                              offset: Offset(0 * fem, 4 * fem),
                              blurRadius: 2 * fem,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // frame10dsH (I11:802;11:382)
                              margin: EdgeInsets.fromLTRB(
                                  0 * fem, 0 * fem, 0 * fem, 5 * fem),
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    // numberofitems5YUT (I11:802;11:383)
                                    constraints: BoxConstraints(
                                      maxWidth: 94 * fem,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 12 * ffem,
                                          fontWeight: FontWeight.w600,
                                          height: 1.1725 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Number of Items:\n',
                                          ),
                                          TextSpan(
                                            text:
                                                '${inVM.tolistPO.value[widget.index].T_DATA.length}',
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 12 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.1725 * ffem / fem,
                                              color: Color(0xff000000),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 23 * fem,
                                  ),
                                  Container(
                                    // totalgrinctn0fzK (I11:802;11:385)
                                    constraints: BoxConstraints(
                                      maxWidth: 88 * fem,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 12 * ffem,
                                          fontWeight: FontWeight.w600,
                                          height: 1.1725 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Total GR in CTN:\n',
                                          ),
                                          TextSpan(
                                            text: _CalculTotalctn(),
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 12 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.1725 * ffem / fem,
                                              color: Color(0xff000000),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 23 * fem,
                                  ),
                                  Container(
                                    // totalgrinpcs120PNb (I11:802;11:384)
                                    constraints: BoxConstraints(
                                      maxWidth: 87 * fem,
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: SafeGoogleFont(
                                          'Roboto',
                                          fontSize: 12 * ffem,
                                          fontWeight: FontWeight.w600,
                                          height: 1.1725 * ffem / fem,
                                          color: Color(0xff000000),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Total GR in PCS / KG:\n',
                                          ),
                                          TextSpan(
                                            text: _CalculTotalpcs(),
                                            style: SafeGoogleFont(
                                              'Roboto',
                                              fontSize: 12 * ffem,
                                              fontWeight: FontWeight.w400,
                                              height: 1.1725 * ffem / fem,
                                              color: Color(0xff000000),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                                child: widget.from == "sync"
                                    ? Container(
                                        // frame11azo (I11:802;11:371)
                                        // margin: EdgeInsets.fromLTRB(
                                        //     7.5 * fem, 0 * fem, 7.5 * fem, 0 * fem),
                                        width: double.infinity,
                                        height: 40 * fem,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // cancelbuttonVM5 (I11:802;11:372)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  30 * fem,
                                                  0 * fem),
                                              child: TextButton(
                                                onPressed: () {
                                                  _showMyDialogReject(inVM
                                                      .tolistPO
                                                      .value[widget.index]);
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
                                                        color:
                                                            Color(0xfff44236)),
                                                    color: Color(0xffffffff),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12 * fem),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x3f000000),
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
                                              onPressed: containerinput.text ==
                                                      ""
                                                  ? null // Disable the button by setting onPressed to null
                                                  : () {
                                                      setState(() {
                                                        _showMyDialogApprove(
                                                            widget.flag);
                                                      });
                                                    },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: containerinput
                                                            .text ==
                                                        ""
                                                    ? Colors
                                                        .grey // Set the background color to gray for disabled button
                                                    : Color(
                                                        0xff2cab0c), // Set the original background color for enabled button
                                                // foregroundColor: Colors
                                                //     .white, // Set the text color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12 * fem),
                                                ),
                                                shadowColor: Color(0x3f000000),
                                                elevation: 2 * fem,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    52 * fem,
                                                    5 * fem,
                                                    53 * fem,
                                                    5 * fem),
                                                height: double.infinity,
                                                child: Center(
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
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        // frame11azo (I11:802;11:371)
                                        // margin: EdgeInsets.fromLTRB(
                                        //     7.5 * fem, 0 * fem, 7.5 * fem, 0 * fem),
                                        width: double.infinity,
                                        height: 40 * fem,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              // cancelbuttonVM5 (I11:802;11:372)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  30 * fem,
                                                  0 * fem),
                                              child: TextButton(
                                                onPressed: () {
                                                  _showMyDialogReject(inVM
                                                      .tolistPO
                                                      .value[widget.index]);
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
                                                        color:
                                                            Color(0xfff44236)),
                                                    color: Color(0xffffffff),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12 * fem),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x3f000000),
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
                                              onPressed:
                                                  // inVM
                                                  //             .tolistPO
                                                  //             .value[widget.index]
                                                  //             .T_DATA
                                                  //             .any((element) =>
                                                  //                 element.vfdat ==
                                                  //                 "0000-00-00") ||

                                                  containerinput.text == ""
                                                      ? null // Disable the button by setting onPressed to null
                                                      : () {
                                                          setState(() {
                                                            _showMyDialogApprove(
                                                                inVM.tolistPO
                                                                        .value[
                                                                    widget
                                                                        .index]);
                                                          });
                                                        },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor:
                                                    //  inVM
                                                    //             .tolistPO
                                                    //             .value[widget.index]
                                                    //             .T_DATA
                                                    //             .any((element) =>
                                                    //                 element.vfdat ==
                                                    //                 "0000-00-00") ||

                                                    containerinput.text == ""
                                                        ? Colors
                                                            .grey // Set the background color to gray for disabled button
                                                        : Color(
                                                            0xff2cab0c), // Set the original background color for enabled button
                                                // foregroundColor: Colors
                                                //     .white, // Set the text color
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12 * fem),
                                                ),
                                                shadowColor: Color(0x3f000000),
                                                elevation: 2 * fem,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    52 * fem,
                                                    5 * fem,
                                                    53 * fem,
                                                    5 * fem),
                                                height: double.infinity,
                                                child: Center(
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
                                            )
                                          ],
                                        ),
                                      ),
                                visible: widget.from != "history")
                          ],
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
