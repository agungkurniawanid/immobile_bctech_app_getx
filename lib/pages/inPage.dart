import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/recent.dart';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/inmodel.dart';
import 'package:immobile/page/indetailPage.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shimmer/shimmer.dart';
import 'package:immobile/widget/card.dart';

class InPage extends StatefulWidget {
  @override
  _InPage createState() => _InPage();
}

class _InPage extends State<InPage> {
  bool _allow = true;
  int idPeriodSelected = 1;
  List<String> sortList = ['PO Date', 'Vendor'];
  InVM inVM = Get.find();
  GlobalVM globalvm = Get.find();
  List<ItemChoice> listchoice = [];
  List<Category> listcategory = [];
  List<InModel> listinmodel = [];
  ScrollController controller;
  bool _leading = true;
  GlobalKey srKey = GlobalKey();
  bool _isSearching = false;
  TextEditingController _searchQuery;
  String searchQuery;
  var choicein = "".obs;

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    getchoicechip();
  }

  void getchoicechip() async {
    try {
      listcategory = await DatabaseHelper.db.getCategorywithrole("IN");

      setState(() {
        for (int i = 0; i < listcategory.length; i++) {
          if (listcategory[i].inventory_group_name == "Others") {
          } else {
            ItemChoice choicelocal = ItemChoice(
                id: i + 1,
                label: listcategory[i].inventory_group_id,
                labelname: listcategory[i].inventory_group_name);
            listchoice.add(choicelocal);
          }
          // if(listcategory[i].)

        }
        GlobalVar.choicecategory = listchoice[0].label;
        inVM.choicein.value = listchoice[0].label;
        // stockrequestVM.choicesr.value = listchoice[0].label;
        if (listcategory.length != 0) {
          inVM.onReady();
        }
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
      if (listinmodel
          .where((element) =>
              element.ebeln != null &&
              element.ebeln is String &&
              element.ebeln.contains(search))
          .toList()
          .isNotEmpty) {
        inVM.tolistPO.assignAll(listinmodel
            .where((element) =>
                element.ebeln != null &&
                element.ebeln is String &&
                element.ebeln.contains(search))
            .toList());
      } else if (listinmodel
          .where((element) =>
              element.invoiceno != null &&
              element.invoiceno is String &&
              element.invoiceno.contains(search))
          .toList()
          .isNotEmpty) {
        inVM.tolistPO.assignAll(listinmodel
            .where((element) =>
                element.invoiceno != null &&
                element.invoiceno is String &&
                element.invoiceno.contains(search))
            .toList());
      } else if (listinmodel
          .where((element) =>
              element.vendorpo != null &&
              element.vendorpo is String &&
              element.vendorpo.contains(search))
          .toList()
          .isNotEmpty) {
        inVM.tolistPO.assignAll(listinmodel
            .where((element) =>
                element.vendorpo != null &&
                element.vendorpo is String &&
                element.vendorpo.contains(search))
            .toList());
      } else {
        inVM.tolistPO.assignAll([]);
      }
    } catch (e) {
      print(e);
      inVM.tolistPO.assignAll([]);
    }
    // if (listinmodel
    //         .where((element) => element.ebeln.contains(search))
    //         .toList()
    //         .length !=
    //     0) {
    //   inVM.tolistPO.assignAll(listinmodel
    //       .where((element) => element.ebeln.contains(search))
    //       .toList());
    // } else if (listinmodel
    //         .where((element) => element.invoiceno.contains(search))
    //         .toList()
    //         .length !=
    //     0) {
    //   inVM.tolistPO.assignAll(listinmodel
    //       .where((element) => element.invoiceno.contains(search))
    //       .toList());
    // } else if (listinmodel
    //         .where((element) => element.vendorpo.contains(search))
    //         .toList()
    //         .length !=
    //     0) {
    //   inVM.tolistPO.assignAll(listinmodel
    //       .where((element) => element.vendorpo.contains(search))
    //       .toList());
    // } else {
    //   inVM.tolistPO.assignAll([]);
    // }
  }

  void _startSearch() {
    setState(() {
      listinmodel.clear();
      var locallist = inVM.tolistPO.value;
      for (var i = 0; i < locallist.length; i++) {
        listinmodel.add(locallist[i]);
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
      if (listcategory.length != 0) {
        inVM.onReady();
      }
      // inVM.onReady();
      // inVM.tolistPO.value.clear();
      // inVM.tolistPO.assignAll(listinmodel);
    });
  }

  Widget headerCard2(InModel inmodel) {
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
                    children: [
                      Container(
                        // autogroupqe3auJY (Xy3E1KY1gvhpbMNvhZQE3A)
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 12 * fem, 13.34 * fem),
                        width: 130 * fem,
                        height: 38 * fem,
                        decoration: BoxDecoration(
                          color: inVM.choicein.value == "FZ"
                              ? Colors.blue
                              : inVM.choicein.value == "CH"
                                  ? Colors.green
                                  : inVM.choicein.value == "All"
                                      ? Colors.orange
                                      : Color(0xfff44236),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8 * fem),
                            bottomRight: Radius.circular(8 * fem),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${inmodel.ebeln}',
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
                      Container(
                        // podate070320222Gg (11:442)
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 0 * fem, 25 * fem, 10.34 * fem),
                        child: Text(
                          'PO Date: ${inVM.dateToString(inmodel.aedat, "aedat")}',
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
                        margin: EdgeInsets.fromLTRB(
                            0 * fem, 31.94 * fem, 0 * fem, 0 * fem),
                        width: 11 * fem,
                        height: 19.39 * fem,
                        child: Image.asset(
                          'data/images/vector-1HV.png',
                          width: 11 * fem,
                          height: 19.39 * fem,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // vendor1000000crownpacificinves (11:443)
                  margin:
                      EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                  child: Text(
                    inmodel.lifnr.length > 42
                        ? 'Vendor:   ${inmodel.lifnr.substring(0, 7)}' +
                            '\n' +
                            '${inmodel.lifnr.substring(8, 43)}'
                        : inmodel.lifnr.contains("Crown Pacific Investments")
                            ? 'Vendor:   ${inmodel.lifnr.substring(0, 7)}' +
                                '\n' +
                                '${inmodel.lifnr.substring(8, inmodel.lifnr.length)}'
                            : inmodel.lifnr.contains("Australian Fruit Juice")
                                ? 'Vendor:   ${inmodel.lifnr.substring(0, 7)}' +
                                    '\n' +
                                    '${inmodel.lifnr.substring(8, inmodel.lifnr.length)}'
                                : 'Vendor:   ${inmodel.lifnr}',
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
                  // vendor1000000crownpacificinves (11:443)
                  margin:
                      EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                  child: Text(
                    'Invoice No:   ${inmodel.invoiceno}',
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
                  // vendor1000000crownpacificinves (11:443)
                  margin:
                      EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                  child: Text(
                    'Last Updated : ' +
                        inVM.dateToString(inmodel.created, "created"),
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
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController textFieldController =
                      TextEditingController();
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      'Sync By Document Number',
                      style: SafeGoogleFont(
                        'Roboto',
                        // fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Text('Do you want to proceed?'),
                          TextField(
                            controller: textFieldController,
                            decoration: InputDecoration(
                              hintText: 'Document Number',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              // Other text style properties
                            ),
                          )
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.all(20.0),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () async {
                          // GlobalVar.flag = "sync";
                          EasyLoading.show(
                              status: 'Loading Get PO',
                              maskType: EasyLoadingMaskType.black);
                          String enteredText = textFieldController.text;
                          dynamic check = await inVM.getpowithdoc(enteredText);
                          print(check);
                          if (check != "0") {
                            // inVM.onReady();
                            var data = await inVM.getData(enteredText, check);
                            // for (int i = 0; i < data.length; i++) {
                            //   if (inVM.tolistPO.length == 0) {
                            //     inVM.tolistPO.value = [];
                            //     inVM.tolistPO.add(data[i]);
                            //   } else {
                            //     inVM.tolistPO.add(data[i]);
                            //   }
                            // }

                            // print("asawau");

                            // int indexfromdocument = inVM.tolistPO.indexWhere(
                            //     (element) => element.ebeln == enteredText);

                            // inVM.onReady();
                            Navigator.of(context).pop();
                            // print(index);
                            if (data.length != 0) {
                              var choice = listchoice.singleWhere(
                                  (element) => element.label == check);
                              idPeriodSelected = choice.id;
                              GlobalVar.choicecategory = choice.label;
                              inVM.choicein.value = choice.label;
                              // Get.back();
                              // Get.to(InDetailPage(0, "sync", data[0]));
                              Get.to(() => InDetailPage(0, "sync", data[0]));
                              Fluttertoast.showToast(
                                  fontSize: 22,
                                  gravity: ToastGravity.TOP,
                                  msg: "Success Get Document",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.green);
                              EasyLoading.dismiss();
                            } else {
                              // Get.back();
                              // Get.to(InDetailPage(0, "sync", data[0]));
                              Fluttertoast.showToast(
                                  fontSize: 22,
                                  gravity: ToastGravity.TOP,
                                  msg:
                                      "Document Doesn't Exist Or Document Cannot Release",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.green);
                              EasyLoading.dismiss();
                            }
                          } else {
                            Fluttertoast.showToast(
                                fontSize: 22,
                                gravity: ToastGravity.TOP,
                                msg: "Document Doesn't Exist ",
                                backgroundColor: Colors.red,
                                textColor: Colors.green);

                            EasyLoading.dismiss();
                            Get.back();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    if (inVM.isapprove.value) {
      // _isSearching = false;
      _stopSearching();
      inVM.isapprove.value = false;
      FocusScope.of(context).unfocus();
      // inVM.onReady();
    }

    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return WillPopScope(
        onWillPop: () => Future.value(_allow),
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    actions: _buildActions(),
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 20.0,
                      onPressed: () {
                        GlobalVar.choicecategory =
                            globalvm.choicecategory.value;
                        if (GlobalVar.choicecategory == "ALL") {
                          if (listcategory.length != 0) {
                            inVM.onRecent();
                          }
                          // inVM.onRecent();
                        } else {
                          if (listcategory.length != 0) {
                            inVM.onReady();
                          }
                          // inVM.onReady();
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
                    title: _isSearching
                        ? _buildSearchField()
                        : Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Container(
                                child: TextWidget(
                                    text: "GR In Purchase Order",
                                    isBlueTxt: false,
                                    maxLines: 2,
                                    size: 18,
                                    color: Colors.white)),
                          ),
                    // actions: widget.listTrack != null ? null : _buildActions(),
                    centerTitle: true),
                backgroundColor: kWhiteColor,
                body: Container(
                  padding: EdgeInsets.only(bottom: 25, left: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                    text:
                                        '${inVM.tolistPO.length} of ${inVM.tolistPO.length} data shown',
                                    isBlueTxt: false,
                                    maxLines: 2,
                                    size: 16),
                                Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white, //<-- SEE HERE
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.sort, color: Colors.black),
                                        DropdownButton(
                                          dropdownColor: Colors.white,
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.red,
                                          ),
                                          hint: TextWidget(
                                              isBlueTxt: false,
                                              text: 'Sort By ',
                                              size: 16.0),
                                          value: inVM.sortVal.value,
                                          items: sortList.map((value) {
                                            return DropdownMenuItem(
                                              child: TextWidget(
                                                  text: value,
                                                  isBlueTxt: false),
                                              value: value,
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              inVM.sortVal.value = value;
                                              if (value == "PO Date") {
                                                inVM.tolistPO.value.sort((a,
                                                        b) =>
                                                    b.aedat.compareTo(a.aedat));
                                              } else {
                                                inVM.tolistPO.value.sort((a,
                                                        b) =>
                                                    a.lifnr.compareTo(b.lifnr));
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ))
                              ],
                            ),
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
                                              e.labelname,
                                            ),
                                            selected: idPeriodSelected == e.id,
                                            onSelected: (_) {
                                              setState(() {
                                                idPeriodSelected = e.id;
                                                _stopSearching();
                                                if (idPeriodSelected == 5) {
                                                  int choice =
                                                      idPeriodSelected - 1;
                                                  GlobalVar.choicecategory =
                                                      listchoice
                                                          .where((element) =>
                                                              element.label
                                                                  .contains(
                                                                      "ALL"))
                                                          .toList()[0]
                                                          .label;
                                                  inVM.choicein.value =
                                                      listchoice[3].labelname;
                                                } else {
                                                  // _stopSearching();
                                                  int choice =
                                                      idPeriodSelected - 1;
                                                  GlobalVar.choicecategory =
                                                      listchoice[choice].label;
                                                  inVM.choicein.value =
                                                      listchoice[choice].label;
                                                }
                                                if (listcategory.length != 0) {
                                                  inVM.onReady();
                                                }
                                                // inVM.onReady();
                                              });
                                              // changeSelectedId('Period', e.id);
                                            },
                                            selectedColor: Theme.of(context)
                                                        .backgroundColor ==
                                                    Colors.grey[100]
                                                ? Colors.white
                                                : inVM.choicein.value == "All"
                                                    ? Colors.orange
                                                    : inVM.choicein.value ==
                                                            "FZ"
                                                        ? Colors.blue
                                                        : inVM.choicein.value ==
                                                                "CH"
                                                            ? Colors.green
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
                        return inVM.isLoading.value
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[500],
                                highlightColor: Colors.white12,
                                period: Duration(milliseconds: 1500),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: CardWidget(
                                      text: '',
                                      icon: Icons.tag,
                                      height: Get.height * 0.5,
                                    ),
                                  ),
                                ),
                              )
                            : inVM.tolistPO.length == 0
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
                                    child: ListView.builder(
                                        controller: controller,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        // gridDelegate:
                                        //     SliverGridDelegateWithFixedCrossAxisCount(
                                        //         crossAxisCount: 1),
                                        itemCount: inVM.tolistPO.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            child: headerCard2(
                                                inVM.tolistPO.value[index]),
                                            onTap: () async {
                                              Get.to(InDetailPage(
                                                  index, "in", null));
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
