import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:immobile_app_fixed/models/role_model.dart';
import 'package:immobile_app_fixed/view_models/global_view_model.dart';

class Rolevm extends GetxController {
  final GlobalVM globalvm = Get.find();

  final RxBool isLoading = true.obs;
  final Rx<Role> role = Role.empty().obs;

  Stream<Role> listrole() {
    try {
      return FirebaseFirestore.instance
          .collection('role')
          .doc(globalvm.username.value)
          .snapshots()
          .asyncMap((DocumentSnapshot docSnapshot) async {
            if (!docSnapshot.exists) {
              isLoading.value = false;
              return Role.empty();
            }

            final Role returnstock = Role.fromDocumentSnapshot(docSnapshot);
            role.value = returnstock;
            isLoading.value = false;
            return returnstock;
          });
    } catch (e) {
      print("Error in listrole: $e");
      isLoading.value = false;
      return Stream.value(Role.empty());
    }
  }
}
