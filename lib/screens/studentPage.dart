import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'dart:async';

enum Focus { home, message, settings}

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Focus focus = Focus.home;

  bool isEditingEmail = false;
  bool isEditingPassword = false;

  bool emailChanged = false;
  bool passwordChanged = false;

  final _searchController = TextEditingController();
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();

    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email;

    _emailController.text = userEmail!;

    _emailController.addListener(() {
      setState(() {
        emailChanged = _emailController.text.trim() != userEmail;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        passwordChanged = _passwordController.text.isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = Color(0xffF5761A);
    final selectedOrange = Color(0xffD26217);
    final isWide = screenWidth > 600;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isWide ? screenHeight * 0.1 : screenHeight * 0.08,
          ),
          child: AppBar(
            backgroundColor: orange,
            centerTitle: true,
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
              child: Image.asset(
                'assets/logo-no-text.png',
                height: isWide ? 30 : 35,
                width: isWide ? 30 : 35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
