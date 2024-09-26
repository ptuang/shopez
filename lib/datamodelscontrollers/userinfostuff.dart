import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class userinfo {
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String getuid() {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    return uid;
  }

  Future<String> getfname() async {
    DocumentSnapshot docSnapshot = await users.doc(getuid()).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, String>;
      return data['firstname'] ?? '';
    } else {
      return '';
    }
  }

  Future<String> getlname() async {
    DocumentSnapshot docSnapshot = await users.doc(getuid()).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, String>;
      return data['lastname'] ?? '';
    } else {
      return '';
    }
  }

  Future<String> getaddress() async {
    DocumentSnapshot docSnapshot = await users.doc(getuid()).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, String>;
      return data['address'] ?? '';
    } else {
      return '';
    }
  }

  Future<void> setfname(String firstname) async {
    return users.doc(getuid()).set({'firstname': firstname});
  }

  Future<void> setlname(String lastname) async {
    return users.doc(getuid()).set({'lastname': lastname});
  }

  Future<void> setaddress(String address) async {
    return users.doc(getuid()).set({'address': address});
  }
}
