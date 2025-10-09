import 'package:get/get.dart';
import 'package:immobile_app_fixed/view_models/history_view_model.dart';
import 'package:immobile_app_fixed/view_models/pid_view_model.dart';
import 'package:immobile_app_fixed/view_models/stock_request_view_model.dart';
import 'category_view_model.dart';
import 'weborder_view_model.dart';
import 'in_view_model.dart';
import 'stock_check_view_model.dart';
import 'global_view_model.dart';
import 'reports_view_model.dart';
import 'stock_tick_view_model.dart';
import 'role_view_model.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryVM>(() => CategoryVM(), fenix: true);
    Get.lazyPut<WeborderVM>(() => WeborderVM(), fenix: true);
    Get.lazyPut<StockRequestVM>(() => StockRequestVM(), fenix: true);
    Get.lazyPut<InVM>(() => InVM(), fenix: true);
    Get.lazyPut<StockCheckVM>(() => StockCheckVM(), fenix: true);
    Get.lazyPut<HistoryViewModel>(() => HistoryViewModel(), fenix: true);
    Get.lazyPut<ReportsVM>(() => ReportsVM(), fenix: true);
    Get.lazyPut<GlobalVM>(() => GlobalVM(), fenix: true);
    Get.lazyPut<PidViewModel>(() => PidViewModel(), fenix: true);
    Get.lazyPut<StockTickVM>(() => StockTickVM(), fenix: true);
    Get.lazyPut<Rolevm>(() => Rolevm(), fenix: true);
  }
}
