import 'package:flutter/material.dart';
import 'package:internhub/screens/companyPage.dart';
import 'package:internhub/screens/firstTimeCompany.dart';
import 'package:internhub/screens/firstTimeStudent.dart';
import 'package:internhub/screens/studentPage.dart';
import 'package:internhub/screens/adminPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';

class LoginResult {
  final bool success;
  final String message;
  LoginResult(this.success, this.message);
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool loginFocus = true;
  int userType = 0;
  bool isVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
  }

  Future<LoginResult> _login(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return LoginResult(false, "Login failed. Please try again.");
      }
      return LoginResult(true, 'Successfully signed in as $email');
    } on AuthException catch (e) {
      return LoginResult(false, e.message);
    }
  }

  Future<String> _signUp(String email, String password, int userType) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) return "Sign-up failed. Please try again.";

      final isExisting = await Supabase.instance.client
          .from('users')
          .select('email')
          .eq('email', email);

      if (isExisting.isNotEmpty) {
        return "This email already has an account registered to it.";
      }

      String role = userType == 0
          ? 'students'
          : userType == 1
          ? 'company'
          : 'admin';

      final userInsert = await Supabase.instance.client
          .from('users')
          .insert({'auth_id': response.user!.id, 'role': role, 'email': email})
          .select()
          .single();

      await Supabase.instance.client.from(role).insert({
        'user_id': userInsert['user_id'],
      });

      return "You're almost there! Check your email for a verification link.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<Map<String, dynamic>?> getProfile(String role) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user.id)
        .maybeSingle();

    Map<String, dynamic>? response = await Supabase.instance.client
        .from(role)
        .select()
        .eq('user_id', usersResponse!['user_id'])
        .single();

    for (final entry in response.entries) {
      final value = entry.value;
      if (value == null || value.toString().isEmpty) {
        return null;
      }
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = const Color(0xffF5761A);
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
              leading: Image.asset(
                'assets/logo-no-text.png',
                height: 20,
                width: 20,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 25,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: WidgetStateColor.transparent,
                      foregroundColor: Colors.black,
                      disabledForegroundColor: Colors.black,
                    ),
                    onPressed: loginFocus
                        ? null
                        : () => setState(() {
                            loginFocus = true;
                            isVisible = false;
                            emailController.text = '';
                            passwordController.text = '';
                          }),
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
                      disabledForegroundColor: Colors.black,
                    ),
                    onPressed: loginFocus
                        ? () => setState(() {
                            loginFocus = false;
                            isVisible = false;
                            emailController.text = '';
                            passwordController.text = '';
                          })
                        : null,
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
          height: screenHeight,
          margin: isWide
              ? EdgeInsets.symmetric(horizontal: screenWidth * 0.3)
              : EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: screenHeight / 20,
                children: [
                  if (!loginFocus)
                    _userTypeSelector(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      orange: orange,
                      userType: userType,
                      isWide: isWide,
                      onSelect: (val) => setState(() => userType = val),
                    ),
                  _loginCard(
                    context,
                    screenWidth,
                    screenHeight,
                    userType,
                    _formKey,
                    orange,
                    loginFocus,
                    emailController,
                    passwordController,
                    isVisible,
                    isWide,
                    _login,
                    _signUp,
                    setState,
                    getProfile,
                    () => setState(() {
                      isVisible = !isVisible;
                    }),
                  ),
                ],
              ),
            ),
          ),
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
  required bool isWide,
  required void Function(int) onSelect,
}) {
  return Container(
    height: isWide ? screenHeight / 10 : screenHeight / 15,
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
                    fontSize: screenHeight / 50,
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
                    fontSize: screenHeight / 50,
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
                    fontSize: screenHeight / 50,
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

Widget _loginCard(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  int userType,
  formKey,
  orange,
  bool loginFocus,
  emailController,
  passwordController,
  bool isVisible,
  bool isWide,
  Future<LoginResult> Function(String, String) onLogin,
  Future<String> Function(String, String, int) onSignUp,
  void Function(void Function()) setParentState,
  Future<Map<String, dynamic>?> Function(String) getProfile,
  VoidCallback passwordChange,
) {
  return Container(
    child: Column(
      children: [
        loginFocus
            ? Text(
                'LOGIN',
                style: TextStyle(
                  fontFamily: 'InterExtraBold',
                  fontSize: isWide ? screenHeight / 15 : screenHeight / 20,
                ),
              )
            : Text(
                'SIGN UP',
                style: TextStyle(
                  fontFamily: 'InterExtraBold',
                  fontSize: isWide ? screenHeight / 15 : screenHeight / 20,
                ),
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
                    errorBorder: _inputBorder(),
                    focusedErrorBorder: _inputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
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
                  obscureText: !isVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hoverColor: Colors.white,
                    hint: Text(
                      'Password',
                      style: TextStyle(color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: passwordChange,
                      icon: isVisible
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                    ),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _inputBorder(),
                    errorBorder: _inputBorder(),
                    focusedErrorBorder: _inputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth / 20),
                height: isWide ? screenHeight / 10 : screenHeight / 15,
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
                    FocusScope.of(context).unfocus();
                    isVisible = false;

                    final email = emailController.text.trim().toLowerCase();
                    final password = passwordController.text.trim();

                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Email can't be empty"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    } else if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Password can't be empty"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    emailController.text = '';
                    passwordController.text = '';

                    if (loginFocus) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                          child: CircularProgressIndicator(color: orange),
                        ),
                      );

                      final result = await onLogin(email, password);

                      Navigator.of(context).pop();

                      setParentState(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });

                      if (!result.success) return;

                      final type = await Supabase.instance.client
                          .from('users')
                          .select('role')
                          .eq('email', email)
                          .single();
                      if (type['role'] == 'students') {
                        final profile = await getProfile('students');

                        if (profile == null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  FirstTimeStudentPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => StudentPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      } else if (type['role'] == 'company') {
                        final profile = await getProfile('company');
                        if (profile == null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  FirstTimeCompanyPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => CompanyPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      } else {
                        final profile = await getProfile('admin');

                        if (profile == null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  AdminPage(isFirstTime: true),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  AdminPage(isFirstTime: false),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      }
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(
                          child: CircularProgressIndicator(color: orange),
                        ),
                      );

                      final result = await onSignUp(email, password, userType);

                      Navigator.of(context).pop();

                      setParentState(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
                    }
                  },
                  child: loginFocus
                      ? Text(
                          'LOGIN',
                          style: TextStyle(
                            fontFamily: 'InterExtraBold',
                            fontSize: 16,
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
            ],
          ),
        ),
      ],
    ),
  );
}
