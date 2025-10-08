import 'package:get/get.dart';
import 'package:immobile_app_fixed/config/config.dart';
import 'package:intl/intl.dart';

class GlobalVM extends GetxController {
  Config config = Config();
  var choicecategory = "".obs;
  var username = "".obs;
  var version = "".obs;

  dateToString(String date) {
    final format = DateFormat('dd-MM-yyyy');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }

  stringToDateWithTime(String date) {
    final format = DateFormat('dd-MM-yyyy HH:mm:ss');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }

  stringToDateWithHour(String date) {
    final format = DateFormat('dd-MM-yyyy / HH:mm');
    final dateTime = DateTime.parse(date);
    final dateFormat = format.format(dateTime);
    return dateFormat;
  }
}
