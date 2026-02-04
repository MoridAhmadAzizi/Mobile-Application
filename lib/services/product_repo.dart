import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:objectbox/objectbox.dart' as obx;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/product.dart';
import '../objectbox/objectbox.dart';
import '../objectbox/product_entity.dart';
import '../objectbox/product_image_entity.dart';
import '../supabase_config.dart';
import '../utils/image_utils.dart';
import '../objectbox.g.dart';

/// ریپو برای محصولات:
/// - آنلاین: Supabase (products + Storage)
/// - آفلاین: ObjectBox (products + bytes تصاویر)
/// - سینک: وقتی آنلاین شد، رکوردهای isDirty را به Supabase می‌فرستد.
class ProductRepo {
  ProductRepo({
    required SupabaseClient client,
    required ObjectBoxApp objectBox,
  })  : _client = client,
        _ob = objectBox {
    _initConnectivity();
  }

  final SupabaseClient _client;
  final ObjectBoxApp _ob;

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  RealtimeChannel? _channel;

  // -------------------------
  // Connectivity
  // -------------------------
  Future<void> _initConnectivity() async {
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
      unawaited(syncPendingToRemote());
      unawaited(syncFromRemote());
      _startRealtime();
    } else {
      _stopRealtime();
    }
  }

  // -------------------------
  // Watch local cache
  // -------------------------
  Stream<List<Product>> watchProducts() {
    return _ob.watchAllProducts().map((entities) {
      // جدیدترین اول: createdAtMs desc
      final list = [...entities];
      list.sort((a, b) => (b.createdAtMs ?? 0).compareTo(a.createdAtMs ?? 0));
      return list.map((e) => e.toProduct()).toList();
    });
  }

  // -------------------------
  // Remote sync (download)
  // -------------------------
  Future<void> syncFromRemote() async {
    try {
      final data = await _client
          .from('products')
          // group یک keyword است، پس در select با کوتیشن می‌آوریم
          .select('id,title,description,"group",tools,image_paths,created_at,updated_at')
          .order('created_at', ascending: false);

      final products = (data as List)
          .cast<Map<String, dynamic>>()
          .map(Product.fromDb)
          .toList();

      _ob.store.runInTransaction(obx.TxMode.write, () {
        // رکوردهای dirty را نگه دار
        final dirty = _ob.productBox.query(ProductEntity_.isDirty.equals(true)).build().find();
        _ob.productBox.removeAll();

        for (final p in products) {
          _ob.productBox.put(ProductEntity.fromProduct(p, isDirty: false));
        }
        for (final d in dirty) {
          _ob.productBox.put(d);
        }
      });

      // Cache images (best-effort)
      for (final p in products) {
        await _cacheImagesForProduct(p);
      }
    } catch (_) {
      // silent
    }
  }

  void _startRealtime() {
    if (_channel != null) return;
    _channel = _client.channel('public:products');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (_) => unawaited(syncFromRemote()),
        )
        .subscribe();
  }

  void _stopRealtime() {
    final ch = _channel;
    _channel = null;
    if (ch != null) {
      _client.removeChannel(ch);
    }
  }

  // -------------------------
  // CRUD (offline-first)
  // -------------------------

  String _genLocalId() {
    final r = Random().nextInt(999999);
    return 'local_${DateTime.now().millisecondsSinceEpoch}_$r';
  }

  /// ایجاد/ویرایش محصول:
  /// - اگر آفلاین هستیم => فقط در ObjectBox ذخیره می‌شود (isDirty=true)
  /// - اگر آنلاین هستیم => به Supabase می‌رود و سپس کش آپدیت می‌شود.
  Future<Product> upsert(Product draft) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (!isOnline.value) {
      // offline save
      final localId = draft.id.isEmpty ? _genLocalId() : draft.id;
      final now = DateTime.now();
      final offlineProduct = draft.copyWith(
        id: localId,
        createdAt: draft.createdAt ?? now,
        updatedAt: now,
      );
      _upsertLocalCache(offlineProduct, isDirty: true);

      // cache local images bytes (from file) for offline viewing on this device
      await _cacheLocalImagesBytes(offlineProduct.imagePaths);

      return offlineProduct;
    }

    // online
    if (draft.id.startsWith('local_') || draft.id.isEmpty) {
      return _insertRemote(draft, user.id);
    }
    return _updateRemote(draft, user.id);
  }

  Future<Product> _insertRemote(Product draft, String userId) async {
    // 1) Insert row (without images) => get uuid
    final inserted = await _client
        .from('products')
        .insert({
          'title': draft.title,
          'description': draft.desc,
          'group': draft.group,
          'tools': draft.tools,
          'image_paths': <String>[],
          // owner_id توسط trigger set_owner_id() پر می‌شود
        })
        .select('id,title,description,"group",tools,image_paths,created_at,updated_at')
        .single();

    final productId = inserted['id'].toString();

    // 2) Upload images (if any local)
    final urls = await _uploadImagesIfNeeded(
      productId: productId,
      userId: userId,
      images: draft.imagePaths,
    );

    // 3) Update row with image urls
    final updatedRow = await _client
        .from('products')
        .update({'image_paths': urls})
        .eq('id', productId)
        .select('id,title,description,"group",tools,image_paths,created_at,updated_at')
        .single();

    final product = Product.fromDb(updatedRow);

    _upsertLocalCache(product, isDirty: false);
    await _cacheImagesForProduct(product);
    return product;
  }

  Future<Product> _updateRemote(Product product, String userId) async {
    final urls = await _uploadImagesIfNeeded(
      productId: product.id,
      userId: userId,
      images: product.imagePaths,
    );

    final row = await _client
        .from('products')
        .update({
          'title': product.title,
          'description': product.desc,
          'group': product.group,
          'tools': product.tools,
          'image_paths': urls,
        })
        .eq('id', product.id)
        .select('id,title,description,"group",tools,image_paths,created_at,updated_at')
        .single();

    final updated = Product.fromDb(row);

    _upsertLocalCache(updated, isDirty: false);
    await _cacheImagesForProduct(updated);
    return updated;
  }

  /// سینک رکوردهای آفلاین/dirty به Supabase (best-effort)
  Future<void> syncPendingToRemote() async {
    if (!isOnline.value) return;
    final user = _client.auth.currentUser;
    if (user == null) return;

    final q = _ob.productBox.query(ProductEntity_.isDirty.equals(true)).build();
    final dirty = q.find();
    q.close();

    for (final e in dirty) {
      try {
        final p = e.toProduct();
        final synced = await upsert(p);
        // اگر id عوض شد (local -> uuid)، entity را جایگزین کن
        if (synced.id != e.id) {
          _ob.productBox.remove(e.obId);
        }
        _upsertLocalCache(synced, isDirty: false);
      } catch (_) {
        // ignore and try later
      }
    }
  }

  // -------------------------
  // Image: upload + cache (ObjectBox)
  // -------------------------
  bool _isRemoteUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

  Future<List<String>> _uploadImagesIfNeeded({
    required String productId,
    required String userId,
    required List<String> images,
  }) async {
    final out = <String>[];
    final storage = _client.storage.from(SupabaseConfig.imageBucket);

    for (var i = 0; i < images.length; i++) {
      final img = images[i];
      if (img.isEmpty) continue;
      if (img.startsWith('assets/')) continue;
      if (_isRemoteUrl(img)) {
        out.add(img);
        continue;
      }

      // local file -> compress -> upload
      final normalized = img.startsWith('file://') ? img.replaceFirst('file://', '') : img;
      if (!File(normalized).existsSync()) continue;

      final bytes = await ImageUtils.compressToJpegBytes(normalized);
      final path = '$userId/$productId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      final publicUrl = storage.getPublicUrl(path);
      out.add(publicUrl);

      // cache bytes locally
      _upsertImageCache(publicUrl, bytes);
    }

    return out;
  }

  Future<void> _cacheImagesForProduct(Product p) async {
    for (final url in p.imagePaths) {
      if (!_isRemoteUrl(url)) continue;

      final existing = _findImageCache(url);
      if (existing != null) continue;

      try {
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode == 200) {
          _upsertImageCache(url, resp.bodyBytes);
        }
      } catch (_) {}
    }
  }

  Future<void> _cacheLocalImagesBytes(List<String> paths) async {
    for (final path in paths) {
      if (_isRemoteUrl(path)) continue;
      final normalized = path.startsWith('file://') ? path.replaceFirst('file://', '') : path;
      if (!File(normalized).existsSync()) continue;

      final existing = _findImageCache(path);
      if (existing != null) continue;

      try {
        final bytes = await ImageUtils.compressToJpegBytes(normalized);
        _upsertImageCache(path, bytes);
      } catch (_) {}
    }
  }

  ProductImageEntity? _findImageCache(String key) {
    final q = _ob.imageBox.query(ProductImageEntity_.key.equals(key)).build();
    final found = q.findFirst();
    q.close();
    return found;
  }

  void _upsertImageCache(String key, Uint8List bytes) {
    final existing = _findImageCache(key);
    final e = ProductImageEntity(key: key, bytes: bytes);
    if (existing != null) {
      e.obId = existing.obId;
    }
    _ob.imageBox.put(e);
  }

  /// برای UI: اگر در ObjectBox کش هست bytes را بده
  Uint8List? getCachedBytes(String key) {
    return _findImageCache(key)?.bytes;
  }

  void _upsertLocalCache(Product product, {required bool isDirty}) {
    final q = _ob.productBox.query(ProductEntity_.id.equals(product.id)).build();
    final existing = q.findFirst();
    q.close();

    final entity = ProductEntity.fromProduct(product, isDirty: isDirty);
    if (existing != null) {
      entity.obId = existing.obId;
    }
    _ob.productBox.put(entity);
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    _stopRealtime();
  }
}
