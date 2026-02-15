import 'package:events/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'core/repository/database_repository.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final databaseRepository = await DatabaseRepository.create();

  // Services / Repos
  // Get.put<AuthService>(AuthService(client), permanent: true);
  // Get.put<ProfileRepo>(ProfileRepo(client), permanent: true);
  // Get.put<ProductRepo>(ProductRepo(client: client, objectBox: ob), permanent: true);

  // Controllers
  // Get.put<AuthController>(
  //   AuthController(auth: Get.find<AuthService>(), profiles: Get.find<ProfileRepo>()),
  //   permanent: true,
  // );
  // Get.put<EventController>(
  //   EventController(Get.find<ProductRepo>()),
  //   permanent: true,
  // );
  final router = AppRouter().buildRoutes();
  runApp(MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: databaseRepository), RepositoryProvider.value(value: databaseRepository.getEventRepository())],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'برنامه ها',
        theme: AppTheme.light(),
        locale: const Locale('fa', 'IR'),
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox()),
      )));
}
