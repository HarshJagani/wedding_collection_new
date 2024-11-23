import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wedding_collection_new/home.dart';
import 'package:wedding_collection_new/product_detail.dart';
import 'package:wedding_collection_new/upload_product.dart';
import 'package:wedding_collection_new/utils/costom%20theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Collection',
      themeMode: ThemeMode.system,
      theme: ECTheme.lightTheme,
      darkTheme: ECTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/addProduct': (context) => const AddProductScreen(),
       
      },
    );
  }
}
