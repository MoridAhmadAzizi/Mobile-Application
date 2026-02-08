import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'core/objectbox/objectbox.dart';
import 'features/home.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  await ObjectBoxApp.create();
  // final client = Supabase.instance.client;

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'برنامه ها',
      theme: AppTheme.light(),
      locale: const Locale('fa', 'IR'),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox()),
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    // final ac = Get.find<AuthController>();
    return const Home();

    //   return Obx(() {
    //     if (ac.isLoading.value) {
    //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    //     }
    //
    //     // اگر لاگین نیست => لاگین
    //     if (!ac.isAuthenticated) {
    //       return const LoginOrRegister();
    //     }
    //
    //     // اگر لاگین هست => هوم
    //     return const Home();
    //   });
  }
}
