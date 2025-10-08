import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/recentsr.dart';
import 'package:intl/intl.dart';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/widget/outcard.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/outmodel.dart';
import 'package:immobile/page/outdetailPage.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:immobile/viewmodel/webordervm.dart';
import 'package:immobile/viewmodel/stockrequestvm.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class OutPage extends StatefulWidget {
  @override
  _OutPage createState() => _OutPage();
}

class _OutPage extends State<OutPage> {
  bool _allow = true;
  int idPeriodSelected = 1;
  List<String> sortList = ['Location', 'Delivery Date'];
  List<String> sortListSR = ['Request Date', 'Location'];
  InVM inVM = Get.find();
  List<ItemChoice> listchoice = [];
  List<ItemChoice> listchoiceWO = [];
  List<Category> listcategory = [];
  ScrollController controller;
  bool _leading = true;
  GlobalKey srKey = GlobalKey();
  WeborderVM weborderVM = Get.find();
  StockrequestVM stockrequestVM = Get.find();
  GlobalVM globalVM = Get.find();
  GlobalKey p4Key = GlobalKey();
  String choice = "SR";
  int length;
  bool _isSearching = false;
  TextEditingController _searchQuery;
  String searchQuery;
  DateTime date;
  String ebeln, barcodeScanRes;
  List<OutModel> listsearch = new List<OutModel>();

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    // var h1 = DateTime(
    //     DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
    // String h1string = DateFormat('yyyy-MM-dd').format(h1);
    // stockrequestVM.choicedate = h1string;
    // print('yuhu');
    getchoicechip();
    stockrequestVM.onButton();
    // forbutton();
  }

  // void forbutton() async {
  //   String forbutton = await stockrequestVM.forbutton();
  //   stockrequestVM.validationbuttonrefresh = forbutton;
  // }

  void getchoicechip() async {
    try {
      listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
      // print(listcategory);
      setState(() {
        ItemChoice choiceforall;
        if (listcategory.length == 1) {
          ItemChoice choicelocal = ItemChoice(
              id: listchoice.length + 1,
              label: listcategory[0].inventory_group_id,
              labelname: listcategory[0].inventory_group_name);
          listchoice.add(choicelocal);
        } else {
          for (int i = 0; i < listcategory.length; i++) {
            if (listcategory[i].inventory_group_name == "All") {
              ItemChoice choicelocal = ItemChoice(
                  id: 10,
                  label: listcategory[i].inventory_group_id,
                  labelname: listcategory[i].inventory_group_name);
              choiceforall = choicelocal;
              // listchoice.add(choiceforall);
            } else {
              ItemChoice choicelocal = ItemChoice(
                  id: listchoice.length + 1,
                  label: listcategory[i].inventory_group_id,
                  labelname: listcategory[i].inventory_group_name);
              // listchoiceWO.add(choicelocal);
              listchoice.add(choicelocal);
            }
          }
        }

        if (choiceforall == null) {
        } else {
          listchoice.add(choiceforall);
        }
        weborderVM.choiceout.value = listchoice[0].label;
        GlobalVar.choicecategory = listchoice[0].label;
        // weborderVM.choiceWO.value = listchoice[0].label;
        stockrequestVM.choicesr.value = listchoice[0].label;
        // weborderVM.onReady();
        stockrequestVM.onReady();
      });
    } catch (e) {
      print(e);
    }
  }

  // void getchoicechip() async {
  //   try {
  //     listcategory = await DatabaseHelper.db.getCategorywithrole("OUT");
  //     setState(() {
  //       ItemChoice choiceforall;
  //       for (int i = 0; i < listcategory.length; i++) {
  //         if (listcategory[i].inventory_group_name == "All") {
  //           ItemChoice choicelocal = ItemChoice(
  //               id: 10,
  //               label: listcategory[i].inventory_group_id,
  //               labelname: listcategory[i].inventory_group_name);
  //           choiceforall = choicelocal;
  //         } else {
  //           ItemChoice choicelocal = ItemChoice(
  //               id: listchoice.length + 1,
  //               label: listcategory[i].inventory_group_id,
  //               labelname: listcategory[i].inventory_group_name);
  //           listchoice.add(choicelocal);
  //           listchoiceWO.add(choicelocal);
  //         }
  //       }
  //       listchoice.add(choiceforall);
  //       GlobalVar.choicecategory = listchoice[0].label;
  //       weborderVM.choiceWO.value = listchoice[0].label;
  //       weborderVM.choiceout.value = listchoice[0].label;
  //       stockrequestVM.choicesr.value = listchoice[0].label;
  //       // weborderVM.onReady();
  //       // stockrequestVM.onReady();
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
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
          //   icon: const Icon(Icons.calendar_today_outlined),
          //   onPressed: () async {
          //     DateTime currentDate = DateTime.now();

          //     DateTime newDate = await showDatePicker(
          //       context: context,
          //       initialDate: currentDate,
          //       firstDate: currentDate.subtract(Duration(
          //           days:
          //               7)), // Set the first date to 1 year before the current date
          //       lastDate: currentDate,
          //     );

          //     if (newDate == null) return;

          //     setState(() {
          //       // stockrequestVM.choicedate =
          //       //     DateFormat('yyyy-MM-dd').format(newDate);

          //       stockrequestVM.onReady();
          //       // historyVM.choicedate.value =
          //       //     DateFormat('yyyy-MM-dd').format(newDate);
          //       // historyVM.onReady();
          //     });
          //   },
          // ),

          ValueListenableBuilder<bool>(
            valueListenable: stockrequestVM.forbutton,
            builder: (context, isButtonVisible, child) {
              return Visibility(
                visible: isButtonVisible,
                child: IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Do you want to proceed?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                // Add your cancel logic here if needed
                              },
                            ),
                            TextButton(
                              child: Text('Yes'),
                              onPressed: () async {
                                EasyLoading.show(
                                    status: 'Loading Get StockRequest',
                                    maskType: EasyLoadingMaskType.black);
                                bool check =
                                    await stockrequestVM.getstockrequest();
                                if (check) {
                                  stockrequestVM.onReady();
                                  Fluttertoast.showToast(
                                      fontSize: 22,
                                      gravity: ToastGravity.TOP,
                                      msg: "Success Get Document",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.green);
                                  EasyLoading.dismiss();
                                  Navigator.of(context).pop();
                                } else {
                                  Fluttertoast.showToast(
                                      fontSize: 22,
                                      gravity: ToastGravity.TOP,
                                      msg: "Document Doesn't Exist ",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.green);

                                  EasyLoading.dismiss();
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
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
    stockrequestVM.tolistsrout.value.clear();
    search = search.toUpperCase();

    var locallist2 = listsearch
        .where((element) => element.recordid.contains(search))
        .toList();

    for (var i = 0; i < locallist2.length; i++) {
      stockrequestVM.tolistsrout.value.add(locallist2[i]);
    }
  }

  void _startSearch() {
    setState(() {
      listsearch.clear();
      var locallist = stockrequestVM.tolistsrout.value;
      for (var i = 0; i < locallist.length; i++) {
        listsearch.add(locallist[i]);
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

      stockrequestVM.tolistsrout.value.clear();

      for (var item in listsearch) {
        stockrequestVM.tolistsrout.value.add(item);
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

  @override
  Widget build(BuildContext context) {
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
                        stockrequestVM.choicesr.value =
                            globalVM.choicecategory.value;
                        GlobalVar.choicecategory =
                            globalVM.choicecategory.value;
                        stockrequestVM.onReady();
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
                            child: TextWidget(
                                text: "OUT",
                                isBlueTxt: false,
                                maxLines: 2,
                                size: 20,
                                color: Colors.white)),
                    // actions: widget.listTrack != null ? null : _buildActions(),
                    centerTitle: true),
                backgroundColor: kWhiteColor,
                body: Container(
                  padding: EdgeInsets.only(bottom: 20, left: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            return TextWidget(
                                text: choice == "WO"
                                    ? '${weborderVM.tolistwoout.value.length} of ${weborderVM.tolistwoout.value.length} data shown'
                                    : choice == "SR" &&
                                            GlobalVar.choicecategory
                                                .contains("ALL")
                                        ? '${stockrequestVM.tolistsrout.length} of ${stockrequestVM.tolistsrout.length} data shown'
                                        : '${stockrequestVM.tolistsrout.value.where((element) => element.detail != null && element.detail.any((detail) => detail.inventory_group.contains(GlobalVar.choicecategory))).toList().length} of ${stockrequestVM.tolistsrout.value.where((element) => element.detail != null && element.detail.any((detail) => detail.inventory_group.contains(GlobalVar.choicecategory))).toList().length} data shown',
                                isBlueTxt: false,
                                maxLines: 2,
                                size: 16);
                          }),
                          Row(
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
                                value: choice == "WO"
                                    ? weborderVM.sortVal.value
                                    : weborderVM.sortValSR.value,
                                items: choice == "WO"
                                    ? sortList.map((value) {
                                        return DropdownMenuItem(
                                          child: TextWidget(
                                              text: value, isBlueTxt: false),
                                          value: value,
                                        );
                                      }).toList()
                                    : sortListSR.map((value) {
                                        return DropdownMenuItem(
                                          child: TextWidget(
                                              text: value, isBlueTxt: false),
                                          value: value,
                                        );
                                      }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    choice == "WO"
                                        ? weborderVM.sortVal.value = value
                                        : weborderVM.sortValSR.value = value;
                                    if (value == "Location") {
                                      choice == "WO"
                                          ? weborderVM.tolistwoout.value.sort(
                                              (a, b) => a.location
                                                  .compareTo(b.location))
                                          : stockrequestVM.tolistsrout.value
                                              .sort((a, b) => a.location
                                                  .compareTo(b.location));
                                    } else {
                                      if (choice == "WO") {
                                        weborderVM.tolistwoout.value.sort(
                                            (a, b) => a.delivery_date
                                                .compareTo(b.delivery_date));
                                      } else {
                                        stockrequestVM.tolistsrout.value.sort(
                                            (a, b) => b.delivery_date
                                                .compareTo(a.delivery_date));
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      // Container(
                      //   // pochillerjMu (11:476)
                      //   // margin:
                      //   //     EdgeInsets.fromLTRB(16 * fem, 0 * fem, 17 * fem, 0 * fem),
                      //   // padding: EdgeInsets.all(10),
                      //   // width: double.infinity,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Obx(() {
                      //             return TextWidget(
                      //                 text: choice == "WO"
                      //                     ? '${weborderVM.tolistwoout.value.length} of ${weborderVM.tolistwoout.value.length} data shown'
                      //                     : choice == "SR" &&
                      //                             GlobalVar.choicecategory
                      //                                 .contains("ALL")
                      //                         ? '${stockrequestVM.tolistsrout.length} of ${stockrequestVM.tolistsrout.length} data shown'
                      //                         : '${stockrequestVM.tolistsrout.value.where((element) => element.detail != null && element.detail.any((detail) => detail.inventory_group.contains(GlobalVar.choicecategory))).toList().length} of ${stockrequestVM.tolistsrout.value.where((element) => element.detail != null && element.detail.any((detail) => detail.inventory_group.contains(GlobalVar.choicecategory))).toList().length} data shown',
                      //                 isBlueTxt: false,
                      //                 maxLines: 2,
                      //                 size: 16);
                      //           }),
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.end,
                      //             children: [
                      //               Icon(Icons.sort, color: Colors.black),
                      //               DropdownButton(
                      //                 dropdownColor: Colors.white,
                      //                 icon: Icon(
                      //                   Icons.arrow_drop_down,
                      //                   color: Colors.red,
                      //                 ),
                      //                 hint: TextWidget(
                      //                     isBlueTxt: false,
                      //                     text: 'Sort By ',
                      //                     size: 16.0),
                      //                 value: choice == "WO"
                      //                     ? weborderVM.sortVal.value
                      //                     : weborderVM.sortValSR.value,
                      //                 items: choice == "WO"
                      //                     ? sortList.map((value) {
                      //                         return DropdownMenuItem(
                      //                           child: TextWidget(
                      //                               text: value,
                      //                               isBlueTxt: false),
                      //                           value: value,
                      //                         );
                      //                       }).toList()
                      //                     : sortListSR.map((value) {
                      //                         return DropdownMenuItem(
                      //                           child: TextWidget(
                      //                               text: value,
                      //                               isBlueTxt: false),
                      //                           value: value,
                      //                         );
                      //                       }).toList(),
                      //                 onChanged: (value) {
                      //                   setState(() {
                      //                     choice == "WO"
                      //                         ? weborderVM.sortVal.value = value
                      //                         : weborderVM.sortValSR.value =
                      //                             value;
                      //                     if (value == "Location") {
                      //                       choice == "WO"
                      //                           ? weborderVM.tolistwoout.value
                      //                               .sort((a, b) => a.location
                      //                                   .compareTo(b.location))
                      //                           : stockrequestVM
                      //                               .tolistsrout.value
                      //                               .sort((a, b) => a.location
                      //                                   .compareTo(b.location));
                      //                     } else {
                      //                       if (choice == "WO") {
                      //                         weborderVM.tolistwoout.value.sort(
                      //                             (a, b) => a.delivery_date
                      //                                 .compareTo(
                      //                                     b.delivery_date));
                      //                       } else {
                      //                         stockrequestVM.tolistsrout.value
                      //                             .sort((a, b) =>
                      //                                 b.delivery_date.compareTo(
                      //                                     a.delivery_date));
                      //                       }
                      //                     }
                      //                   });
                      //                 },
                      //               ),
                      //             ],
                      //           )
                      //         ],
                      //       ),

                      //       // Container(
                      //       //   // outcategoryuEb (13:620)
                      //       //   width: double.infinity,
                      //       //   height: 50 * fem,
                      //       //   child: Row(
                      //       //     crossAxisAlignment: CrossAxisAlignment.center,
                      //       //     children: [
                      //       //       TextButton(
                      //       //           // stockrequestbuttongPm (I13:620;13:537)
                      //       //           onPressed: () {
                      //       //             setState(() {
                      //       //               choice = "SR";
                      //       //               weborderVM.sortVal.value = "Location";
                      //       //               // stockrequestVM.onReady();
                      //       //               stockrequestVM.tolistsrout.value =
                      //       //                   stockrequestVM
                      //       //                       .tolistsrbackup.value
                      //       //                       .where((element) => element
                      //       //                           .inventory_group
                      //       //                           .contains(GlobalVar
                      //       //                               .choicecategory))
                      //       //                       .toList();
                      //       //             });
                      //       //           },
                      //       //           style: TextButton.styleFrom(
                      //       //             padding: EdgeInsets.zero,
                      //       //           ),
                      //       //           child: Container(
                      //       //             // weborderbuttonEGs (I13:620;13:540)
                      //       //             width: 165 * fem,
                      //       //             height: double.infinity,
                      //       //             decoration: BoxDecoration(
                      //       //               borderRadius:
                      //       //                   BorderRadius.circular(10),
                      //       //               border: Border.all(
                      //       //                   color: choice == "SR"
                      //       //                       ? Color(0xfff44236)
                      //       //                       : Color(0xffa8a8a8)),
                      //       //               color: choice == "SR"
                      //       //                   ? Color(0xfffeeceb)
                      //       //                   : Colors.white,
                      //       //             ),
                      //       //             child: Center(
                      //       //               child: Text(
                      //       //                 'Stock Request',
                      //       //                 style: SafeGoogleFont(
                      //       //                   'Roboto',
                      //       //                   fontSize: 16 * ffem,
                      //       //                   fontWeight: FontWeight.w500,
                      //       //                   height: 1.1725 * ffem / fem,
                      //       //                   color: choice == "SR"
                      //       //                       ? Color(0xfff44236)
                      //       //                       : Color(0xffa8a8a8),
                      //       //                 ),
                      //       //               ),
                      //       //             ),
                      //       //           )),
                      //       //       SizedBox(
                      //       //         width: 10,
                      //       //       ),
                      //       //       TextButton(
                      //       //         // stockrequestbuttongPm (I13:620;13:537)
                      //       //         onPressed: () {
                      //       //           setState(() {
                      //       //             choice = "WO";
                      //       //             weborderVM.sortVal.value = "Location";
                      //       //             weborderVM.onReady();
                      //       //           });
                      //       //         },
                      //       //         style: TextButton.styleFrom(
                      //       //           padding: EdgeInsets.zero,
                      //       //         ),
                      //       //         child: Container(
                      //       //           width: 165 * fem,
                      //       //           height: double.infinity,
                      //       //           decoration: BoxDecoration(
                      //       //               borderRadius:
                      //       //                   BorderRadius.circular(10),
                      //       //               border: Border.all(
                      //       //                   color: choice == "WO"
                      //       //                       ? Color(0xfff44236)
                      //       //                       : Color(0xffa8a8a8)),
                      //       //               color: choice == "WO"
                      //       //                   ? Color(0xfffeeceb)
                      //       //                   : Colors.white),
                      //       //           child: Center(
                      //       //             child: Text(
                      //       //               'WebOrder',
                      //       //               style: SafeGoogleFont(
                      //       //                 'Roboto',
                      //       //                 fontSize: 16 * ffem,
                      //       //                 fontWeight: FontWeight.w500,
                      //       //                 height: 1.1725 * ffem / fem,
                      //       //                 color: choice == "WO"
                      //       //                     ? Color(0xfff44236)
                      //       //                     : Color(0xffa8a8a8),
                      //       //               ),
                      //       //             ),
                      //       //           ),
                      //       //         ),
                      //       //       ),
                      //       //     ],
                      //       //   ),
                      //       // ),

                      //       // SizedBox(height: 8),
                      //       Padding(
                      //           child: Wrap(
                      //             children: choice == "WO"
                      //                 ? listchoiceWO
                      //                     .map((e) => ChoiceChip(
                      //                           padding: EdgeInsets.only(
                      //                               left: 15, right: 15),
                      //                           labelStyle: (Theme.of(context)
                      //                                       .backgroundColor ==
                      //                                   Colors.grey[100]
                      //                               ? (idPeriodSelected == e.id
                      //                                   ? TextStyle(
                      //                                       color: Colors.white)
                      //                                   : TextStyle(
                      //                                       color:
                      //                                           Colors.white))
                      //                               : (idPeriodSelected == e.id
                      //                                   ? TextStyle(
                      //                                       color: Colors.white)
                      //                                   : TextStyle(
                      //                                       color:
                      //                                           Colors.white))),
                      //                           backgroundColor: Theme.of(
                      //                                           context)
                      //                                       .backgroundColor ==
                      //                                   Colors.grey[100]
                      //                               ? Colors.grey
                      //                               : Colors.grey,
                      //                           label: Text(
                      //                             e.labelname,
                      //                           ),
                      //                           selected:
                      //                               idPeriodSelected == e.id,
                      //                           onSelected: (_) {
                      //                             setState(() {
                      //                               _stopSearching();
                      //                               idPeriodSelected = e.id;
                      //                               int choicechip;
                      //                               if (e.id == 10) {
                      //                                 GlobalVar.choicecategory =
                      //                                     listchoice
                      //                                         .where((element) =>
                      //                                             element
                      //                                                 .labelname ==
                      //                                             "All")
                      //                                         .toList()[0]
                      //                                         .label;
                      //                                 if (choice == "WO") {
                      //                                   weborderVM.onReady();
                      //                                 } else {
                      //                                   stockrequestVM
                      //                                       .onReady();
                      //                                 }
                      //                                 weborderVM
                      //                                         .choiceout.value =
                      //                                     listchoice
                      //                                         .where((element) =>
                      //                                             element
                      //                                                 .labelname ==
                      //                                             "All")
                      //                                         .toList()[0]
                      //                                         .label;
                      //                                 weborderVM.sortVal.value =
                      //                                     "Location";
                      //                               } else {
                      //                                 choicechip =
                      //                                     idPeriodSelected - 1;

                      //                                 GlobalVar.choicecategory =
                      //                                     listchoice[choicechip]
                      //                                         .label;
                      //                                 if (choice == "WO") {
                      //                                   weborderVM.onReady();
                      //                                 } else {
                      //                                   stockrequestVM
                      //                                       .onReady();
                      //                                 }
                      //                                 //tes
                      //                                 weborderVM
                      //                                         .choiceout.value =
                      //                                     listchoice[choicechip]
                      //                                         .label;
                      //                                 weborderVM.sortVal.value =
                      //                                     "Location";
                      //                               }
                      //                               if (choice == "WO") {
                      //                                 weborderVM.onReady();
                      //                               } else {
                      //                                 // stockrequestVM.onReady();
                      //                                 stockrequestVM.tolistsrout
                      //                                         .value =
                      //                                     stockrequestVM
                      //                                         .tolistsrbackup
                      //                                         .value
                      //                                         .where((element) => element
                      //                                             .inventory_group
                      //                                             .contains(
                      //                                                 GlobalVar
                      //                                                     .choicecategory))
                      //                                         .toList();
                      //                               }
                      //                               print(weborderVM
                      //                                   .tolistwoout.length);
                      //                             });
                      //                             // changeSelectedId('Period', e.id);
                      //                           },
                      //                           selectedColor: Theme.of(context)
                      //                                       .backgroundColor ==
                      //                                   Colors.grey[100]
                      //                               ? Colors.white
                      //                               : weborderVM.choiceout
                      //                                           .value ==
                      //                                       "FZ"
                      //                                   ? Colors.blue
                      //                                   : weborderVM.choiceout
                      //                                               .value ==
                      //                                           "CH"
                      //                                       ? Colors.green
                      //                                       : weborderVM.choiceout
                      //                                                   .value ==
                      //                                               "ALL"
                      //                                           ? Colors.orange
                      //                                           : Color(
                      //                                               0xfff44236),
                      //                           elevation: 10,
                      //                         ))
                      //                     .toList()
                      //                 : listchoice
                      //                     .map((e) => ChoiceChip(
                      //                           padding: EdgeInsets.only(
                      //                               left: 10, right: 10),
                      //                           labelStyle: (Theme.of(context)
                      //                                       .backgroundColor ==
                      //                                   Colors.grey[100]
                      //                               ? (idPeriodSelected == e.id
                      //                                   ? TextStyle(
                      //                                       color: Colors.white)
                      //                                   : TextStyle(
                      //                                       color:
                      //                                           Colors.white))
                      //                               : (idPeriodSelected == e.id
                      //                                   ? TextStyle(
                      //                                       color: Colors.white)
                      //                                   : TextStyle(
                      //                                       color:
                      //                                           Colors.white))),
                      //                           backgroundColor: Theme.of(
                      //                                           context)
                      //                                       .backgroundColor ==
                      //                                   Colors.grey[100]
                      //                               ? Colors.grey
                      //                               : Colors.grey,
                      //                           label: Text(
                      //                             e.labelname,
                      //                           ),
                      //                           selected:
                      //                               idPeriodSelected == e.id,
                      //                           onSelected: (_) {
                      //                             setState(() {
                      //                               _stopSearching();
                      //                               idPeriodSelected = e.id;
                      //                               int choicechip;
                      //                               if (e.id == 10) {
                      //                                 GlobalVar.choicecategory =
                      //                                     listchoice
                      //                                         .where((element) =>
                      //                                             element
                      //                                                 .labelname ==
                      //                                             "All")
                      //                                         .toList()[0]
                      //                                         .label;
                      //                                 if (choice == "WO") {
                      //                                   weborderVM.onReady();
                      //                                 } else {
                      //                                   stockrequestVM
                      //                                       .onReady();
                      //                                 }
                      //                                 weborderVM
                      //                                         .choiceout.value =
                      //                                     listchoice
                      //                                         .where((element) =>
                      //                                             element
                      //                                                 .labelname ==
                      //                                             "All")
                      //                                         .toList()[0]
                      //                                         .label;
                      //                                 weborderVM.sortVal.value =
                      //                                     "Location";
                      //                               } else {
                      //                                 choicechip =
                      //                                     idPeriodSelected - 1;

                      //                                 GlobalVar.choicecategory =
                      //                                     listchoice[choicechip]
                      //                                         .label;
                      //                                 if (choice == "WO") {
                      //                                   weborderVM.onReady();
                      //                                 } else {
                      //                                   stockrequestVM
                      //                                       .onReady();
                      //                                 }
                      //                                 weborderVM
                      //                                         .choiceout.value =
                      //                                     listchoice[choicechip]
                      //                                         .label;
                      //                                 weborderVM.sortVal.value =
                      //                                     "Location";
                      //                               }
                      //                               if (choice == "WO") {
                      //                                 weborderVM.onReady();
                      //                               } else {
                      //                                 // stockrequestVM.onReady();
                      //                                 stockrequestVM.tolistsrout
                      //                                         .value =
                      //                                     stockrequestVM
                      //                                         .tolistsrbackup
                      //                                         .value
                      //                                         .where((element) => element
                      //                                             .inventory_group
                      //                                             .contains(
                      //                                                 GlobalVar
                      //                                                     .choicecategory))
                      //                                         .toList();
                      //                               }
                      //                             });
                      //                             // changeSelectedId('Period', e.id);
                      //                           },
                      //                           selectedColor: Theme.of(context)
                      //                                       .backgroundColor ==
                      //                                   Colors.grey[100]
                      //                               ? Colors.white
                      //                               : weborderVM.choiceout
                      //                                           .value ==
                      //                                       "FZ"
                      //                                   ? Colors.blue
                      //                                   : weborderVM.choiceout
                      //                                               .value ==
                      //                                           "CH"
                      //                                       ? Colors.green
                      //                                       : weborderVM.choiceout
                      //                                                   .value ==
                      //                                               "ALL"
                      //                                           ? Colors.orange
                      //                                           : Color(
                      //                                               0xfff44236),
                      //                           elevation: 10,
                      //                         ))
                      //                     .toList(),
                      //             spacing: 10,
                      //           ),
                      //           padding: EdgeInsets.only(bottom: 10)),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                          child: Wrap(
                            children: choice == "WO"
                                ? listchoiceWO
                                    .map((e) => ChoiceChip(
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15),
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
                                              _stopSearching();
                                              idPeriodSelected = e.id;
                                              int choicechip;
                                              if (e.id == 10) {
                                                GlobalVar.choicecategory =
                                                    listchoice
                                                        .where((element) =>
                                                            element.labelname ==
                                                            "All")
                                                        .toList()[0]
                                                        .label;
                                                if (choice == "WO") {
                                                  weborderVM.onReady();
                                                } else {
                                                  stockrequestVM.onReady();
                                                }
                                                weborderVM.choiceout.value =
                                                    listchoice
                                                        .where((element) =>
                                                            element.labelname ==
                                                            "All")
                                                        .toList()[0]
                                                        .label;
                                                weborderVM.sortVal.value =
                                                    "Location";
                                              } else {
                                                choicechip =
                                                    idPeriodSelected - 1;

                                                GlobalVar.choicecategory =
                                                    listchoice[choicechip]
                                                        .label;
                                                if (choice == "WO") {
                                                  weborderVM.onReady();
                                                } else {
                                                  stockrequestVM.onReady();
                                                }
                                                //tes
                                                weborderVM.choiceout.value =
                                                    listchoice[choicechip]
                                                        .label;
                                                weborderVM.sortVal.value =
                                                    "Location";
                                              }
                                              if (choice == "WO") {
                                                weborderVM.onReady();
                                              } else {
                                                // stockrequestVM.onReady();
                                                stockrequestVM
                                                        .tolistsrout.value =
                                                    stockrequestVM
                                                        .tolistsrbackup.value
                                                        .where((element) => element
                                                            .inventory_group
                                                            .contains(GlobalVar
                                                                .choicecategory))
                                                        .toList();
                                              }
                                              // print(weborderVM
                                              //     .tolistwoout.length);
                                            });
                                            // changeSelectedId('Period', e.id);
                                          },
                                          selectedColor: Theme.of(context)
                                                      .backgroundColor ==
                                                  Colors.grey[100]
                                              ? Colors.white
                                              : weborderVM.choiceout.value ==
                                                      "FZ"
                                                  ? Colors.blue
                                                  : weborderVM.choiceout
                                                              .value ==
                                                          "CH"
                                                      ? Colors.green
                                                      : weborderVM.choiceout
                                                                  .value ==
                                                              "ALL"
                                                          ? Colors.orange
                                                          : Color(0xfff44236),
                                          elevation: 10,
                                        ))
                                    .toList()
                                : listchoice
                                    .map((e) => ChoiceChip(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10),
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
                                              _stopSearching();
                                              idPeriodSelected = e.id;
                                              int choicechip;
                                              if (e.id == 10) {
                                                GlobalVar.choicecategory =
                                                    listchoice
                                                        .where((element) =>
                                                            element.labelname ==
                                                            "All")
                                                        .toList()[0]
                                                        .label;
                                                if (choice == "WO") {
                                                  weborderVM.onReady();
                                                } else {
                                                  stockrequestVM.onReady();
                                                }
                                                weborderVM.choiceout.value =
                                                    listchoice
                                                        .where((element) =>
                                                            element.labelname ==
                                                            "All")
                                                        .toList()[0]
                                                        .label;
                                                weborderVM.sortVal.value =
                                                    "Location";
                                              } else {
                                                choicechip =
                                                    idPeriodSelected - 1;

                                                GlobalVar.choicecategory =
                                                    listchoice[choicechip]
                                                        .label;
                                                if (choice == "WO") {
                                                  weborderVM.onReady();
                                                } else {
                                                  stockrequestVM.onReady();
                                                }
                                                weborderVM.choiceout.value =
                                                    listchoice[choicechip]
                                                        .label;
                                                weborderVM.sortVal.value =
                                                    "Location";
                                              }
                                              if (choice == "WO") {
                                                weborderVM.onReady();
                                              } else {
                                                // stockrequestVM.onReady();
                                                stockrequestVM
                                                        .tolistsrout.value =
                                                    stockrequestVM
                                                        .tolistsrbackup.value
                                                        .where((element) => element
                                                            .inventory_group
                                                            .contains(GlobalVar
                                                                .choicecategory))
                                                        .toList();
                                              }
                                            });
                                            // changeSelectedId('Period', e.id);
                                          },
                                          selectedColor: Theme.of(context)
                                                      .backgroundColor ==
                                                  Colors.grey[100]
                                              ? Colors.white
                                              : weborderVM.choiceout.value ==
                                                      "FZ"
                                                  ? Colors.blue
                                                  : weborderVM.choiceout
                                                              .value ==
                                                          "CH"
                                                      ? Colors.green
                                                      : weborderVM.choiceout
                                                                  .value ==
                                                              "ALL"
                                                          ? Colors.orange
                                                          : Color(0xfff44236),
                                          elevation: 10,
                                        ))
                                    .toList(),
                            spacing: 10,
                          ),
                          padding: EdgeInsets.only(bottom: 10)),
                      Obx(() {
                        return Expanded(
                          child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              scrollDirection: Axis.vertical,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200.0,
                                      mainAxisSpacing: 10.0,
                                      crossAxisSpacing: 10.0,
                                      childAspectRatio: 1.5),
                              itemCount: choice == "WO"
                                  ? weborderVM.tolistwoout.length
                                  : choice == "SR" &&
                                          GlobalVar.choicecategory
                                              .contains("ALL")
                                      ? stockrequestVM.tolistsrout.length
                                      : stockrequestVM.tolistsrout.value
                                          .where((element) =>
                                              element.detail != null &&
                                              element.detail.any((detail) =>
                                                  detail.isapprove == "N" &&
                                                  detail.inventory_group
                                                      .contains(GlobalVar
                                                          .choicecategory)))
                                          .length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child: Container(
                                      key: index == 0 ? p4Key : null,
                                      // height: Get.height * 0.24,
                                      child: Center(
                                        child: OutCard(
                                            index: index,
                                            choice: choice,
                                            category: GlobalVar.choicecategory),
                                      )),
                                  onTap: () async {
                                    Get.to(OutDetailPage(
                                        index,
                                        choice,
                                        "outpage",
                                        stockrequestVM.tolistsrout.value[index]
                                            .documentno));
                                    // _clearSearchQuery();
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
