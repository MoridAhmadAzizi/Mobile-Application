import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import '../model/product.dart';
import '../services/product_repo.dart';

class ProductController extends GetxController {
  ProductController(this._repo);

  final ProductRepo _repo;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isOnline = true.obs;

  StreamSubscription<List<Product>>? _sub;

  @override
  void onInit() {
    super.onInit();

    _sub = _repo.watchProducts().listen((list) {
      products.assignAll(list);
    });

    isOnline.value = _repo.isOnline.value;
    _repo.isOnline.addListener(_onlineListener);
  }

  void _onlineListener() {
    isOnline.value = _repo.isOnline.value;
  }

  Uint8List? cachedBytes(String key) => _repo.getCachedBytes(key);

  Future<Product> upsert(Product p) => _repo.upsert(p);

  Future<void> forceSync() async {
    await _repo.syncPendingToRemote();
    await _repo.syncFromRemote();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _repo.isOnline.removeListener(_onlineListener);
    super.onClose();
  }
}
