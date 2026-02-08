// import 'dart:async';
// import 'dart:typed_data';
//
// import 'package:get/get.dart';
//
// import '../model/event_model.dart';
// import '../repository/event_repository.dart';
//
// class EventController extends GetxController {
//   EventController(this._repo);
//
//   final ProductRepo _repo;
//
//   final RxList<EventModel> products = <EventModel>[].obs;
//   final RxBool isOnline = true.obs;
//
//   StreamSubscription<List<EventModel>>? _sub;
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     _sub = _repo.watchProducts().listen((list) {
//       products.assignAll(list);
//     });
//
//     isOnline.value = _repo.isOnline.value;
//     _repo.isOnline.addListener(_onlineListener);
//   }
//
//   void _onlineListener() {
//     isOnline.value = _repo.isOnline.value;
//   }
//
//   // Uint8List? cachedBytes(String key) => _repo.getCachedBytes(key);
//
//   Future<EventModel> upsert(EventModel p) => _repo.upsert(p);
//
//   Future<void> forceSync() async {
//     await _repo.syncPendingToRemote();
//     await _repo.syncFromRemote();
//   }
//
//   @override
//   void onClose() {
//     _sub?.cancel();
//     _repo.isOnline.removeListener(_onlineListener);
//     super.onClose();
//   }
// }
