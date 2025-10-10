import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/config/database_config.dart';
import 'package:immobile_app_fixed/config/global_variable_config.dart';
import 'package:immobile_app_fixed/constants/theme_constant.dart';
import 'package:immobile_app_fixed/models/category_model.dart';
import 'package:immobile_app_fixed/models/item_choice_model.dart';
import 'package:immobile_app_fixed/models/out_model.dart';
import 'package:immobile_app_fixed/pages/outdetailPage.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/view_models/in_view_model.dart';
import 'package:immobile_app_fixed/view_models/stock_request_view_model.dart';
import 'package:immobile_app_fixed/view_models/weborder_view_model.dart';
import 'package:immobile_app_fixed/widgets/out_card_widget.dart';
import 'package:immobile_app_fixed/widgets/text_widget.dart';

class OutPage extends StatefulWidget {
  const OutPage({super.key});

  @override
  State<OutPage> createState() => _OutPageState();
}

class _OutPageState extends State<OutPage> {
  final InVM inVM = Get.find();
  final WeborderVM _weborderVM = Get.find();
  final StockRequestVM _stockrequestVM = Get.find();
  final GlobalVM _globalVM = Get.find();

  final List<String> _sortList = ['Location', 'Delivery Date'];
  final List<String> _sortListSR = ['Request Date', 'Location'];

  final List<ItemChoice> _listChoice = [];
  final List<ItemChoice> _listChoiceWO = [];
  final List<Category> _listCategory = [];
  final List<OutModel> _listSearch = [];

  final ScrollController _controller = ScrollController();
  final GlobalKey srKey = GlobalKey();
  final GlobalKey p4Key = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  bool allow = true;
  bool leading = true;
  bool _isSearching = false;

  int _idPeriodSelected = 1;
  String choice = "SR";
  String? searchQuery;
  DateTime? date;
  String? ebeln;
  String? barcodeScanRes;

  @override
  void initState() {
    super.initState();
    _getChoiceChip();
    _stockrequestVM.onButton();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getChoiceChip() async {
    try {
      _listCategory.clear();
      _listCategory.addAll(await DatabaseHelper.db.getCategoryWithRole("OUT"));

      setState(() {
        _processCategoryList();
        _initializeDefaultValues();
        _stockrequestVM.onReady();
      });
    } catch (e) {
      debugPrint('Error in _getChoiceChip: $e');
    }
  }

  void _processCategoryList() {
    _listChoice.clear();
    _listChoiceWO.clear();

    ItemChoice? choiceForAll;

    if (_listCategory.length == 1) {
      _addChoiceItem(_listCategory.first, _listChoice);
    } else {
      for (final category in _listCategory) {
        if (category.inventoryGroupName == "All") {
          choiceForAll = ItemChoice(
            id: 10,
            label: category.inventoryGroupId,
            labelName: category.inventoryGroupName,
          );
        } else {
          _addChoiceItem(category, _listChoice);
          _addChoiceItem(category, _listChoiceWO);
        }
      }
    }

    if (choiceForAll != null) {
      _listChoice.add(choiceForAll);
    }
  }

  void _addChoiceItem(Category category, List<ItemChoice> targetList) {
    targetList.add(
      ItemChoice(
        id: targetList.length + 1,
        label: category.inventoryGroupId,
        labelName: category.inventoryGroupName,
      ),
    );
  }

  void _initializeDefaultValues() {
    if (_listChoice.isNotEmpty) {
      _weborderVM.choiceout.value = _listChoice.first.label ?? '';
      _globalVM.choicecategory.value = _listChoice.first.label ?? '';
      GlobalVar.choicecategory = _listChoice.first.label ?? '';
      _stockrequestVM.choicesr.value = _listChoice.first.label ?? '';
    }
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchController.text.isEmpty) {
              _stopSearching();
            } else {
              _clearSearchQuery();
            }
          },
        ),
      ];
    }

    return [
      Row(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _stockrequestVM.forButton,
            builder: (context, isButtonVisible, child) {
              return Visibility(
                visible: isButtonVisible,
                child: IconButton(
                  icon: const Icon(Icons.refresh_outlined),
                  onPressed: _showRefreshConfirmation,
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
    ];
  }

  void _showRefreshConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Do you want to proceed?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(onPressed: _handleRefresh, child: const Text('Yes')),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    EasyLoading.show(
      status: 'Loading Get StockRequest',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final bool success = await _stockrequestVM.getStockRequest();

      if (success) {
        _stockrequestVM.onReady();
        _showToast("Success Get Document", isError: false);
      } else {
        _showToast("Document Doesn't Exist", isError: true);
      }
    } finally {
      EasyLoading.dismiss();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      _searchWorkflow(newQuery);
    });
  }

  void _searchWorkflow(String search) {
    _stockrequestVM.srOutList.clear();
    search = search.toUpperCase();

    final filteredList = _listSearch
        .where((element) => (element.recordId?.contains(search) ?? false))
        .toList();

    _stockrequestVM.srOutList.addAll(filteredList);
  }

  void _startSearch() {
    setState(() {
      _listSearch.clear();
      _listSearch.addAll(_stockrequestVM.srOutList);
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
      _searchController.clear();
      _isSearching = false;
      _stockrequestVM.srOutList
        ..clear()
        ..addAll(_listSearch);
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: _updateSearchQuery,
    );
  }

  void _handleChoiceChipSelection(ItemChoice selectedChoice) {
    setState(() {
      _stopSearching();
      _idPeriodSelected = selectedChoice.id ?? 0;

      if (selectedChoice.id == 10) {
        _handleAllCategorySelection();
      } else {
        _handleSpecificCategorySelection(selectedChoice);
      }

      _applySorting();
    });
  }

  void _handleAllCategorySelection() {
    final allChoice = _listChoice.firstWhere(
      (element) => element.labelName == "All",
    );

    GlobalVar.choicecategory = allChoice.label ?? '';
    _weborderVM.choiceout.value = allChoice.label ?? '';

    if (choice == "WO") {
      _weborderVM.onReady();
    } else {
      _stockrequestVM.onReady();
    }
  }

  void _handleSpecificCategorySelection(ItemChoice selectedChoice) {
    final choiceIndex = _idPeriodSelected - 1;

    if (choiceIndex < _listChoice.length) {
      GlobalVar.choicecategory = _listChoice[choiceIndex].label ?? '';
      _weborderVM.choiceout.value = _listChoice[choiceIndex].label ?? '';

      if (choice == "WO") {
        _weborderVM.onReady();
      } else {
        _stockrequestVM.onReady();
        _filterStockRequestsByCategory();
      }
    }
  }

  void _filterStockRequestsByCategory() {
    _stockrequestVM.srOutList.value = _stockrequestVM.srBackupList
        .where(
          (element) =>
              (element.inventoryGroup?.contains(GlobalVar.choicecategory) ??
              false),
        )
        .toList();
  }

  void _applySorting() {
    if (choice == "WO") {
      _weborderVM.sortVal.value = "Location";
      _weborderVM.tolistwoout.sort((a, b) {
        final locationA = a.location ?? '';
        final locationB = b.location ?? '';
        return locationA.compareTo(locationB);
      });
    } else {
      _weborderVM.sortValSR.value = "Request Date";
      _stockrequestVM.srOutList.sort((a, b) {
        final dateA = a.deliveryDate;
        final dateB = b.deliveryDate;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });
    }
  }

  Color _getSelectedColor() {
    if (Theme.of(context).scaffoldBackgroundColor == Colors.grey[100]) {
      return Colors.white;
    }

    switch (_weborderVM.choiceout.value) {
      case "FZ":
        return Colors.blue;
      case "CH":
        return Colors.green;
      case "ALL":
        return Colors.orange;
      default:
        return const Color(0xfff44236);
    }
  }

  Widget _buildChoiceChips() {
    final targetList = choice == "WO" ? _listChoiceWO : _listChoice;

    return Wrap(
      spacing: 10,
      children: targetList
          .map(
            (choice) => ChoiceChip(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              label: Text(choice.labelName ?? ''),
              selected: _idPeriodSelected == choice.id,
              onSelected: (_) => _handleChoiceChipSelection(choice),
              selectedColor: _getSelectedColor(),
              labelStyle: TextStyle(
                color: _idPeriodSelected == choice.id
                    ? Colors.white
                    : Colors.white,
              ),
              backgroundColor: Colors.grey,
              elevation: 10,
            ),
          )
          .toList(),
    );
  }

  int _getItemCount() {
    if (choice == "WO") {
      return _weborderVM.tolistwoout.length;
    } else if (choice == "SR" && GlobalVar.choicecategory.contains("ALL")) {
      return _stockrequestVM.srOutList.length;
    } else {
      return _stockrequestVM.srOutList
          .where(
            (element) =>
                element.detail != null &&
                element.detail!.any(
                  (detail) =>
                      detail.isApprove == "N" &&
                      (detail.inventoryGroup).contains(
                        GlobalVar.choicecategory,
                      ),
                ),
          )
          .length;
    }
  }

  String _getDataCountText() {
    if (choice == "WO") {
      return '${_weborderVM.tolistwoout.length} of ${_weborderVM.tolistwoout.length} data shown';
    } else if (choice == "SR" && GlobalVar.choicecategory.contains("ALL")) {
      return '${_stockrequestVM.srOutList.length} of ${_stockrequestVM.srOutList.length} data shown';
    } else {
      final count = _stockrequestVM.srOutList
          .where(
            (element) =>
                element.detail != null &&
                element.detail!.any(
                  (detail) =>
                      detail.isApprove == "N" &&
                      detail.inventoryGroup.contains(GlobalVar.choicecategory),
                ),
          )
          .length;
      return '$count of $count data shown';
    }
  }

  void _handleBackButton() {
    _stockrequestVM.choicesr.value = _globalVM.choicecategory.value;
    GlobalVar.choicecategory = _globalVM.choicecategory.value;
    _stockrequestVM.onReady();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: allow,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: _buildAppBarActions(),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: _handleBackButton,
            ),
            backgroundColor: Colors.red,
            title: _isSearching
                ? _buildSearchField()
                : TextWidget(
                    text: "OUT",
                    maxLines: 2,
                    fontSize: 20,
                    color: Colors.white,
                  ),
            centerTitle: true,
          ),
          backgroundColor: kWhiteColor,
          body: Container(
            padding: const EdgeInsets.only(bottom: 20, left: 5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Data count and sort dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => TextWidget(
                          text: _getDataCountText(),
                          maxLines: 2,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.sort, color: Colors.black),
                          const SizedBox(width: 4),
                          _buildSortDropdown(),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildChoiceChips(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(
                    () => GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200.0,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: _getItemCount(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          key: index == 0 ? p4Key : null,
                          child: SizedBox(
                            child: Center(
                              child: OutCard(
                                index: index,
                                choice: choice,
                                category: GlobalVar.choicecategory,
                              ),
                            ),
                          ),
                          onTap: () {
                            if (choice == "SR" &&
                                index < _stockrequestVM.srOutList.length) {
                              Get.to(
                                OutDetailPage(
                                  index,
                                  choice,
                                  "outpage",
                                  _stockrequestVM.srOutList[index].documentNo ??
                                      "",
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    final currentValue = choice == "WO"
        ? _weborderVM.sortVal.value
        : _weborderVM.sortValSR.value;

    final items = choice == "WO" ? _sortList : _sortListSR;

    return DropdownButton<String>(
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
      hint: const TextWidget(text: 'Sort By ', fontSize: 16.0),
      value: currentValue,
      items: items
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: TextWidget(text: value),
            ),
          )
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            if (choice == "WO") {
              _weborderVM.sortVal.value = newValue;
              _sortWebOrders(newValue);
            } else {
              _weborderVM.sortValSR.value = newValue;
              _sortStockRequests(newValue);
            }
          });
        }
      },
    );
  }

  void _sortWebOrders(String sortBy) {
    if (sortBy == "Location") {
      _weborderVM.tolistwoout.sort((a, b) {
        final locationA = a.location ?? '';
        final locationB = b.location ?? '';
        return locationA.compareTo(locationB);
      });
    } else {
      _weborderVM.tolistwoout.sort((a, b) {
        final dateA = a.deliveryDate;
        final dateB = b.deliveryDate;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // null terakhir
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });
    }
  }

  void _sortStockRequests(String sortBy) {
    if (sortBy == "Location") {
      _stockrequestVM.srOutList.sort((a, b) {
        final locationA = a.location ?? '';
        final locationB = b.location ?? '';
        return locationA.compareTo(locationB);
      });
    } else {
      _stockrequestVM.srOutList.sort((a, b) {
        final dateA = a.deliveryDate;
        final dateB = b.deliveryDate;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
    }
  }
}
