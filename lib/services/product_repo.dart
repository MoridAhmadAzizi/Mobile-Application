import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wahab/model/product.dart';

class ProductRepo extends GetxController {
  static ProductRepo get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> addproduct(Product product) async {
    try {
      await _db.collection("products").add(product.toJson()).whenComplete(() {
        Get.snackbar("Success", "The Prodcut has been added",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withAlpha(10),
            colorText: Colors.white);
      });
    } catch (e) {
      Get.snackbar("Error", "oops something unexpected",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withAlpha(40),
          colorText: Colors.black87);
    }
  }

  Stream<List<Product>> fetchproducts() {
    return _db.collection("products").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromJson(doc.data());
      }).toList();
    });
  }
}
