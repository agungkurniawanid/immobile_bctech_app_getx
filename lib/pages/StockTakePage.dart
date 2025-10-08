import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:immobile/widget/utils.dart';
import 'package:immobile/widget/recent.dart';
import 'package:immobile/widget/theme.dart';
import 'package:immobile/widget/outcard.dart';
import 'package:immobile/widget/text.dart';
import 'package:immobile/config/database.dart';
import 'package:immobile/config/globalvar.dart';
import 'package:immobile/model/category.dart';
import 'package:immobile/viewmodel/stocktickvm.dart';
import 'package:immobile/model/stocktake.dart';
import 'package:immobile/viewmodel/invm.dart';
import 'package:get/get.dart';
import 'package:immobile/model/itemchoicemodel.dart';
import 'package:immobile/viewmodel/webordervm.dart';
import 'package:immobile/page/StockTakeHeaderPage.dart';
import 'package:intl/intl.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockTickPage extends StatefulWidget {
  @override
  _StockTickPage createState() => _StockTickPage();
}

class _StockTickPage extends State<StockTickPage> {
  bool _allow = true;
  int idPeriodSelected = 1;
  List<String> sortList = ['Location', 'Delivery Date'];
  InVM inVM = Get.find();
  List<Category> listcategory = [];
  ScrollController controller;
  bool _leading = true;
  GlobalKey srKey = GlobalKey();
  WeborderVM weborderVM = Get.find();
  GlobalVM globalVM = Get.find();
  StockTickVM stocktickVM = Get.find();
  GlobalKey p4Key = GlobalKey();
  String choice = "SR";
  bool _isSearching = false;
  TextEditingController _searchQuery;
  String searchQuery;
  List<StocktickModel> listStocktickModel = new List<StocktickModel>();
  static const platform = const MethodChannel('zebra_scanner_channel');
  String scannedData = '';

  @override
  void initState() {
    super.initState();
    _searchQuery = new TextEditingController();
    stocktickVM.listStock();
  }

  Widget headerCard2(StocktickModel stock) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      // frame165VV (23:980)
      padding: EdgeInsets.fromLTRB(16 * fem, 11 * fem, 17 * fem, 0 * fem),
      width: double.infinity,
      child: Container(
        // frame15wGo (23:939)
        width: double.infinity,
        height: 90 * fem,
        child: Stack(
          children: [
            Positioned(
              // vansaleslistex1qCw (23:968)
              left: 0 * fem,
              top: 0 * fem,
              child: Container(
                width: 325 * fem,
                // height: 300 * fem,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // autogrouphft7zV9 (UM8QQHnJfieXqUkuTFhFt7)
                      // margin: EdgeInsets.fromLTRB(
                      //     0 * fem, 0 * fem, 0 * fem, 35 * fem),
                      padding: EdgeInsets.fromLTRB(
                          21 * fem, 23 * fem, 20 * fem, 22 * fem),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(10 * fem),
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
                            // hq3bq (23:979)
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 1 * fem, 29 * fem, 0 * fem),
                            child: Text(
                              '${stock.LGORT}',
                              textAlign: TextAlign.center,
                              style: SafeGoogleFont(
                                'Roboto',
                                fontSize: 18 * ffem,
                                fontWeight: FontWeight.w600,
                                height: 1.1725 * ffem / fem,
                                color: Color(0xfff44236),
                              ),
                            ),
                          ),
                          Container(
                            // lasttranscationtoday102556S8B (23:971)
                            // margin: EdgeInsets.fromLTRB(
                            //     0 * fem, 0 * fem, 124 * fem, 0 * fem),
                            constraints: BoxConstraints(
                              maxWidth: 200 * fem,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: SafeGoogleFont(
                                  'Roboto',
                                  fontSize: 16 * ffem,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1725 * ffem / fem,
                                  color: Color(0xff2d2d2d),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Last Transcation: \n',
                                  ),
                                  TextSpan(
                                    text: stock.updated,
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
                          ),
                          Container(
                            // onlinebuttonjwq (23:970)
                            padding: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 1 * fem),
                            width: 14 * fem,
                            height: 14 * fem,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7 * fem),
                              color: Colors.red,
                            ),
                          ),
                          Container(
                            // vectorfqS (11:444)
                            margin: EdgeInsets.fromLTRB(
                                5 * fem, 0 * fem, 0 * fem, 0 * fem),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
    stocktickVM.toliststock.value.clear();
    search = search.toUpperCase();

    var locallist2 = listStocktickModel
        .where((element) => element.LGORT.contains(search))
        .toList();

    for (var i = 0; i < locallist2.length; i++) {
      stocktickVM.toliststock.value.add(locallist2[i]);
    }
  }

  void _startSearch() {
    setState(() {
      listStocktickModel.clear();
      var locallist = stocktickVM.toliststock.value;
      for (var i = 0; i < locallist.length; i++) {
        listStocktickModel.add(locallist[i]);
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

      stocktickVM.toliststock.value.clear();

      for (var item in listStocktickModel) {
        stocktickVM.toliststock.value.add(item);
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
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
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
                                text: "Stock Take",
                                isBlueTxt: false,
                                maxLines: 2,
                                size: 20,
                                color: Colors.white)),
                    // actions: widget.listTrack != null ? null : _buildActions(),
                    centerTitle: true),
                backgroundColor: kWhiteColor,
                body: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Obx(() {
                          return Expanded(
                            child: ListView.builder(
                                controller: controller,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                // gridDelegate:
                                //     SliverGridDelegateWithFixedCrossAxisCount(
                                //         crossAxisCount: 1),
                                itemCount: stocktickVM.toliststock.value.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: headerCard2(
                                        stocktickVM.toliststock.value[index]),
                                    onTap: () async {
                                      stocktickVM.choicelocation = stocktickVM
                                          .toliststock.value[index].LGORT;
                                      Get.to(StockTakeHeader(stocktickVM
                                          .toliststock.value[index]));
                                    },
                                  );
                                }),
                          );
                        }),
                      ),
                    ],
                  ),
                ))));
  }
}
