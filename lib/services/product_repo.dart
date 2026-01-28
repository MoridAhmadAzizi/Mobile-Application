import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wahab/model/product.dart';
import 'package:wahab/objectbox.g.dart';
import 'package:wahab/objectbox/objectbox.dart';
import 'package:wahab/objectbox/product_entity.dart';

class ProductRepo extends GetxController {
  static ProductRepo get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final ObjectBoxApp _ob = Get.find<ObjectBoxApp>();

  final RxBool isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _connSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _fsSub;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  void showOfflineMassage() {
    Get.snackbar("Offline", "You are offline, Check your internet connection",
    snackPosition: SnackPosition.BOTTOM
    );
  }

  void _initConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _setOnlineFromResults(results);

    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      _setOnlineFromResults(results);
    });
  }

  void _setOnlineFromResults(List<ConnectivityResult> results) {
    final online = !results.contains(ConnectivityResult.none);
    isOnline.value = online;

    if (online) {
      _startFirestoreSync();
    } else {
      _stopFirestoreSync();
    }
  }

  void _startFirestoreSync() {
    if (_fsSub != null) return;

    _fsSub = _db.collection("products").snapshots().listen((snapshot) {
      final entities = snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;
        final p = Product.fromJson(data);
        return ProductEntity.fromProduct(p);
      }).toList();
      _ob.store.runInTransaction(TxMode.write, () {
        _ob.productBox.removeAll();
        _ob.productBox.putMany(entities);
      });
    });
  }

  void _stopFirestoreSync() async {
    await _fsSub?.cancel();
    _fsSub = null;
  }

  Stream<List<Product>> watchProducts() {
    return _ob.watchAllProducts().map((entities) {
      return entities.map((e) => e.toProduct()).toList();
    });
  }

  void _offlineError() {
    Get.snackbar(
      "Offline",
      "You are offline. Read-only mode (no add/update).",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withAlpha(40),
      colorText: Colors.white,
    );
  }

  Future<String> _getNextSerialId() async {
    final counterRef = _db.collection("counters").doc("products");

    final int nextId = await _db.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int lastId = 0;

      if (snapshot.exists) {
        lastId = (snapshot.data()?["lastId"] ?? 0) as int;
      } else {
        transaction.set(counterRef, {"lastId": 0});
        lastId = 0;
      }

      final newId = lastId + 1;
      transaction.update(counterRef, {"lastId": newId});

      return newId;
    });

    return nextId.toString();
  }

  Future<void> addproduct(Product product) async {
    if (!isOnline.value) {
      _offlineError();
      throw Exception("Offline: add is disabled");
    }

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

      _upsertLocalCache(newProduct);

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
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    if (!isOnline.value) {
      _offlineError();
      throw Exception("Offline: update is disabled");
    }

    try {
      await _db.collection("products").doc(product.id).update(product.toJson());

      _upsertLocalCache(product);

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
      rethrow;
    }
  }

  void _upsertLocalCache(Product product) {
    final q = _ob.productBox
        .query(ProductEntity_.firebaseId.equals(product.id))
        .build();
    final existing = q.findFirst();
    q.close();

    final entity = ProductEntity.fromProduct(product);
    if (existing != null) {
      entity.obId = existing.obId;
    }
    _ob.productBox.put(entity);
  }

  @override
  void onClose() {
    _connSub?.cancel();
    _fsSub?.cancel();
    super.onClose();
  }
}
