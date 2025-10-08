import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immobile/model/stocktake.dart';
import 'package:immobile/model/stocktakedetail.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:immobile/viewmodel/stocktickvm.dart';
import 'package:immobile/widget/text.dart';

class CountedPage extends StatefulWidget {
  final int index;

  const CountedPage(this.index, {Key key}) : super(key: key);

  @override
  _CountedPageState createState() => _CountedPageState();
}

class _CountedPageState extends State<CountedPage> {
  GlobalVM globalvm = Get.find();
  StockTickVM stocktickvm = Get.find();
  String dropdownValue = 'All';
  TextEditingController _searchQuery;
  String searchQuery, barcodeScanRes;
  bool _isSearching = false;

    @override
  void initState() {
        _searchQuery = new TextEditingController();
     stocktickvm.tolistinput.value = stocktickvm.tolistcounted.value.where((element) => element.createdby == globalvm.username.value).toList();
   print(stocktickvm.tolistinput.value );
  }

   void _startSearch() {
    setState(() {
      // if (widget.from == "sync") {
      //   listindetaillocal.clear();
      //   var locallist = widget.flag.T_DATA;
      //   for (var i = 0; i < locallist.length; i++) {
      //     listindetaillocal.add(locallist[i]);
      //   }
      //   _isSearching = true;
      // } else {
      // detaillocal.clear();
      // var locallist =
      //     stocktickvm.tolistdocumentnosame.value[widget.index].detail;
      // for (var i = 0; i < locallist.length; i++) {
      //   detaillocal.add(locallist[i]);
      // }
      _isSearching = true;
      // }
    });
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
      if(dropdownValue == "All"){
 var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
    parseumren = (calcu[j].count_box * umrez);
      // calcu[j].count_box
      //print(widget.controllers[i].text);
      total += parseumren += calcu[j].count_bun;
    }
      } else {
         var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR && element.selectedChoice == dropdownValue)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH != "KG" && element.MEINH != "PAK").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
    parseumren = (calcu[j].count_box * umrez);
      // calcu[j].count_box
      //print(widget.controllers[i].text);
      total += parseumren += calcu[j].count_bun;
    }
      }

    } else {
       if(dropdownValue == "All"){
        var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH == "KG").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
    parseumren = (calcu[j].count_box * umrez);
      // calcu[j].count_box
      //print(widget.controllers[i].text);
      total += parseumren += calcu[j].count_bun;
    }
       } else {
var calcu = stocktickvm.tolistforinputstocktake
        .where((element) => element.matnr == item.MATNR && element.selectedChoice == dropdownValue)
        .toList();
    for (var j = 0; j < calcu.length; j++) {
    var listumrez = item.MARM.where((element) => element.MEINH == "KG").toList();
    if(listumrez.length != 0){
    stringumrez = listumrez[0].UMREZ;
      umrez = double.parse(stringumrez);
    }
    parseumren = (calcu[j].count_box * umrez);
      // calcu[j].count_box
      //print(widget.controllers[i].text);
      total += parseumren += calcu[j].count_bun;
    }
       }
 
    }
   
    String totalstring = total.toString();
    return totalstring;
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

   String extractSize(String name) {
    List<String> parts = name.split(' ');
    return parts.isNotEmpty ? parts.last : '';
  }

  void _clearSearchQuery() {
    setState(() {
      _isSearching = false;
      _searchQuery.clear();
      _isSearching = false;
      // detaillocal.clear();
      stocktickvm.searchValue.value = '';
      // stocktickvm.tolistdocumentnosame.value.singleWhere((element) => element.documentno == widget.documentno).detail.clear();

      // for (var item in detaillocal) {
      //   stocktickvm.tolistdocumentnosame.value
      //       .singleWhere((element) => element.documentno == widget.documentno)
      //       .detail
      //       .add(item);
      // }

      // Get.to(InDetailPage(index));
    });
  }
    void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
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
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: Colors.red,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items: <String>['All', 'UU', 'QI','BLOCK'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        ],
      )
    ];
  }

  String calculateNo(int index){
   var indexing =  index + 1;
   return indexing.toString();
  }



   String _CalculTotalStockPCS(StockTakeDetailModel item, String flag) {
    if (flag == "stock") {
      int total = 0;
      var calcu = stocktickvm.tolistdocument[widget.index].detail
          .where((element) => element.MATNR == item.MATNR)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].INSME.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    } else {
      if(dropdownValue == "All"){
   int total = 0;
      var calcu = stocktickvm.tolistforinputstocktake
          .where((element) => element.matnr == item.MATNR && element.createdby == globalvm.username.value)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].count_bun.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
      } else {
   int total = 0;
      var calcu = stocktickvm.tolistforinputstocktake
          .where((element) => element.matnr == item.MATNR && element.createdby == globalvm.username.value && element.selectedChoice == dropdownValue)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].count_bun.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
      }
   
    }
  }

  String _CalculTotalStockCTN(StockTakeDetailModel item, String flag) {
    if (flag == "stock") {
      int total = 0;
      var calcu = stocktickvm.tolistdocument[widget.index].detail
          .where((element) => element.MATNR == item.MATNR)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].INSME.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    } else {
      int total = 0;
      var calcu = stocktickvm.tolistforinputstocktake
          .where((element) => element.matnr == item.MATNR && element.createdby == globalvm.username.value)
          .toList();
      for (var j = 0; j < calcu.length; j++) {
        //print(widget.controllers[i].text);
        total += calcu[j].count_box.toInt();
      }
      String totalstring = total.toString();
      return totalstring;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        // Leading places the arrow at the far left
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
       title: Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: _isSearching
                          ? _buildSearchField()
                          : Container(
                              child: TextWidget(
                                  text: "Counted",
                                  isBlueTxt: false,
                                  maxLines: 2,
                                  size: 18 ,
                                  color: Colors.white)),
                    ),
        actions: _buildActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-Width Grey Header Row
          Container(
            width: double.infinity, // Ensures full-width
            color: Colors.grey[300], // Light grey background
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Item',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
               
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'BUN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                 Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'BOX',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'KG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 1.0),
          // List of Items
         Expanded(
  child: Obx(() {
    // Filter the list based on dropdown value
    final filteredList = _isSearching && stocktickvm.searchValue.value == "" ? 
    []
  : _isSearching && stocktickvm.searchValue.value != "" ? 
    stocktickvm.tolistdocument.where((element) => element.documentno == stocktickvm.document.value).toList()[0].detail.where((element) => element.MAKTX.toLowerCase().contains(stocktickvm.searchValue.value.toLowerCase())
            ).toList() 
  : dropdownValue == "All"
        ? stocktickvm.tolistdocumentnosame.where((element) => element.documentno == stocktickvm.document.value).toList()[0].detail.where((element) => element.checkboxvalidation.value).toList()
        : stocktickvm.tolistdocumentnosame.where((element) => element.documentno == stocktickvm.document.value).toList()[0].detail.where((element) => element.checkboxvalidation.value).toList();

    // Sort the filtered list by name (MAKTX)
    filteredList.sort((a, b) => a.MAKTX.compareTo(b.MAKTX));
    print(filteredList);

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        calculateNo(index),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        item.MAKTX.toString(),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                    Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        (int.parse(_CalculTotalStockPCS(item, "physical")) -
                                int.parse(_CalculTotalStockPCS(item, "stock")))
                            .toString(),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
               
                Expanded(
  flex: 1,
  child: Center(
    child: Text(
      (double.parse(_CalculTotalbun(item, "Box")) == 0.0 && double.parse(_convertphysicaltobox(item, "Box")) == 0.0)
          ? '0.00'
          : (double.parse(_CalculTotalbun(item, "Box")) / double.parse(_convertphysicaltobox(item, "Box"))).toStringAsFixed(1),
      style: TextStyle(
        color: Colors.green,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),


                Expanded(
  flex: 1,
  child: Center(
    child: Text(
      double.parse(_CalculTotalbun(item,"Box")) == 0.0 && double.parse(_convertphysicaltobox(item,"Box")) == 0.0
          ? '0.0'
          : '${double.parse(_CalculTotalbun(item,"KG")) / double.parse(_convertphysicaltobox(item,"KG"))}',
      style: TextStyle(
        color: Colors.green,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
)

                  
                ],
              ),
            ),
            Divider(
              thickness: 1.0,
              height: 1.0,
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }),
),
],
      ),
    );
  }
}
