import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'package:internhub/screens/adminOperations/manageUser.dart';
import 'package:internhub/screens/adminOperations/manageCompany.dart';

class AdminPage extends StatefulWidget {
  final bool isFirstTime;
  const AdminPage({super.key, required this.isFirstTime});
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool get isFirstTime => widget.isFirstTime;

  late bool firstTime;

  final _formKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newNameController = TextEditingController();

  bool homeFocus = true;

  bool isEditingEmail = false;
  bool isEditingPassword = false;
  bool isEditingName = false;
  bool isPasswordPlain = false;

  bool emailChanged = false;
  bool passwordChanged = false;

  Future<String?> _getAdminName() async {
    final user = Supabase.instance.client.auth.currentUser;

    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user!.id)
        .maybeSingle();

    final userId = usersResponse!['user_id'];

    final nameResponse = await Supabase.instance.client
        .from('admin')
        .select('name')
        .eq('user_id', userId)
        .maybeSingle();

    return nameResponse!['name'];
  }

  Future<void> _loadAdminName() async {
    final name = await _getAdminName();
    if (name != null) _newNameController.text = name;
  }

  @override
  void initState() {
    super.initState();
    firstTime = widget.isFirstTime;

    String? originalName;

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

    _loadAdminName();

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
        appBar: firstTime
            ? PreferredSize(
                preferredSize: Size.fromHeight(screenHeight * 0.08),
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
              )
            : PreferredSize(
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
        body: firstTime
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth / 10,
                        ),
                        child: Center(
                          child: _firstTime(
                            context,
                            screenWidth,
                            screenHeight,
                            _formKey,
                            orange,
                            isWide,
                            _nameController,
                            () => setState(() {
                              firstTime = false;
                            }),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth / 10),
                child: homeFocus
                    ? _homePage(
                        context,
                        screenWidth,
                        screenHeight,
                        orange,
                        isWide,
                      )
                    : _settingsPage(
                        context,
                        screenWidth,
                        screenHeight,
                        orange,
                        isWide,
                        _emailController,
                        _passwordController,
                        _newNameController,
                        _loginFormKey,
                        _nameFormKey,
                        isEditingEmail,
                        isEditingPassword,
                        isEditingName,
                        isPasswordPlain,
                        emailChanged,
                        passwordChanged,
                        () => setState(() {
                          isEditingEmail = !isEditingEmail;
                        }),
                        () => setState(() {
                          isEditingPassword = !isEditingPassword;
                        }),
                        () => setState(() {
                          isEditingName = !isEditingName;
                        }),
                        () => setState(() {
                          isPasswordPlain = !isPasswordPlain;
                        }),
                      ),
              ),
        bottomNavigationBar: Container(
          height: screenHeight * 0.08,
          color: orange,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: homeFocus ? selectedOrange : orange,
                    minimumSize: Size(screenHeight, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: homeFocus
                      ? null
                      : () {
                          setState(() {
                            homeFocus = true;
                          });
                        },
                  child: Icon(Icons.home, color: Colors.white, size: 25),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: homeFocus ? orange : selectedOrange,
                    minimumSize: Size(screenHeight, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: homeFocus
                      ? () {
                          setState(() {
                            homeFocus = false;
                          });
                        }
                      : null,
                  child: Icon(Icons.settings, color: Colors.white, size: 25),
                ),
              ),
            ],
          ),
        ),
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
  nameController,
  VoidCallback changeFirstTime,
) {
  return Container(
    width: double.infinity,
    height: screenHeight / 1.5,
    padding: EdgeInsets.symmetric(horizontal: isWide ? screenWidth * 0.02 : 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        isWide
            ? BoxShadow(
                color: Color(0x88888888),
                offset: Offset(1, 5),
                blurRadius: 10,
                spreadRadius: 2,
              )
            : BoxShadow(),
      ],
    ),
    child: isWide
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: screenHeight / 15,
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
                    SizedBox(height: 10),
                    Text(
                      'Manage users, posts, and progress all in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight / 30,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20, width: 20),
              Container(
                width: screenWidth / 3,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Name", style: TextStyle(fontFamily: 'Inter')),
                      SizedBox(height: 10),
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
                          controller: nameController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hoverColor: Colors.white,
                            hint: Text(
                              'Coordinator Name',
                              style: TextStyle(color: Colors.grey),
                            ),
                            border: _inputBorder(),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            errorBorder: _inputBorder(),
                            focusedErrorBorder: _inputBorder(),
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
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
                            width: screenWidth / 10,
                            height: screenHeight / 10,
                            child: TextButton(
                              onPressed: () async {
                                final name = nameController.text.trim();

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Coordinator name can't be empty",
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                final authUser =
                                    Supabase.instance.client.auth.currentUser;
                                if (authUser == null) return;

                                final usersResponse = await Supabase
                                    .instance
                                    .client
                                    .from('users')
                                    .select('user_id')
                                    .eq('auth_id', authUser.id)
                                    .maybeSingle();

                                if (usersResponse == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Something went wrong."),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }

                                final userId = usersResponse!['user_id'];

                                final updateResponse = await Supabase
                                    .instance
                                    .client
                                    .from('admin')
                                    .update({'name': name})
                                    .eq('user_id', userId);

                                changeFirstTime();
                              },
                              child: Text(
                                'Finish',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: screenHeight / 25,
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
              SizedBox(height: 10),
              Text(
                'Manage users, posts, and progress all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight / 60,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Name", style: TextStyle(fontFamily: 'Inter')),
                      SizedBox(height: 10),
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
                          controller: nameController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hoverColor: Colors.white,
                            hint: Text(
                              'Coordinator Name',
                              style: TextStyle(color: Colors.grey),
                            ),
                            border: _inputBorder(),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            errorBorder: _inputBorder(),
                            focusedErrorBorder: _inputBorder(),
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
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
                            width: screenWidth / 5,
                            height: screenHeight / 17.5,
                            child: TextButton(
                              onPressed: () async {
                                final name = nameController.text.trim();

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Coordinator name can't be empty",
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                final authUser =
                                    Supabase.instance.client.auth.currentUser;
                                if (authUser == null) return;

                                final usersResponse = await Supabase
                                    .instance
                                    .client
                                    .from('users')
                                    .select('user_id')
                                    .eq('auth_id', authUser.id)
                                    .maybeSingle();

                                if (usersResponse == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Something went wrong."),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }

                                final userId = usersResponse!['user_id'];

                                final updateResponse = await Supabase
                                    .instance
                                    .client
                                    .from('admin')
                                    .update({'name': name})
                                    .eq('user_id', userId);

                                changeFirstTime();
                              },
                              child: Text(
                                'Finish',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
  );
}

Widget _homePage(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  orange,
  bool isWide,
) {
  return Container(
    height: double.infinity,
    padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
    child: Column(
      spacing: 10,
      children: [
        Expanded(
          child: Material(
            color: Colors.white,
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                print('Manage Users clicked!');
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ManageUserPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Manage Students',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: Colors.white,
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                print('Manage Companies clicked!');
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ManageCompanyPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Manage Companies',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: Colors.white,
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                print('View Logs clicked!');
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'View Logs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _settingsPage(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  orange,
  bool isWide,
  TextEditingController emailController,
  TextEditingController passwordController,
  TextEditingController newNameController,
  loginFormKey,
  nameFormKey,
  bool isEditingEmail,
  bool isEditingPassword,
  bool isEditingName,
  bool isPasswordPlain,
  bool emailChanged,
  bool passwordChanged,
  VoidCallback editEmailChange,
  VoidCallback editPasswordChange,
  VoidCallback editNameChange,
  VoidCallback passwordVisibilityChange,
) {
  return SingleChildScrollView(
    padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        Text(
          'Edit Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Material(
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 10
                              : screenHeight / 20,
                          child: TextFormField(
                            controller: emailController,
                            enabled: isEditingEmail,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              floatingLabelStyle: TextStyle(
                                color: isEditingEmail ? orange : null,
                              ),
                              border: _inputBorder(),
                              enabledBorder: _inputBorder(),
                              focusedBorder: _inputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => editEmailChange(),
                        icon: Icon(
                          isEditingEmail ? Icons.edit_off : Icons.edit,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 10
                              : screenHeight / 20,
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: !isPasswordPlain,
                            enabled: isEditingPassword,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              floatingLabelStyle: TextStyle(color: orange),
                              border: _inputBorder(),
                              enabledBorder: _inputBorder(),
                              focusedBorder: _inputBorder(),
                              contentPadding: EdgeInsets.all(10),
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: passwordVisibilityChange,
                                icon: Icon(
                                  isPasswordPlain
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: isEditingPassword
                                      ? orange
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => editPasswordChange(),
                        icon: Icon(
                          isEditingPassword ? Icons.edit_off : Icons.edit,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed:
                          ((isEditingEmail && emailChanged) ||
                              (isEditingPassword && passwordChanged))
                          ? () async {
                              bool valid = false;

                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();

                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Email can't be empty."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              if (user != null) {
                                try {
                                  final emailResponse = await Supabase
                                      .instance
                                      .client
                                      .auth
                                      .updateUser(
                                        UserAttributes(
                                          email: email,
                                          password: password.isEmpty
                                              ? null
                                              : password,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'A confirmation email has been sent to $email. Confirm to change your email.',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  valid = true;
                                } on AuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.message),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                              if (valid) {
                                if (isEditingEmail) editEmailChange();
                                if (isEditingPassword) editPasswordChange();
                              }
                            }
                          : null,
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color:
                              ((isEditingEmail && emailChanged) ||
                                  (isEditingPassword && passwordChanged))
                              ? Colors.black
                              : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Material(
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: nameFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 10
                              : screenHeight / 20,
                          child: TextFormField(
                            controller: newNameController,
                            enabled: isEditingName,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              floatingLabelStyle: TextStyle(
                                color: isEditingName ? orange : null,
                              ),
                              border: _inputBorder(),
                              enabledBorder: _inputBorder(),
                              focusedBorder: _inputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => editNameChange(),
                        icon: Icon(
                          isEditingName ? Icons.edit_off : Icons.edit,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: isEditingName
                          ? () async {
                              final name = newNameController.text.trim();

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              final usersResponse = await Supabase
                                  .instance
                                  .client
                                  .from('users')
                                  .select('user_id')
                                  .eq('auth_id', user!.id)
                                  .maybeSingle();

                              final userId = usersResponse!['user_id'];

                              try {
                                final nameResponse = await Supabase
                                    .instance
                                    .client
                                    .from('admin')
                                    .update({'name': name})
                                    .eq('user_id', userId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Successfully updated!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } on AuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.message),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                              editNameChange();
                            }
                          : null,
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color:
                              isEditingName
                              ? Colors.black
                              : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Material(
          color: orange,
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              try {
                await Supabase.instance.client.auth.signOut();

                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => LoginPage(),
                    transitionDuration: Duration.zero,
                  ),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to log out: $e'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Log out',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
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
