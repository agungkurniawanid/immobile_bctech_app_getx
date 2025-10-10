import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:immobile_app_fixed/config/database_config.dart';
import 'package:immobile_app_fixed/config/global_variable_config.dart';
import 'package:immobile_app_fixed/models/category_model.dart';
import 'package:immobile_app_fixed/models/in_model.dart';
import 'package:immobile_app_fixed/models/item_choice_model.dart';
import 'package:immobile_app_fixed/pages/in_detail_page.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';
import 'package:immobile_app_fixed/view_models/in_view_model.dart';
import 'package:immobile_app_fixed/widgets/card_widget.dart';
import 'package:immobile_app_fixed/widgets/text_widget.dart';
import 'package:shimmer/shimmer.dart';

class InPage extends StatefulWidget {
  const InPage({super.key});

  @override
  State<InPage> createState() => _InPageState();
}

class _InPageState extends State<InPage> {
  final InVM _inVM = Get.find();
  final GlobalVM _globalVM = Get.find();

  final List<String> _sortList = ['PO Date', 'Vendor'];
  final List<ItemChoice> _listChoice = [];
  final List<Category> _listCategory = [];
  final List<InModel> _listInModel = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey srKey = GlobalKey();

  bool _isSearching = false;
  bool allowPop = true;
  int _selectedChoiceId = 1;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    _initializeChoiceChips();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeChoiceChips() async {
    try {
      _listCategory.addAll(await DatabaseHelper.db.getCategoryWithRole("IN"));

      setState(() {
        for (int i = 0; i < _listCategory.length; i++) {
          if (_listCategory[i].inventoryGroupName != "Others") {
            _listChoice.add(
              ItemChoice(
                id: i + 1,
                label: _listCategory[i].inventoryGroupId,
                labelName: _listCategory[i].inventoryGroupName,
              ),
            );
          }
        }

        if (_listChoice.isNotEmpty) {
          GlobalVar.choicecategory = _listChoice.first.label ?? '';
          _inVM.choicein.value = _listChoice.first.label ?? '';
          _inVM.onReady();
        }
      });
    } catch (e) {
      debugPrint('Error initializing choice chips: $e');
    }
  }

  void _startSearch() {
    setState(() {
      _listInModel.clear();
      _listInModel.addAll(_inVM.tolistPO);
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
      searchQuery = null;
      _isSearching = false;

      if (_listCategory.isNotEmpty) {
        _inVM.onReady();
      }
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      _searchWorkflow(newQuery);
    });
  }

  void _searchWorkflow(String search) {
    try {
      final filteredList = _listInModel.where((element) {
        return (element.ebeln?.contains(search) ?? false) ||
            (element.invoiceno?.contains(search) ?? false) ||
            (element.vendorpo?.contains(search) ?? false);
      }).toList();

      _inVM.tolistPO.assignAll(filteredList);
    } catch (e) {
      debugPrint('Search error: $e');
      _inVM.tolistPO.assignAll([]);
    }
  }

  Future<void> _handleRefresh() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildSyncDialog(),
    );
  }

  Widget _buildSyncDialog() {
    final textFieldController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Sync By Document Number', style: _getTextStyle()),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: textFieldController,
              decoration: _getInputDecoration('Document Number'),
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(20.0),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _syncDocument(textFieldController.text),
          child: const Text('Yes'),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      hintStyle: const TextStyle(color: Colors.black),
    );
  }

  Future<void> _syncDocument(String documentNumber) async {
    EasyLoading.show(
      status: 'Loading Get PO',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final String check = await _inVM.getPoWithDoc(documentNumber);

      if (check != "0") {
        final List<InModel> data = await _inVM.getData(documentNumber, check);

        if (data.isNotEmpty) {
          final ItemChoice choice = _listChoice.firstWhere(
            (element) => element.label == check,
          );

          _updateSelectedChoice(choice);
          if (!mounted) return;
          Navigator.of(context).pop();

          Get.to(() => InDetailPage(0, "sync", data.first));
          _showToast("Success Get Document", isError: false);
        } else {
          _showToast("Document Doesn't Exist Or Document Cannot Release");
        }
      } else {
        _showToast("Document Doesn't Exist");
      }
    } catch (e) {
      debugPrint('Sync error: $e');
      _showToast("Error syncing document");
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _updateSelectedChoice(ItemChoice choice) {
    setState(() {
      _selectedChoiceId = choice.id ?? 0;
      GlobalVar.choicecategory = choice.label ?? '';
      _inVM.choicein.value = choice.label ?? '';
    });
  }

  void _showToast(String message, {bool isError = true}) {
    Fluttertoast.showToast(
      fontSize: 22,
      gravity: ToastGravity.TOP,
      msg: message,
      backgroundColor: Colors.red,
      textColor: isError ? Colors.white : Colors.green,
    );
  }

  void _handleChoiceSelection(ItemChoice choice) {
    setState(() {
      _selectedChoiceId = choice.id ?? 0;
      _stopSearching();

      if (_selectedChoiceId == 5) {
        // Pastikan ada elemen yang sesuai
        final allChoice = _listChoice.firstWhere(
          (element) => element.label?.contains("ALL") ?? false,
          orElse: () => _listChoice.isNotEmpty ? _listChoice[0] : choice,
        );
        GlobalVar.choicecategory = allChoice.label ?? '';

        // Gunakan index aman
        if (_listChoice.length > 3) {
          _inVM.choicein.value = _listChoice[3].labelName ?? '';
        }
      } else {
        GlobalVar.choicecategory = choice.label ?? '';
        _inVM.choicein.value = choice.label ?? '';
      }

      if (_listCategory.isNotEmpty) {
        _inVM.onReady();
      }
    });
  }

  void _handleSortChange(String? value) {
    setState(() {
      _inVM.sortVal.value = value ?? '';
      if (value == "PO Date") {
        _inVM.tolistPO.sort((a, b) {
          final aDate = a.aedat ?? '';
          final bDate = b.aedat ?? '';
          return bDate.compareTo(aDate);
        });
      } else {
        _inVM.tolistPO.sort((a, b) {
          final aLifnr = a.lifnr ?? '';
          final bLifnr = b.lifnr ?? '';
          return aLifnr.compareTo(bLifnr);
        });
      }
    });
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearchQuery),
      ];
    }

    return [
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _handleRefresh,
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
        ],
      ),
    ];
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

  Widget _buildChoiceChips() {
    return Wrap(
      spacing: 25,
      children: _listChoice.map((choice) {
        final isSelected = _selectedChoiceId == (choice.id ?? 0);
        final labelText = choice.labelName ?? '';
        final choiceInValue = _inVM.choicein.value;

        return ChoiceChip(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          label: Text(labelText),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
          backgroundColor: Colors.grey,
          selected: isSelected,
          selectedColor: _getChoiceChipColor(choiceInValue),
          elevation: 10,
          onSelected: (_) => _handleChoiceSelection(choice),
        );
      }).toList(),
    );
  }

  Color _getChoiceChipColor(String choice) {
    switch (choice) {
      case "All":
        return Colors.orange;
      case "FZ":
        return Colors.blue;
      case "CH":
        return Colors.green;
      default:
        return const Color(0xfff44236);
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          text:
              '${_inVM.tolistPO.length} of ${_inVM.tolistPO.length} data shown',
          maxLines: 2,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.sort, color: Colors.black),
              DropdownButton(
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                hint: const TextWidget(text: 'Sort By '),
                value: _inVM.sortVal.value,
                items: _sortList
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: TextWidget(text: value),
                      ),
                    )
                    .toList(),
                onChanged: _handleSortChange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_inVM.isLoading.value) {
      return _buildShimmerLoader();
    }

    if (_inVM.tolistPO.isEmpty) {
      return _buildEmptyState();
    }

    return _buildInModelList();
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.white12,
      period: const Duration(milliseconds: 1500),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CardWidget(text: '', icon: Icons.tag, height: Get.height * 0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Column(
          children: [
            Image.asset('data/images/undrawnodatarekwbl-1-1.png'),
            const TextWidget(
              text: "No Data",
              fontSize: 15,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInModelList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: _inVM.tolistPO.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => Get.to(() => InDetailPage(index, "in", null)),
          child: _buildInModelCard(_inVM.tolistPO[index]),
        ),
      ),
    );
  }

  Widget _buildInModelCard(InModel inModel) {
    final double fem = MediaQuery.of(context).size.width / 360;
    final double ffem = fem * 0.97;

    return Container(
      margin: EdgeInsets.fromLTRB(5 * fem, 0, 10 * fem, 10 * fem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 13 * fem),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8 * fem),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: Offset(0, 4 * fem),
                  blurRadius: 5 * fem,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(inModel, fem, ffem),
                _buildCardInfo(
                  'Vendor:',
                  _formatVendorText(inModel.lifnr ?? ''),
                  12 * fem,
                ),
                _buildCardInfo(
                  'Invoice No:',
                  inModel.invoiceno ?? '',
                  12 * fem,
                ),
                _buildCardInfo(
                  'Last Updated:',
                  _inVM.dateToString(inModel.created ?? '', "created") ?? '',
                  12 * fem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(InModel inModel, double fem, double ffem) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.66 * fem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 130 * fem,
            height: 38 * fem,
            margin: EdgeInsets.only(right: 12 * fem, bottom: 13.34 * fem),
            decoration: BoxDecoration(
              color: _getChoiceChipColor(_inVM.choicein.value),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8 * fem),
                bottomRight: Radius.circular(8 * fem),
              ),
            ),
            child: Center(
              child: Text(
                inModel.ebeln ?? '',
                style: _getTextStyle(
                  fontSize: 16 * ffem,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PO Date: ${_inVM.dateToString(inModel.aedat, "aedat")}',
              style: _getTextStyle(
                fontSize: 16 * ffem,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 31.94 * fem),
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
    );
  }

  Widget _buildCardInfo(String label, String value, double leftMargin) {
    return Container(
      margin: EdgeInsets.only(left: leftMargin),
      child: Text(
        '$label $value',
        style: _getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatVendorText(String vendor) {
    if (vendor.length > 42) {
      return '${vendor.substring(0, 7)}\n${vendor.substring(8, 43)}';
    }

    if (vendor.contains("Crown Pacific Investments") ||
        vendor.contains("Australian Fruit Juice")) {
      return '${vendor.substring(0, 7)}\n${vendor.substring(8)}';
    }

    return vendor;
  }

  TextStyle _getTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = const Color(0xff2d2d2d),
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.1725,
      color: color,
    );
  }

  void _handleBackPress() {
    GlobalVar.choicecategory = _globalVM.choicecategory.value;

    if (GlobalVar.choicecategory == "ALL") {
      if (_listCategory.isNotEmpty) _inVM.onRecent();
    } else {
      if (_listCategory.isNotEmpty) _inVM.onReady();
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    if (_inVM.isapprove.value) {
      _stopSearching();
      _inVM.isapprove.value = false;
      FocusScope.of(context).unfocus();
    }

    return PopScope(
      canPop: allowPop,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: _buildAppBarActions(),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20.0),
              onPressed: _handleBackPress,
            ),
            backgroundColor: Colors.red,
            title: _isSearching
                ? _buildSearchField()
                : Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: TextWidget(
                      text: "GR In Purchase Order",
                      maxLines: 2,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: Container(
            padding: const EdgeInsets.only(bottom: 25, left: 5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildChoiceChips(),
                      ),
                    ],
                  ),
                ),
                Obx(() => _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
