import 'dart:async';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/objectbox.g.dart';

class ObjectBoxApp {
  final Store store;
  late final Box<EventModel> productBox;

  ObjectBoxApp._(this.store) {
    productBox = store.box<EventModel>();
  }

  static Future<ObjectBoxApp> create() async {
    final store = await openStore();
    return ObjectBoxApp._(store);
  }

  // Stream<List<EventModel>> watchAllProducts() {
  //   final controller = StreamController<List<EventModel>>();
  //   Query<EventModel>? q;
  //
  //   final sub = productBox.query().watch(triggerImmediately: true).listen((query) {
  //     q ??= query;
  //     controller.add(query.find());
  //   }, onError: controller.addError);
  //
  //   controller.onCancel = () async {
  //     await sub.cancel();
  //     q?.close();
  //     await controller.close();
  //   };
  //
  //   return controller.stream;
  // }
}
