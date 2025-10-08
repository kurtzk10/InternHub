import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:internhub/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentMainPage extends StatefulWidget {
  @override
  _StudentMainPageState createState() => _StudentMainPageState();
}

class _StudentMainPageState extends State<StudentMainPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = Color(0xffF5761A);
    final isWide = screenWidth > 600;
    return Scaffold(
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

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(
                top: screenHeight / 20,
                bottom: screenHeight / 40,
              ),
              child: _firstTime(
                context,
                screenWidth,
                screenHeight,
                _formKey,
                orange,
                isWide,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _firstTime(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  formKey,
  orange,
  bool isWide,
) {
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  return Container(
    width: double.infinity,
    height: screenHeight * 0.6,
    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),

    decoration: isWide
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.5),
            boxShadow: [
              BoxShadow(
                color: Color(0x88888888),
                offset: Offset(1, 5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          )
        : null,

    child: Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          width: isWide
              ? screenWidth / 2.5 - (screenWidth * 0.05 * 2)
              : screenWidth,
          height: isWide ? screenHeight * 0.6 : null,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: 'Welcome to '),
                    TextSpan(
                      text: 'InternHub',
                      style: TextStyle(
                        color: orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '!'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please complete your profile information to unlock internship opportunities and connect with potential employers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: isWide
              ? screenWidth * 0.6 - (screenWidth * 0.05 * 2)
              : screenWidth,
          padding: EdgeInsets.only(left: isWide ? screenWidth * 0.05 : 0),
          height: isWide ? screenHeight * 0.6 : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: formKey,
                child: Container(
                  height: isWide ? screenHeight / 2 : null, //FIX
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'What is your name?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _firstController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hoverColor: Colors.white,
                          hint: Text(
                            'First Name',
                            style: TextStyle(color: Colors.grey),
                          ),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          errorBorder: _inputBorder(),
                          focusedErrorBorder: _inputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _lastController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hoverColor: Colors.white,
                          hint: Text(
                            'Last Name',
                            style: TextStyle(color: Colors.grey),
                          ),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          errorBorder: _inputBorder(),
                          focusedErrorBorder: _inputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Spacer(),
                  Expanded(
                    child: Container(
                      height: screenHeight / 15,
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x88888888),
                            offset: Offset(1, 5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          final first = _firstController.text.trim();
                          final last = _lastController.text.trim();
                        },
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'InterExtraBold',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ],
    ),
  );
}

OutlineInputBorder _inputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.circular(12.5),
  );
}
