import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/splash.dart';
import 'package:internhub/checkInternet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mgmvynmmdqbnzlandlmr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbXZ5bm1tZHFibnpsYW5kbG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NzAzNTEsImV4cCI6MjA3NTM0NjM1MX0.Wc5jne51kwrybkqBVCiy-RQdzvascOeRJO0q_LluAdk',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => InternetProvider(),
      child: const MyApp(),
    ),
  );
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
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xffF5761A),
          contentTextStyle: TextStyle(color: Colors.black),
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xfff5761a),
          selectionHandleColor: Color(0xfff5761a),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return Colors.white;
            }),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
