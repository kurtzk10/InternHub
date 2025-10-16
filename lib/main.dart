import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/splash.dart';
import 'package:internhub/screens/authCallback.dart';
import 'package:internhub/screens/passwordReset.dart';
import 'package:internhub/screens/debugCallback.dart';
import 'package:internhub/checkInternet.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://mgmvynmmdqbnzlandlmr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbXZ5bm1tZHFibnpsYW5kbG1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NzAzNTEsImV4cCI6MjA3NTM0NjM1MX0.Wc5jne51kwrybkqBVCiy-RQdzvascOeRJO0q_LluAdk',
  );

  WidgetsFlutterBinding.ensureInitialized();
  
  // Listen to auth state changes for email confirmations and password resets
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;
    
    if (event == AuthChangeEvent.signedIn && session != null) {
      // User signed in successfully (could be from email confirmation or password reset)
      print('User signed in: ${session.user.email}');
      print('Email confirmed: ${session.user.emailConfirmedAt != null}');
    } else if (event == AuthChangeEvent.signedOut) {
      // User signed out
      print('User signed out');
    }
  });

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
      onGenerateRoute: (settings) {
        print('Route generated: ${settings.name}');
        
        switch (settings.name) {
          case '/auth/callback':
            return MaterialPageRoute(builder: (context) => AuthCallbackPage());
          case '/password-reset':
            return MaterialPageRoute(builder: (context) => PasswordResetPage());
          case '/debug-callback':
            return MaterialPageRoute(builder: (context) => DebugCallbackPage());
          default:
            return MaterialPageRoute(builder: (context) => SplashPage());
        }
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF02243F),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF02243F),
          surfaceTintColor: const Color(0xFF02243F),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFFF55119),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: const Color(0xFFF55119),
          selectionHandleColor: const Color(0xFFF55119),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return const Color(0xFF04305A);
            }),
          ),
        ),
        primaryColor: const Color(0xFFF55119),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF55119),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
