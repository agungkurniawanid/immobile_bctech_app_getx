import 'package:get/get.dart';
import 'package:immobile/viewmodel/rolevm.dart';
import 'categoryvm.dart';
import 'webordervm.dart';
import 'stockrequestvm.dart';
import 'invm.dart';
import 'stockcheckvm.dart';
import 'globalvm.dart';
import 'historyvm.dart';
import 'pidvm.dart';
import 'reportsvm.dart';
import 'stocktickvm.dart';
import 'rolevm.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Get.put<UserController>(UserController(), permanent: true);
    // Get.put<AppController>(AppController(), permanent: true);
    // Get.lazyPut<CycleController>(() => CycleController(), fenix: true);
    // Get.create<TransactionController>(() => TransactionController('pembelian'),
    //     tag: 'pembelian');
    // Get.create<TransactionController>(() => TransactionController('penjualan'),
    //     tag: 'penjualan');
    // Get.lazyPut<TransactionController>(() => TransactionController('recent'),
    //     fenix: true, tag: 'recent');
    // Get.lazyPut<P4Controller>(() => P4Controller(), fenix: true);
    // Get.lazyPut<SPPAController>(() => SPPAController(), fenix: true);
    // Get.lazyPut<DtaController>(() => DtaController(), fenix: true);
    // Get.lazyPut<SearchingController>(() => SearchingController(), fenix: true);
    // Get.lazyPut<CatalogController>(() => CatalogController(), fenix: true);
    Get.lazyPut<CategoryVM>(() => CategoryVM(), fenix: true);
    Get.lazyPut<WeborderVM>(() => WeborderVM(), fenix: true);
    Get.lazyPut<StockrequestVM>(() => StockrequestVM(), fenix: true);
    Get.lazyPut<InVM>(() => InVM(), fenix: true);
    Get.lazyPut<StockCheckVM>(() => StockCheckVM(), fenix: true);
    Get.lazyPut<HistoryVM>(() => HistoryVM(), fenix: true);
    Get.lazyPut<ReportsVM>(() => ReportsVM(), fenix: true);
    Get.lazyPut<GlobalVM>(() => GlobalVM(), fenix: true);
    Get.lazyPut<PidVM>(() => PidVM(), fenix: true);
    Get.lazyPut<StockTickVM>(() => StockTickVM(), fenix: true);
    Get.lazyPut<Rolevm>(() => Rolevm(), fenix: true);
  }
}
