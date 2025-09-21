import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool loginFocus = true;
  int userType = 0;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = Color(0xffF5761A);
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 25,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: WidgetStateColor.transparent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      loginFocus = true;
                    });
                  },
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: loginFocus
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: WidgetStateColor.transparent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      loginFocus = false;
                    });
                  },
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontWeight: loginFocus
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            toolbarHeight: screenHeight * 0.07,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),

        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: loginFocus
                  ? SingleChildScrollView(
                      child: _loginCard(
                        screenWidth,
                        screenHeight,
                        _formKey,
                        orange,
                      ),
                    )
                  : SingleChildScrollView(
                      child: _loginCard(
                        screenWidth,
                        screenHeight,
                        _formKey,
                        orange,
                      ),
                    ), //SingleChildScrollView(child: _CreateCard(screenWidth, screenHeight))
            ),
            Positioned(
              left: 0,
              right: 0,
              top: screenHeight / 5,
              child: _UserTypeSelector(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                orange: orange,
                userType: userType,
                onSelect: (val) {
                  setState(() {
                    userType = val;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _UserTypeSelector({
  required double screenWidth,
  required double screenHeight,
  required Color orange,
  required int userType,
  required void Function(int) onSelect,
}) {
  return Container(
    height: screenHeight / 15,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(width: 1),
      boxShadow: [
        BoxShadow(
          color: Color(0x88888888),
          offset: Offset(1, 5),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: userType == 0 ? orange : Colors.white,
                border: Border(right: BorderSide(width: 1)),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  overlayColor: orange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () => onSelect(0),
                child: Text(
                  'Student',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: userType == 1 ? orange : Colors.white,
                border: Border(right: BorderSide(width: 1)),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  overlayColor: orange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () => onSelect(1),
                child: Text(
                  'Company',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              color: userType == 2 ? orange : Colors.white,
              child: TextButton(
                style: TextButton.styleFrom(
                  overlayColor: orange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () => onSelect(2),
                child: Text(
                  'Coordinator',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

OutlineInputBorder _inputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.circular(12.5),
  );
}

OutlineInputBorder _errorBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
    borderRadius: BorderRadius.circular(12.5),
  );
}

Widget _loginCard(double screenWidth, double screenHeight, _formKey, orange) {
  return Column(
    children: [
      Text(
        'LOGIN',
        style: TextStyle(fontFamily: 'InterExtraBold', fontSize: 48),
      ),
      SizedBox(height: screenHeight * 0.005),
      Form(
        key: _formKey,
        child: Column(
          spacing: screenHeight / 30,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x88888888),
                    offset: Offset(1, 5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextFormField(
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  hint: Text('Email', style: TextStyle(color: Colors.grey)),
                  border: _inputBorder(),
                  enabledBorder: _inputBorder(),
                  focusedBorder: _inputBorder(),
                  errorBorder: _errorBorder(),
                  focusedErrorBorder: _errorBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x88888888),
                    offset: Offset(1, 5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextFormField(
                cursorColor: Colors.black,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  hint: Text('Password', style: TextStyle(color: Colors.grey)),
                  border: _inputBorder(),
                  enabledBorder: _inputBorder(),
                  focusedBorder: _inputBorder(),
                  errorBorder: _errorBorder(),
                  focusedErrorBorder: _errorBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 20),
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
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontFamily: 'InterExtraBold',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
