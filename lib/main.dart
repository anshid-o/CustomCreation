import 'package:custom_creations/constants.dart';

import 'package:custom_creations/main_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //   apiKey: "AIzaSyCl9ikSan9leewJqHYbk-OEDwXwqJxky_w",
      //   authDomain: "customcreations-26690.firebaseapp.com",
      //   projectId: "customcreations-26690",
      //   storageBucket: "customcreations-26690.appspot.com",
      //   messagingSenderId: "225504360298",
      //   appId: "1:225504360298:web:af96254b7e04995b871713",
      // ),
      );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        splashColor: cdgreen,
        highlightColor: cdgreen,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(), // SplashScreen(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
