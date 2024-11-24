import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:wedding_collection_new/ui/home.dart';
import 'package:wedding_collection_new/utils/costom%20theme/theme.dart';
import 'package:wedding_collection_new/utils/widgets/helper/internet_provider.dart';
import 'package:wedding_collection_new/utils/widgets/no_internet_widget.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2),() => FlutterNativeSplash.remove());
    return ChangeNotifierProvider(
      create: (_) =>
          ConnectivityService(), // Provide ConnectivityService globally
      child: MaterialApp(
        title: 'Wedding Collection',
        themeMode: ThemeMode.system,
        theme: ECTheme.lightTheme,
        darkTheme: ECTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: ConnectivityWrapper(child: const HomePage()),
      ),
    );
  }
}
