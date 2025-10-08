import 'package:immobile/model/role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:immobile/viewmodel/globalvm.dart';
import 'package:get/get.dart';

class Rolevm {
    GlobalVM globalVM = Get.find();
    var isLoading = true.obs;
    GlobalVM globalvm = Get.find();

    Role role;

Stream<Role> listrole() {
  try {
    return FirebaseFirestore.instance
        .collection('role')
        .doc(globalvm.username.value)
        .snapshots()
        .map((DocumentSnapshot docSnapshot) {
      
      // Check if data is null or empty, return an empty list if so
      if (docSnapshot == null) return role;

        final returnstock = Role.fromDocumentSnapshot(documentSnapshot: docSnapshot);
        role = returnstock;

       
      isLoading.value = false;

      return role;
    });
  } catch (e) {
    print(e);
    // Handle the error and return an empty list in case of failure
    return Stream.value(role);
  }

  //  getrole(Role data) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('user')
  //         .doc(data.userid)
  //         .set({
  //           'userid': data.userid,
  //           'email': data.email,
  //           'name': data.name,
  //           'status': data.status
  //         })
  //         // return test;
  //         .then((result) => {print("Sukses")})
  //         .catchError((err) => print('Error retrieving data: $err'));
  //   } catch (e) {
  //     print(e);
  //   }
  // }

}
}