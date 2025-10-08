import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:immobile/model/stocktake.dart';
import 'package:immobile/model/stocktakedetail.dart';
import 'package:immobile/page/StockTakeDetail.dart';
import 'package:immobile/model/category.dart';
// import 'package:immobile/viewmodel/// inVM.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/stocktickvm.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/widget/utils.dart';

class StockTakeHeader extends StatefulWidget {
  final StocktickModel stocktake;
  const StockTakeHeader(this.stocktake);
  @override
  _StockTakeHeader createState() => _StockTakeHeader();
}

class _StockTakeHeader extends State<StockTakeHeader> {
  bool _allow = true;
  int idPeriodSelected = 1;
  List<String> sortList = ['PO Date', 'Vendor'];
  // // inVM // inVM = Get.find();
  GlobalVM globalvm = Get.find();
  StockTickVM stocktickvm = Get.find();
  List<ItemChoice> listchoice = [];
    List<ItemChoice> listchoice2 = [];
  List<Category> listcategory = [];
  // List<InModel> listinmodel = [];
  ScrollController controller;
  bool _leading = true;
  GlobalKey srKey = GlobalKey();
  bool _isSearching = false;
  TextEditingController _searchQuery;
  String searchQuery;
  var choicein = "".obs;
  String choiceforchip;
  List<StocktickModel> stocklocal = [];
  String werks,lgort = "";

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();

    // stocktickvm.listdocument();
    getchoicechip();
  }

  void parseLGORT() {
    if (widget.stocktake.LGORT.isNotEmpty) {
      // Ambil elemen pertama dari List<String>
      final String item = widget.stocktake.LGORT.first;

      // Bersihkan string: hapus kurung siku dan spasi
      final cleanedItem = item.replaceAll("[", "").replaceAll("]", "").trim();

      // Pisahkan berdasarkan "-"
      final parts = cleanedItem.split('-');

      // Ambil nilai werks dan lgort
      if (parts.length == 2) {
        werks = parts[0]; // Bagian sebelum "-"
        lgort = parts[1]; // Bagian setelah "-"
      }
    }
  }

  void getchoicechip() async {
    try {
      listcategory = await DatabaseHelper.db.getCategorywithrole("STOCKTAKE");
      setState(() {
           for (int i = 0; i < listcategory.length; i++) {
          // if (listcategory[i].inventory_group_name == "Others") {
          // } else {
          ItemChoice choicelocal = ItemChoice(
              id: i + 1,
              label: listcategory[i].inventory_group_id,
              labelname: listcategory[i].inventory_group_name);
          listchoice2.add(choicelocal);
          // }
          // if(listcategory[i].)

        }
        // for (int i = 0; i < 1; i++) {
        // if (listcategory[i].inventory_group_name == "Others") {
        // } else {
        ItemChoice choicelocal = ItemChoice(
          id: 0 + 1,
          label: "N",
          labelname: "In Progress",
        );
        listchoice.add(choicelocal);

        ItemChoice choicelocal2 = ItemChoice(
          id: 1 + 1,
          label: "Y",
          labelname: "Completed",
        );
        listchoice.add(choicelocal2);

        // }
        // if(listcategory[i].)

        // }
        stocktickvm.choiceforchip = listchoice[0].label;
        stocktickvm.onReady();
        // stocktickvm.forDetail();
        // inVM.choicein.value = listchoice[0].label;
        // stockrequestVM.choicesr.value = listchoice[0].label;
        // if (listcategory.length != 0) {
        //   // inVM.onReady();
        // }
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _buildSearchField() {
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
    try {
      stocktickvm.tolistdocument.assignAll(stocklocal
          .where((element) =>
              element.documentno != null &&
              element.documentno is String &&
              element.documentno.contains(search.toUpperCase()))
          .toList());
    } catch (e) {
      print(e);
      // inVM.tolistPO.assignAll([]);
    }
    // if (listinmodel
    //         .where((element) => element.ebeln.contains(search))
    //         .toList()
    //         .length !=
    //     0) {
    //   // inVM.tolistPO.assignAll(listinmodel
    //       .where((element) => element.ebeln.contains(search))
    //       .toList());
    // } else if (listinmodel
    //         .where((element) => element.invoiceno.contains(search))
    //         .toList()
    //         .length !=
    //     0) {
    //   // inVM.tolistPO.assignAll(listinmodel
    //       .where((element) => element.invoiceno.contains(search))
    //       .toList());
    // } else if (listinmodel
    //         .where((element) => element.vendorpo.contains(search))
    //         .toList()
    //         .length !=
    //     0) {
    //   // inVM.tolistPO.assignAll(listinmodel
    //       .where((element) => element.vendorpo.contains(search))
    //       .toList());
    // } else {
    //   // inVM.tolistPO.assignAll([]);
    // }
  }

  void _startSearch() {
    setState(() {
      stocklocal.clear();
      var locallist = stocktickvm.tolistdocument.value;
      for (var i = 0; i < locallist.length; i++) {
        stocklocal.add(locallist[i]);
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
      stocktickvm.tolistdocument.value.clear();

      for (var item in stocklocal) {
        stocktickvm.tolistdocument.value.add(item);
      }
      // // inVM.onReady();
      // // inVM.tolistPO.value.clear();
      // // inVM.tolistPO.assignAll(listinmodel);
    });
  }

  Widget headerCard2(StocktickModel inmodel) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
        // poambienteLg (11:470)
        margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 10 * fem, 10 * fem),
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 13 * fem),
            width: double.infinity,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // autogroupth7veNc (Xy3DvKgLfPnrzafMJutH7v)
                  margin: EdgeInsets.fromLTRB(
                      0 * fem, 0 * fem, 0 * fem, 1.66 * fem),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // autogroupqe3auJY (Xy3E1KY1gvhpbMNvhZQE3A)
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 12 * fem, 13.34 * fem),
                        width: 130 * fem,
                        height: 38 * fem,
                        decoration: BoxDecoration(
                          color: Color(0xfff44236),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8 * fem),
                            bottomRight: Radius.circular(8 * fem),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${inmodel.documentno}',
                            style: SafeGoogleFont(
                              'Roboto',
                              fontSize: 16 * ffem,
                              fontWeight: FontWeight.w600,
                              height: 1.1725 * ffem / fem,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            // podate070320222Gg (11:442)
                            margin: EdgeInsets.fromLTRB(
                                60 * fem, 0 * fem, 25 * fem, 10.34 * fem),
                            child: Text(
                              inmodel.isapprove == "Y" ? 'Completed' : '',
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
                            // vectorfqS (11:444)
                            // margin: EdgeInsets.fromLTRB(
                            //     80 * fem, 31.94 * fem, 0 * fem, 0 * fem),
                            width: 11 * fem,
                            height: 19.39 * fem,
                            child: Image.asset(
                              'data/images/vector-1HV.png',
                              width: 11 * fem,
                              height: 19.39 * fem,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  // vendor1000000crownpacificinves (11:443)
                  margin:
                      EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                  child: Text(
                    'Created By:   ${inmodel.createdby}',
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 16 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff2d2d2d),
                    ),
                  ),
                ),
                // Container(
                //   // vendor1000000crownpacificinves (11:443)
                //   margin:
                //       EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                //   child: Text(
                //     'Invoice No:   ${inmodel.LGORT}',
                //     style: SafeGoogleFont(
                //       'Roboto',
                //       fontSize: 16 * ffem,
                //       fontWeight: FontWeight.w600,
                //       height: 1.1725 * ffem / fem,
                //       color: Color(0xff2d2d2d),
                //     ),
                //   ),
                // ),

                Container(
                  // vendor1000000crownpacificinves (11:443)
                  margin:
                      EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                  child: Text(
                    'Created At : ${inmodel.created}',
                    style: SafeGoogleFont(
                      'Roboto',
                      fontSize: 16 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.1725 * ffem / fem,
                      color: Color(0xff2d2d2d),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]));
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
          // IconButton(
          //   icon: const Icon(Icons.refresh_outlined),
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         TextEditingController textFieldController =
          //             TextEditingController();
          //         return AlertDialog(
          //           backgroundColor: Colors.white,
          //           title: Text(
          //             'Sync By Document Number',
          //             style: SafeGoogleFont(
          //               'Roboto',
          //               // fontWeight: FontWeight.w600,
          //               color: Colors.black,
          //             ),
          //           ),
          //           content: SingleChildScrollView(
          //             child: Column(
          //               children: [
          //                 // Text('Do you want to proceed?'),
          //                 TextField(
          //                   controller: textFieldController,
          //                   decoration: InputDecoration(
          //                     hintText: 'Document Number',
          //                     contentPadding:
          //                         EdgeInsets.symmetric(horizontal: 10.0),
          //                     focusedBorder: OutlineInputBorder(
          //                       borderSide: BorderSide(color: Colors.black),
          //                     ),
          //                     enabledBorder: OutlineInputBorder(
          //                       borderSide: BorderSide(color: Colors.black),
          //                     ),
          //                     hintStyle: TextStyle(color: Colors.black),
          //                   ),
          //                   textAlign: TextAlign.left,
          //                   style: TextStyle(
          //                     color: Colors.black,
          //                     // Other text style properties
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ),
          //           contentPadding: EdgeInsets.all(20.0),
          //           actions: <Widget>[
          //             TextButton(
          //               child: Text('Cancel'),
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //               },
          //             ),
          //             TextButton(
          //               child: Text('Yes'),
          //               onPressed: () async {
          //                 // GlobalVar.flag = "sync";
          //                 EasyLoading.show(
          //                     status: 'Loading Get PO',
          //                     maskType: EasyLoadingMaskType.black);
          //                 String enteredText = textFieldController.text;
          //                 // dynamic check = await // inVM.getpowithdoc(enteredText);
          //                 // print(check);
          //                 // if (check != "0") {
          //                 //   // // inVM.onReady();
          //                 //   var data = await // inVM.getData(enteredText, check);
          //                 //   // for (int i = 0; i < data.length; i++) {
          //                 //   //   if (// inVM.tolistPO.length == 0) {
          //                 //   //     // inVM.tolistPO.value = [];
          //                 //   //     // inVM.tolistPO.add(data[i]);
          //                 //   //   } else {
          //                 //   //     // inVM.tolistPO.add(data[i]);
          //                 //   //   }
          //                 //   // }

          //                 //   // print("asawau");

          //                 //   // int indexfromdocument = // inVM.tolistPO.indexWhere(
          //                 //   //     (element) => element.ebeln == enteredText);

          //                 //   // // inVM.onReady();
          //                 //   Navigator.of(context).pop();
          //                 //   // print(index);
          //                 //   if (data.length != 0) {
          //                 //     var choice = listchoice.singleWhere(
          //                 //         (element) => element.label == check);
          //                 //     idPeriodSelected = choice.id;
          //                 //     GlobalVar.choicecategory = choice.label;
          //                 //     // inVM.choicein.value = choice.label;
          //                 //     // Get.back();
          //                 //     // Get.to(InDetailPage(0, "sync", data[0]));
          //                 //     Get.to(() => InDetailPage(0, "sync", data[0]));
          //                 //     Fluttertoast.showToast(
          //                 //         fontSize: 22,
          //                 //         gravity: ToastGravity.TOP,
          //                 //         msg: "Success Get Document",
          //                 //         backgroundColor: Colors.red,
          //                 //         textColor: Colors.green);
          //                 //     EasyLoading.dismiss();
          //                 //   } else {
          //                 //     // Get.back();
          //                 //     // Get.to(InDetailPage(0, "sync", data[0]));
          //                 //     Fluttertoast.showToast(
          //                 //         fontSize: 22,
          //                 //         gravity: ToastGravity.TOP,
          //                 //         msg:
          //                 //             "Document Doesn't Exist Or Document Cannot Release",
          //                 //         backgroundColor: Colors.red,
          //                 //         textColor: Colors.green);
          //                 //     EasyLoading.dismiss();
          //                 //   }
          //                 // } else {
          //                 //   Fluttertoast.showToast(
          //                 //       fontSize: 22,
          //                 //       gravity: ToastGravity.TOP,
          //                 //       msg: "Document Doesn't Exist ",
          //                 //       backgroundColor: Colors.red,
          //                 //       textColor: Colors.green);

          //                 //   EasyLoading.dismiss();
          //                 //   Get.back();
          //                 // }
          //               },
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   },
          // ),

          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        ],
      )
    ];
  }

  // List<Widget> _buildActions() {
  //   if (_isSearching) {
  //     return <Widget>[
  //       new IconButton(
  //         icon: const Icon(Icons.clear),
  //         onPressed: () {
  //           if (_searchQuery == null || _searchQuery.text.isEmpty) {
  //             setState(() {
  //               _stopSearching();
  //             });
  //             return;
  //           }
  //           _clearSearchQuery();
  //         },
  //       ),
  //     ];
  //   }
  //   return <Widget>[
  //     new IconButton(
  //       icon: const Icon(Icons.search),
  //       onPressed: _startSearch,
  //     ),
  //   ];
  // }

  Future _showMyDialogApprove() async {
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
                            'Are you sure to create a new stock take document based on current stock?',
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
                                    // setState(() async {
                                      try {
                                        EasyLoading.show(
                                            status: 'Loading Create Document',
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        // List<Map<String, dynamic>> maptdata =
                                        //     stockmodel
                                        //         .map((person) => person.toMap())
                                        //         .toList();
                                       
                                        parseLGORT();
                      await stocktickvm.getStock(lgort,werks,globalvm.username.value);
                                             EasyLoading.dismiss();
                                        Get.back();
                                      } catch (e) {
                                        EasyLoading.dismiss();
                                        print(e);
                                      }
                                      ;
                                      // DateTime now = DateTime.now();
                                      // String formattedDate =
                                      //     DateFormat('yyyy-MM-dd kk:mm:ss')
                                      //         .format(now);
                                    // });
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
    // if (// inVM.isapprove.value) {
    //   // _isSearching = false;
    //   // _stopSearching();
    //   // inVM.isapprove.value = false;
    //   FocusScope.of(context).unfocus();
    //   // // inVM.onReady();
    // }
    // GlobalVar.darkChecker(context);
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return WillPopScope(
        onWillPop: () => Future.value(_allow),
        child: SafeArea(
            child: Scaffold(
                floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                    
                  
                      _showMyDialogApprove();
                      EasyLoading.dismiss();
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.red,
                  ),
                appBar: AppBar(
                    // actions: _buildActions(),
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 20.0,
                      onPressed: () {
                        GlobalVar.choicecategory =
                            globalvm.choicecategory.value;
                        if (GlobalVar.choicecategory == "ALL") {
                          // if (listcategory.length != 0) {
                          //   // inVM.onRecent();
                          // }
                          // // inVM.onRecent();
                        } else {
                          // if (listcategory.length != 0) {
                          // // inVM.onReady();
                          // }
                          // // inVM.onReady();
                        }

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
                    // title: _isSearching
                    //     ? _buildSearchField()
                    //     :
                    title: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: _isSearching
                          ? _buildSearchField()
                          : Container(
                              child: TextWidget(
                                  text: "${widget.stocktake.LGORT}",
                                  isBlueTxt: false,
                                  maxLines: 2,
                                  size: 18 * ffem,
                                  color: Colors.white)),
                    ),
                    actions: _buildActions(),
                    centerTitle: true),
                backgroundColor: kWhiteColor,
                body: Container(
                  padding: EdgeInsets.only(bottom: 25, left: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Obx(() {
                      //   return
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 5),
                          Padding(
                              child: Wrap(
                                children: listchoice
                                    .map((e) => ChoiceChip(
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          labelStyle: (Theme.of(context)
                                                      .backgroundColor ==
                                                  Colors.grey[100]
                                              ? (idPeriodSelected == e.id
                                                  ? TextStyle(
                                                      fontSize: 16 * ffem,
                                                      color: Colors.white)
                                                  : TextStyle(
                                                      fontSize: 16 * ffem,
                                                      color: Colors.white))
                                              : (idPeriodSelected == e.id
                                                  ? TextStyle(
                                                      fontSize: 16 * ffem,
                                                      color: Colors.white)
                                                  : TextStyle(
                                                      fontSize: 16 * ffem,
                                                      color: Colors.white))),
                                          backgroundColor: Theme.of(context)
                                                      .backgroundColor ==
                                                  Colors.grey[100]
                                              ? Colors.grey
                                              : Colors.grey,
                                          label: Text(
                                            e.labelname,
                                          ),
                                          selected: idPeriodSelected == e.id,
                                          onSelected: (_) {
                                            setState(() {
                                              idPeriodSelected = e.id;
                                              // _stopSearching();
                                              // if (idPeriodSelected == 5) {
                                              //   int choice =
                                              //       idPeriodSelected - 1;
                                              //   GlobalVar.choicecategory =
                                              //       listchoice
                                              //           .where((element) =>
                                              //               element.label
                                              //                   .contains(
                                              //                       "ALL"))
                                              //           .toList()[0]
                                              //           .label;
                                              //   // // inVM.choicein.value =
                                              //   //     listchoice[3].labelname;
                                              // } else {
                                              // _stopSearching();
                                              int choice = idPeriodSelected - 1;
                                              stocktickvm.choiceforchip =
                                                  listchoice[choice].label;
                                              stocktickvm.onReady();
                                              // // inVM.choicein.value =
                                              //     listchoice[choice].label;
                                              // }
                                              // if (listcategory.length != 0) {
                                              //   // // inVM.onReady();
                                              // }
                                              // // inVM.onReady();
                                            });
                                            // changeSelectedId('Period', e.id);
                                          },
                                          selectedColor: Color(0xfff44236),
                                          elevation: 10,
                                        ))
                                    .toList(),
                                spacing: 25,
                              ),
                              padding: EdgeInsets.only(bottom: 10)),
                        ],
                      ),
                      // }),
                      Obx(() {
                        return // inVM.isLoading.value
                            //       // ?
                            // Shimmer.fromColors(
                            //           baseColor: Colors.grey[500],
                            //           highlightColor: Colors.white12,
                            //           period: Duration(milliseconds: 1500),
                            //           child: Padding(
                            //             padding: const EdgeInsets.all(8.0),
                            //             child: Padding(
                            //               padding: EdgeInsets.only(bottom: 5),
                            //               child: CardWidget(
                            //                 text: '',
                            //                 icon: Icons.tag,
                            //                 height: Get.height * 0.5,
                            //               ),
                            //             ),
                            //           ),
                            //         )
                            //       // : // inVM.tolistPO.length == 0
                            //       //     ?
                            stocktickvm.tolistdocument.length == 0
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
                                : Expanded(
                                    child: Obx((){
                                      return   ListView.builder(
                                        controller: controller,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        // gridDelegate:
                                        //     SliverGridDelegateWithFixedCrossAxisCount(
                                        //         crossAxisCount: 1),
                                        itemCount:
                                            stocktickvm.tolistdocument.value.where((element) => element.isapprove == stocktickvm.choiceforchip).length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            child: headerCard2(stocktickvm
                                                .tolistdocument.value.where((element) => element.isapprove == stocktickvm.choiceforchip).toList()[index]),
                                            // inVM.tolistPO.value[index]),

                                            onTap: () async {
                                              stocktickvm.searchValue.value =
                                                  '';
                                              Get.to(() => StockTakeDetail(
                                                  stocktickvm
                                                      .tolistdocument[index],
                                                  index,stocktickvm
                                                      .tolistdocument[index].documentno));
                                            },
                                          );
                                        });
                                 
                                    })
                                    
                                   );
                      }),
                    ],
                  ),
                ))));
  }
}
