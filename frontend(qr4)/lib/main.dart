import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr4/keys/firebase_options.dart';
// import 'theme/light_theme.dart';
// import 'theme/dark_theme.dart';
import 'Pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: lightTheme,
      // darkTheme: darkTheme,
      home: Homepage(),
    );
  }
}
