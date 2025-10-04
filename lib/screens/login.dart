import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/screens/verification.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool loginFocus = true;
  int userType = 0;

  Future<String> _login(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return ("Sign-up failed. Please try again");
      }

      return ('Successfully signed in as $email');
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String> _signUp(String email, String password, int userType) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return ("Sign-up failed. Please try again.");
      }

      String role = userType == 0
          ? 'student'
          : userType == 1
          ? 'company'
          : 'admin';

      if (response.user != null) {
        final userInsert = await Supabase.instance.client
            .from('user')
            .insert({'authId': response.user!.id, 'role': role})
            .select()
            .single();

        await Supabase.instance.client.from(role).insert({
          'userId': userInsert['userId'],
        });
      }
      return "You're almost there! We sent a verification link to your email. Please confirm to continue using InternHub.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return ("Unexpected error: $e");
    }
  }

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
        margin: isWide
            ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3)
            : EdgeInsets.symmetric(horizontal: screenWidth * 0.1),

        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: _loginCard(
                  context,
                  screenWidth,
                  screenHeight,
                  userType,
                  _formKey,
                  orange,
                  loginFocus,
                  _login,
                  _signUp,
                  setState,
                ),
              ),
            ),
            if (!loginFocus)
              Positioned(
                left: 0,
                right: 0,
                top: screenHeight / 6,
                child: _userTypeSelector(
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

Widget _userTypeSelector({
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

Widget _loginCard(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  int userType,
  formKey,
  orange,
  bool loginFocus,
  Future<String> Function(String, String) onLogin,
  Future<String> Function(String, String, int) onSignUp,
  void Function(void Function()) setParentState,
) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  return Column(
    children: [
      loginFocus
          ? Text(
              'LOGIN',
              style: TextStyle(fontFamily: 'InterExtraBold', fontSize: 48),
            )
          : Text(
              'SIGN UP',
              style: TextStyle(fontFamily: 'InterExtraBold', fontSize: 48),
            ),
      SizedBox(height: screenHeight * 0.005),
      Form(
        key: formKey,
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
                controller: emailController,
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
                controller: passwordController,
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
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Email can't be empty")),
                    );
                    return;
                  } else if (password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password can't be empty")),
                    );
                    return;
                  }

                  if (loginFocus) {
                    final result = await onLogin(email, password);

                    setParentState(() {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result)));
                    });
                  } else {
                    final result = await onSignUp(email, password, userType);

                    setParentState(() {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result)));
                    });
                  }
                },
                child: loginFocus
                    ? Text(
                        'LOGIN',
                        style: TextStyle(
                          fontFamily: 'InterExtraBold',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontFamily: 'InterExtraBold',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            Row(
              children: [
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("or", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}


//TODO: implement verification page, 