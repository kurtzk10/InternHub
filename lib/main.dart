import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xyrqvfikewndaqpnqjmq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5cnF2ZmlrZXduZGFxcG5xam1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0NzA5NzAsImV4cCI6MjA3NDA0Njk3MH0.yAbPSrUiNOGvPJTB3F72aosXm-3D8SUNzYRAMyJXwCQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternHub',
      home: SplashPage(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xffF5761A),
          contentTextStyle: TextStyle(
            color: Colors.black,
          )
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
