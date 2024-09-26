import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class productinfo {
  String productname = '';
  String productdesc = '';
  double productprice = 0;
  int reviewrating = 0;
  String userreview = '';

  productinfo(String productName, String productDesc, double productPrice,
      int reviewRating, String userReview) {
    productname = productName;
    productdesc = productDesc;
    productprice = productPrice;
    reviewrating = reviewRating;
    userreview = userReview;
  }

  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  Future<void> setproductinfo() async {
    await products.doc(productname).set({
      'name': productname,
      'description': productdesc,
      'price': productprice,
      'reviewrating': reviewrating,
      'userreview': userreview,
    });
  }

  Future<String> getproductname() async {
    DocumentSnapshot docSnapshot = await products.doc(productname).get();
    if (docSnapshot.exists) {
      return docSnapshot['name'] ?? '';
    } else {
      return '';
    }
  }

  Future<String> getproductdescription() async {
    DocumentSnapshot docSnapshot = await products.doc(productname).get();
    if (docSnapshot.exists) {
      return docSnapshot['description'] ?? '';
    } else {
      return '';
    }
  }

  Future<double> getproductprice() async {
    DocumentSnapshot docSnapshot = await products.doc(productname).get();
    if (docSnapshot.exists) {
      return (docSnapshot['price'] ?? 0).toDouble();
    } else {
      return 0;
    }
  }

  Future<int> getteviewrating() async {
    DocumentSnapshot docSnapshot = await products.doc(productname).get();
    if (docSnapshot.exists) {
      return docSnapshot['reviewrating'] ?? 0;
    } else {
      return 0;
    }
  }

  Future<String> getuserreview() async {
    DocumentSnapshot docSnapshot = await products.doc(productname).get();
    if (docSnapshot.exists) {
      return docSnapshot['userreview'] ?? '';
    } else {
      return '';
    }
  }
}
