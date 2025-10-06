import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mgmvynmmdqbnzlandlmr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbXZ5bm1tZHFibnpsYW5kbG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NzAzNTEsImV4cCI6MjA3NTM0NjM1MX0.Wc5jne51kwrybkqBVCiy-RQdzvascOeRJO0q_LluAdk',
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
