import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wahab/model/product.dart';

class ProductRepo extends GetxController {
  static ProductRepo get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// ✅ 1) گرفتن ID مسلسل با Transaction
  Future<String> _getNextSerialId() async {
    final counterRef = _db.collection("counters").doc("products");

    final int nextId = await _db.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int lastId = 0;

      if (snapshot.exists) {
        lastId = (snapshot.data()?["lastId"] ?? 0) as int;
      } else {
        // اگر سند نبود، بساز
        transaction.set(counterRef, {"lastId": 0});
        lastId = 0;
      }

      final newId = lastId + 1;
      transaction.update(counterRef, {"lastId": newId});

      return newId;
    });

    return nextId.toString(); // چون id در Product تو String است
  }

  /// ✅ 2) ADD با ID مسلسل
  Future<void> addproduct(Product product) async {
    try {
      final String serialId = await _getNextSerialId();

      final newProduct = Product(
        id: serialId,
        title: product.title,
        group: product.group,
        desc: product.desc,
        tool: product.tool,
        imageURL: product.imageURL,
      );

      await _db.collection("products").doc(serialId).set(newProduct.toJson());

      Get.snackbar(
        "Success",
        "Product added with ID: $serialId",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add product: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
        colorText: Colors.white,
      );
    }
  }

  /// ✅ 3) UPDATE
  Future<void> updateProduct(Product product) async {
    try {
      await _db.collection("products").doc(product.id).update(product.toJson());

      Get.snackbar(
        "Success",
        "The product has been updated",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withAlpha(40),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update the product: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
        colorText: Colors.white,
      );
    }
  }

  /// ✅ 4) FETCH
  Stream<List<Product>> fetchproducts() {
    return _db.collection("products").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id; // همیشه id را docId بگیر
        return Product.fromJson(data);
      }).toList();
    });
  }
}
