import 'package:flutter/material.dart';
import 'package:internhub/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';

class CompanyPage extends StatefulWidget {
  @override
  _CompanyPageState createState() => _CompanyPageState();
}

Future<Map<String, dynamic>?> getVerificationStatus() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
}

class _CompanyPageState extends State<CompanyPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = Color(0xffF5761A);
    final isWide = screenWidth > 600;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.07),
          child: Container(
            margin: EdgeInsets.only(
              left: screenWidth * 0.075,
              right: screenWidth * 0.04,
              top: screenHeight * 0.02,
            ),
            child: AppBar(
              leading: Container(
                child: Image.asset(
                  'assets/logo-no-text.png',
                  height: 20,
                  width: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}