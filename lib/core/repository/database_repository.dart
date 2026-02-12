import 'dart:async';
import 'package:events/features/events/repository/event_repository.dart';
import 'package:events/objectbox.g.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Store? _databaseStore;

class DatabaseRepository {
  final Store store;
  DatabaseRepository._(this.store);

  static Future<DatabaseRepository> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final databaseFile = join(docsDir.path, 'repository');
    if (_databaseStore == null) {
      if (Store.isOpen(databaseFile)) {
        _databaseStore = Store.attach(getObjectBoxModel(), databaseFile);
      } else {
        _databaseStore = await openStore(directory: databaseFile);
      }
    }
    final databaseRepository = DatabaseRepository._(_databaseStore!);
    // databaseRepository.fetchData();
    return databaseRepository;
  }

  EventRepository getEventRepository() => EventRepository(_databaseStore!.box());

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
