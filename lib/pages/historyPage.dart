import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:immobile/page/indetailPage.dart';
import 'package:immobile/page/outdetailPage.dart';
import 'package:immobile/page/detailstockcheckPage.dart';
import 'package:immobile/page/detailpidPage.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:immobile/model/stockcheck.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/model/outmodel.dart';
import 'package:immobile/model/history.dart';
import 'package:immobile/model/inmodel.dart';
import 'package:immobile/model/itemchoicemodel.dart' as model;
import 'package:immobile/viewmodel/invm.dart';
import 'package:immobile/viewmodel/stockrequestvm.dart';
import 'package:immobile/viewmodel/pidvm.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/stockcheckvm.dart';
import 'package:immobile/viewmodel/historyvm.dart';
import 'package:get/get.dart';
import 'package:immobile/config/database.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);
  @override
  _HistoryPage createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  int idPeriodSelected = 1;
  List<model.ItemChoice> listchoice = [];
  List<Category> listcategory = [];
  InVM inVM = Get.find();
  StockCheckVM stockcheckVM = Get.find();
  PidVM pidVM = Get.find();
  StockrequestVM stockrequestVM = Get.find();
  GlobalVM globalVM = Get.find();
  HistoryVM historyVM = Get.find();
  GlobalKey p4Key = GlobalKey();
  GlobalKey srKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name;
  ScrollController controller;
  // List<dynamic> mylist = [];

  @override
  void initState() {
    super.initState();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // getname();
    historyVM.choicedate.value = today;
    historyVM.onReady();

    // mylist = [];
    // foraddlist();

    // getchoicechip();
    // getName();
    // _initPackageInfo();
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
                historyVM.choicedate.value =
                    DateFormat('yyyy-MM-dd').format(newDate);
                historyVM.onReady();
              });
            },
          ),
        ],
      )
    ];
  }

  // void foraddlist() async {
  //   var username = await DatabaseHelper.db.getUser();
  //   var listinbyusername = inVM.tolistPOapprove.value;
  //   var listsrbyusername = stockrequestVM.tolistsrapprove;
  //   var liststockcheckbyusername = stockcheckVM.toliststockhistory;
  //   // print(listsrbyusername);
  //   for (int i = 0; i < listinbyusername.length; i++) {
  //     mylist.add(listinbyusername[i]);
  //   }
  //   for (int i = 0; i < listsrbyusername.length; i++) {
  //     mylist.add(listsrbyusername[i]);
  //   }
  //   for (int i = 0; i < liststockcheckbyusername.length; i++) {
  //     mylist.add(liststockcheckbyusername[i]);
  //   }
  //   mylist.sort((a, b) =>
  //       b.getApprovedat(username).compareTo(a.getApprovedat(username)));
  //   print(mylist);
  // }
  Widget headerCard2(HistoryModel list) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      // padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 20 * fem),
      width: double.infinity,
      // decoration: BoxDecoration(
      //   color: Color(0xffffffff),
      //   borderRadius: BorderRadius.circular(8 * fem),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Color(0x3f000000),
      //       offset: Offset(0 * fem, 4 * fem),
      //       blurRadius: 5 * fem,
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 2,
          ),
          Container(
            // autogroupqe3auJY (Xy3E1KY1gvhpbMNvhZQE3A)
            // margin: EdgeInsets.fromLTRB(
            //     0 * fem, 0 * fem, 12 * fem, 13.34 * fem),
            width: 200 * fem,
            height: 35 * fem,
            decoration: BoxDecoration(
              color: list.doctype == "stockcheck"
                  ? Colors.blue
                  : list.doctype == "PID"
                      ? Colors.black
                      : list.doctype == "SR"
                          ? Colors.green
                          : Color(0xfff44236),
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.circular(8 * fem),
              //   bottomRight: Radius.circular(8 * fem),
              // ),
            ),
            child: Center(
              child: Text(
                list.doctype == "IN"
                    ? list.doctype + " - " + list.ebeln
                    : list.doctype == "stockcheck" || list.doctype == "PID"
                        ? list.doctype.toUpperCase() + " - " + list.recordid
                        : list.doctype + " - " + list.documentno,
                style: SafeGoogleFont(
                  'Roboto',
                  fontSize: 14 * ffem,
                  fontWeight: FontWeight.w600,
                  height: 1.1725 * ffem / fem,
                  color: Color(0xffffffff),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // vendor1000000crownpacificinves (11:443)
                margin:
                    EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
                child: Text(
                  'Approved By      :   ${list.updatedby}',
                  style: SafeGoogleFont(
                    'Roboto',
                    fontSize: 14 * ffem,
                    // fontWeight: FontWeight.w600,
                    height: 1.1725 * ffem / fem,
                    // color: Color(0xff2d2d2d),
                  ),
                ),
              ),
              Container(
                // vendor1000000crownpacificinves (11:443)
                padding: EdgeInsets.only(right: 10),
                child: Image.asset(
                  'data/images/vector-1HV.png',
                  width: 11 * fem,
                  height: 30 * fem,
                ),
              )
            ],
          ),
          Container(
            // vendor1000000crownpacificinves (11:443)
            margin: EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
            child: Text(
              list is StockModel
                  ? 'Approved Date  :   ${globalVM.stringToDateWithTime(list.updated_at)}'
                  : 'Approved Date  :   ${globalVM.stringToDateWithTime(list.updated)}',
              style: SafeGoogleFont(
                'Roboto',
                fontSize: 14 * ffem,
                // fontWeight: FontWeight.w600,
                height: 1.1725 * ffem / fem,
                // color: Color(0xff2d2d2d),
              ),
            ),
          ),

          Visibility(
            visible: list.mblnr != "" && list.mblnr != null,
            child: Container(
              // vendor1000000crownpacificinves (11:443)
              margin: EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
              child: Text(
                list is StockModel
                    ? 'Doc No               :   ${list.mblnr}'
                    : 'Doc No               :   ${list.mblnr}',
                style: SafeGoogleFont(
                  'Roboto',
                  fontSize: 14 * ffem,
                  // fontWeight: FontWeight.w600,
                  height: 1.1725 * ffem / fem,
                  // color: Color(0xff2d2d2d),
                ),
              ),
            ),
          ),

          // Add a line at the bottom of the column
          Container(
            height: 1, // Adjust the height of the line as needed
            color: Colors.grey, // You can change the color of the line
            margin:
                EdgeInsets.only(top: 20 * fem), // Adjust the margin as needed
          ),
        ],
      ),
    );
  }

  // Widget headerCard2(HistoryModel list) {
  //   double baseWidth = 360;
  //   double fem = MediaQuery.of(context).size.width / baseWidth;
  //   double ffem = fem * 0.97;
  //   return Container(
  //       // poambienteLg (11:470)
  //       margin: EdgeInsets.fromLTRB(5 * fem, 0 * fem, 10 * fem, 10 * fem),
  //       width: double.infinity,
  //       child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
  //         Container(
  //           padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 20 * fem),
  //           width: double.infinity,
  //           decoration: BoxDecoration(
  //             color: Color(0xffffffff),
  //             borderRadius: BorderRadius.circular(8 * fem),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Color(0x3f000000),
  //                 offset: Offset(0 * fem, 4 * fem),
  //                 blurRadius: 5 * fem,
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(
  //                 height: 20,
  //               ),
  //               Container(
  //                 // autogroupqe3auJY (Xy3E1KY1gvhpbMNvhZQE3A)
  //                 // margin: EdgeInsets.fromLTRB(
  //                 //     0 * fem, 0 * fem, 12 * fem, 13.34 * fem),
  //                 width: 200 * fem,
  //                 height: 50 * fem,
  //                 decoration: BoxDecoration(
  //                   color: list.doctype == "stockcheck"
  //                       ? Colors.blue
  //                       : list.doctype == "PID"
  //                           ? Colors.black
  //                           : list.doctype == "SR"
  //                               ? Colors.green
  //                               : Color(0xfff44236),
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(8 * fem),
  //                     bottomRight: Radius.circular(8 * fem),
  //                   ),
  //                 ),
  //                 child: Center(
  //                   child: Text(
  //                     list.doctype == "IN"
  //                         ? list.doctype + " - " + list.ebeln
  //                         : list.doctype == "stockcheck" ||
  //                                 list.doctype == "PID"
  //                             ? list.doctype.toUpperCase() +
  //                                 " - " +
  //                                 list.recordid
  //                             : list.doctype + " - " + list.documentno,
  //                     style: SafeGoogleFont(
  //                       'Roboto',
  //                       fontSize: 16 * ffem,
  //                       fontWeight: FontWeight.w600,
  //                       height: 1.1725 * ffem / fem,
  //                       color: Color(0xffffffff),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Container(
  //                     // vendor1000000crownpacificinves (11:443)
  //                     margin: EdgeInsets.fromLTRB(
  //                         12 * fem, 0 * fem, 0 * fem, 0 * fem),
  //                     child: Text(
  //                       'Approved By:   ${list.updatedby}',
  //                       style: SafeGoogleFont(
  //                         'Roboto',
  //                         fontSize: 16 * ffem,
  //                         fontWeight: FontWeight.w600,
  //                         height: 1.1725 * ffem / fem,
  //                         color: Color(0xff2d2d2d),
  //                       ),
  //                     ),
  //                   ),
  //                   Container(
  //                     // vendor1000000crownpacificinves (11:443)
  //                     padding: EdgeInsets.only(right: 10),
  //                     child: Image.asset(
  //                       'data/images/vector-1HV.png',
  //                       width: 11 * fem,
  //                       height: 30 * fem,
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               Container(
  //                 // vendor1000000crownpacificinves (11:443)
  //                 margin:
  //                     EdgeInsets.fromLTRB(12 * fem, 0 * fem, 0 * fem, 0 * fem),
  //                 child: Text(
  //                   list is StockModel
  //                       ? 'Approved Date:   ${globalVM.stringToDateWithTime(list.updated_at)}'
  //                       : 'Approved Date:   ${globalVM.stringToDateWithTime(list.updated)}',
  //                   style: SafeGoogleFont(
  //                     'Roboto',
  //                     fontSize: 16 * ffem,
  //                     fontWeight: FontWeight.w600,
  //                     height: 1.1725 * ffem / fem,
  //                     color: Color(0xff2d2d2d),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ]));
  // }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                // actions: _buildActions(),
                automaticallyImplyLeading: false,

                // leading: IconButton(
                //   onPressed: () {
                //     Get.back();
                //   },
                //   icon: Icon(Icons.arrow_back, color: kWhiteColor),
                // ),

                backgroundColor: Colors.red,

                // leading: _isSearching ? const BackButton() : null,
                title: Container(
                    child: TextWidget(
                        text: "History",
                        isBlueTxt: false,
                        maxLines: 2,
                        size: 20,
                        color: Colors.white)),
                actions: _buildActions(),
                centerTitle: true),
            // backgroundColor: Colors.white,
            body: Container(
                // historypageUMn (11:212)
                // width: double.infinity,
                // // height: GlobalVar.height * 5,
                // decoration: BoxDecoration(
                //   color: Color(0xffffffff),
                // ),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Obx(() {
                    historyVM.tolisthistory
                        .sort((a, b) => b.updated.compareTo(a.updated));
                    return historyVM.tolisthistory.length == 0
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
                        : Expanded(
                            child: ListView.builder(
                                controller: controller,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                // gridDelegate:
                                //     SliverGridDelegateWithFixedCrossAxisCount(
                                //         crossAxisCount: 1),
                                itemCount: historyVM.tolisthistory.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: headerCard2(
                                        historyVM.tolisthistory.value[index]),
                                    onTap: () async {
                                      if (historyVM.tolisthistory.value[index]
                                              .doctype ==
                                          "IN") {
                                        InModel inmodel = InModel(
                                            T_DATA: historyVM.tolisthistory
                                                .value[index].T_DATA,
                                            aedat: historyVM.tolisthistory
                                                .value[index].aedat,
                                            approvedate: historyVM.tolisthistory
                                                .value[index].approvedate,
                                            bwart: historyVM.tolisthistory
                                                .value[index].bwart,
                                            clientid: historyVM.tolisthistory
                                                .value[index].clientid,
                                            created: historyVM.tolisthistory
                                                .value[index].created,
                                            createdby: historyVM.tolisthistory
                                                .value[index].createdby,
                                            dlv_comp: historyVM.tolisthistory
                                                .value[index].dlv_comp,
                                            doctype: historyVM.tolisthistory
                                                .value[index].doctype,
                                            ebeln: historyVM.tolisthistory
                                                .value[index].ebeln,
                                            ernam: historyVM.tolisthistory
                                                .value[index].ernam,
                                            group: historyVM.tolisthistory
                                                .value[index].group,
                                            issync: historyVM.tolisthistory
                                                .value[index].issync,
                                            lgort: historyVM.tolisthistory
                                                .value[index].lgort,
                                            lifnr: historyVM.tolisthistory
                                                .value[index].lifnr,
                                            mblnr:
                                                historyVM.tolisthistory.value[index].mblnr,
                                            orgid: historyVM.tolisthistory.value[index].orgid,
                                            truck: historyVM.tolisthistory.value[index].truck,
                                            updated: historyVM.tolisthistory.value[index].updated,
                                            updatedby: historyVM.tolisthistory.value[index].updatedby,
                                            werks: historyVM.tolisthistory.value[index].werks);
                                        inVM.tolistPO.clear();
                                        inVM.tolistPO.assign(inmodel);
                                        Get.to(
                                            InDetailPage(0, "history", null));
                                      } else if (historyVM.tolisthistory
                                              .value[index].doctype ==
                                          "SR") {
                                        OutModel outmodel = OutModel(
                                            postingdate: historyVM
                                                        .tolisthistory
                                                        .value[index]
                                                        .postingdate ==
                                                    null
                                                ? "20231017"
                                                : historyVM.tolisthistory
                                                    .value[index].postingdate,
                                            clientid: historyVM.tolisthistory
                                                .value[index].clientid,
                                            created: historyVM.tolisthistory
                                                .value[index].created,
                                            createdat: historyVM.tolisthistory
                                                .value[index].createdat,
                                            createdby: historyVM.tolisthistory
                                                .value[index].createdby,
                                            delivery_date: historyVM
                                                .tolisthistory
                                                .value[index]
                                                .delivery_date,
                                            detail: historyVM.tolisthistory
                                                .value[index].detail,
                                            detaildouble: historyVM
                                                .tolisthistory
                                                .value[index]
                                                .detaildouble,
                                            doctype: historyVM.tolisthistory.value[index].doctype,
                                            documentno: historyVM.tolisthistory.value[index].documentno,
                                            inventory_group: historyVM.tolisthistory.value[index].inventory_group,
                                            item: historyVM.tolisthistory.value[index].item,
                                            location: historyVM.tolisthistory.value[index].location,
                                            location_name: historyVM.tolisthistory.value[index].location_name,
                                            orgid: historyVM.tolisthistory.value[index].orgid,
                                            recordid: historyVM.tolisthistory.value[index].recordid,
                                            total_item: historyVM.tolisthistory.value[index].total_item,
                                            totalquantity: historyVM.tolisthistory.value[index].totalquantity,
                                            updated: historyVM.tolisthistory.value[index].updated,
                                            updatedby: historyVM.tolisthistory.value[index].updatedby,
                                            matdoc: historyVM.tolisthistory.value[index].mblnr);
                                        stockrequestVM.tolistsrout.clear();
                                        stockrequestVM.tolistsrout
                                            .assign(outmodel);
                                        Get.to(OutDetailPage(
                                            0,
                                            "SR",
                                            "history",
                                            stockrequestVM.tolistsrout.value[0]
                                                .documentno));
                                      } else if (historyVM.tolisthistory
                                              .value[index].doctype ==
                                          "PID") {
                                        StockModel stockmodel = StockModel(
                                            clientid: historyVM.tolisthistory
                                                .value[index].clientid,
                                            color: historyVM.tolisthistory
                                                .value[index].color,
                                            created: historyVM.tolisthistory
                                                .value[index].created,
                                            createdby: historyVM.tolisthistory
                                                .value[index].createdby,
                                            detail: historyVM.tolisthistory
                                                .value[index].detailstockcheck,
                                            doctype: historyVM.tolisthistory
                                                .value[index].doctype,
                                            formatted_updated_at: historyVM
                                                .tolisthistory
                                                .value[index]
                                                .formatted_updated_at,
                                            isapprove: historyVM.tolisthistory
                                                .value[index].isapprove,
                                            issync: historyVM.tolisthistory
                                                .value[index].issync,
                                            location: historyVM.tolisthistory
                                                .value[index].location,
                                            location_name: historyVM
                                                .tolisthistory
                                                .value[index]
                                                .location_name,
                                            orgid: historyVM.tolisthistory
                                                .value[index].orgid,
                                            recordid: historyVM.tolisthistory
                                                .value[index].recordid,
                                            updated: historyVM.tolisthistory
                                                .value[index].updated,
                                            updated_at: historyVM.tolisthistory
                                                .value[index].updated_at,
                                            updatedby:
                                                historyVM.tolisthistory.value[index].updatedby);
                                        pidVM.tolistpid.clear();
                                        pidVM.tolistpid.assign(stockmodel);
                                        Get.to(DetailPidPage(0, "history"));
                                      } else {
                                        StockModel stockmodel = StockModel(
                                            clientid: historyVM.tolisthistory
                                                .value[index].clientid,
                                            color: historyVM.tolisthistory
                                                .value[index].color,
                                            created: historyVM.tolisthistory
                                                .value[index].created,
                                            createdby: historyVM.tolisthistory
                                                .value[index].createdby,
                                            detail: historyVM.tolisthistory
                                                .value[index].detailstockcheck,
                                            doctype: historyVM.tolisthistory
                                                .value[index].doctype,
                                            formatted_updated_at: historyVM
                                                .tolisthistory
                                                .value[index]
                                                .formatted_updated_at,
                                            isapprove: historyVM.tolisthistory
                                                .value[index].isapprove,
                                            issync: historyVM.tolisthistory
                                                .value[index].issync,
                                            location: historyVM.tolisthistory
                                                .value[index].location,
                                            location_name: historyVM
                                                .tolisthistory
                                                .value[index]
                                                .location_name,
                                            orgid: historyVM.tolisthistory
                                                .value[index].orgid,
                                            recordid: historyVM.tolisthistory
                                                .value[index].recordid,
                                            updated: historyVM.tolisthistory
                                                .value[index].updated,
                                            updated_at: historyVM.tolisthistory
                                                .value[index].updated_at,
                                            updatedby:
                                                historyVM.tolisthistory.value[index].updatedby);
                                        stockcheckVM.toliststock.clear();
                                        stockcheckVM.toliststock
                                            .assign(stockmodel);
                                        Get.to(
                                            DetailStockCheckPage(0, "history"));
                                      }
                                    },
                                  );
                                  // dynamic item = mylist[index];
                                  // if (item is HistoryModel) {
                                  //   // Handle Model1 item
                                  //   return GestureDetector(
                                  //     child: headerCard2(item, "stock"),
                                  //     onTap: () async {},
                                  //   );
                                  // } else if (item is OutModel) {
                                  //   // Handle Model2 item
                                  //   return GestureDetector(
                                  //     child: headerCard2(item, "out"),
                                  //     onTap: () async {},
                                  //   );
                                  // } else if (item is InModel) {
                                  //   return GestureDetector(
                                  //     child: headerCard2(item, "in"),
                                  //     onTap: () async {},
                                  //   );
                                  // }

                                  // if (mylist.runtimeType == OutModel) {
                                  //   OutModel model1 = mylist as OutModel;
                                  //   // Access properties of Model1
                                  //   String name = model1.doctype;
                                  //   return GestureDetector(
                                  //     child: headerCard2(mylist[index], index),
                                  //     onTap: () async {},
                                  //   );
                                  //   // Do something with the data
                                  // } else if (mylist.runtimeType == StockModel) {
                                  //   StockModel model2 = mylist as StockModel;
                                  //   // Access properties of Model2
                                  //   // String title = model2.title;
                                  //   return GestureDetector(
                                  //     child: headerCard2(mylist[index], index),
                                  //     onTap: () async {},
                                  //   );
                                  //   // Do something with the data
                                  // } else if (mylist.runtimeType == InModel) {
                                  //   InModel model3 = mylist as InModel;
                                  //   // Access properties of Model3
                                  //   // int value = model3.value;
                                  //   return GestureDetector(
                                  //     child: headerCard2(mylist[index], index),
                                  //     onTap: () async {},
                                  //   );
                                  //   // Do something with the data
                                  // }
                                }),
                          );
                  })
                ]))));
  }
}
