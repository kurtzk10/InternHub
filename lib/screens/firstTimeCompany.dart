import 'package:flutter/material.dart';
import 'package:internhub/screens/studentPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:flutter/services.dart';

enum Step { company, person, finished }

class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(' ', '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    StringBuffer buffer = StringBuffer();
    int selectionIndex = newValue.selection.baseOffset;
    int usedDigits = 0;

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      usedDigits++;

      if (i == 3 || i == 6) {
        if (i != digits.length - 1) {
          buffer.write(' ');
          if (i < selectionIndex) {
            selectionIndex++;
          }
        }
      }
    }

    selectionIndex = selectionIndex.clamp(0, buffer.length);

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}


class FirstTimeCompanyPage extends StatefulWidget {
  @override
  _FirstTimeCompanyPageState createState() => _FirstTimeCompanyPageState();
}

class _FirstTimeCompanyPageState extends State<FirstTimeCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();

  Map<String, dynamic>? studentProfile;

  Step step = Step.company;

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 10),
                  child: Center(
                    child: _firstTime(
                      context,
                      screenWidth,
                      screenHeight,
                      _formKey,
                      orange,
                      isWide,
                      _nameController,
                      _industryController,
                      _numberController,
                      _emailController,
                      step,
                      (Step value) {
                        setState(() {
                          step = value;
                        });

                        if (value == Step.finished) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => StudentPage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
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
  industryController,
  numberController,
  emailController,
  step,
  Function(Step) onStepChange,
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
                      'We’re excited to have your company with us. Use InternHub to share opportunities, discover bright students, and help shape the next generation of professionals.',
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
              SizedBox(width: 20),
              step == Step.company
                  ? _companyForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      nameController,
                      industryController,
                      onStepChange,
                    )
                  : step == Step.person
                  ? _personForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      numberController,
                      emailController,
                      onStepChange,
                    )
                  : Container(),
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
                'We’re excited to have your company with us. Use InternHub to share opportunities, discover bright students, and help shape the next generation of professionals.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight / 60,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              step == Step.company
                  ? _companyForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      nameController,
                      industryController,
                      onStepChange,
                    )
                  : step == Step.person
                  ? _personForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      numberController,
                      emailController,
                      onStepChange,
                    )
                  : Container(),
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

Widget _companyForm(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  formKey,
  orange,
  bool isWide,
  nameController,
  industryController,
  Function(Step) onStepChange,
) {
  return isWide
      ? Container(
          width: screenWidth / 3,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Company Information",
                  style: TextStyle(fontFamily: 'Inter'),
                ),
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
                        'Company Name',
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
                    controller: industryController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Type of Industry',
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
                          final industry = industryController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Company name can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (industry.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Type of industry can't be empty",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final authUser =
                              Supabase.instance.client.auth.currentUser;
                          if (authUser == null) return;

                          final usersResponse = await Supabase.instance.client
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

                          final updateResponse = await Supabase.instance.client
                              .from('company')
                              .update({'name': name, 'industry': industry})
                              .eq('user_id', userId);

                          onStepChange(Step.person);
                        },
                        child: Text(
                          'Next',
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
        )
      : Container(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Company Information",
                  style: TextStyle(fontFamily: 'Inter'),
                ),
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
                        'Company Name',
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
                    controller: industryController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Type of Industry',
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
                          final industry = industryController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Company name can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (industry.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Type of industry can't be empty",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final authUser =
                              Supabase.instance.client.auth.currentUser;
                          if (authUser == null) return;

                          final usersResponse = await Supabase.instance.client
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

                          final updateResponse = await Supabase.instance.client
                              .from('company')
                              .update({'name': name, 'industry': industry})
                              .eq('user_id', userId);

                          onStepChange(Step.person);
                        },
                        child: Text(
                          'Next',
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
        );
}

Widget _personForm(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  formKey,
  orange,
  bool isWide,
  numberController,
  emailController,
  Function(Step) onStepChange,
) {
  return isWide
      ? Container(
          width: screenWidth / 3,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Contact Information",
                  style: TextStyle(fontFamily: 'Inter'),
                ),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [NumberFormatter()],
                    controller: numberController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Contact Number',
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
                      hint: Text(
                        'Contact Email',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: screenWidth / 10,
                      height: screenHeight / 10,

                      child: TextButton(
                        onPressed: () {
                          onStepChange(Step.company);
                        },
                        child: Text('Back', style: TextStyle(color: orange)),
                      ),
                    ),
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
                          final number = numberController.text.replaceAll(' ', '');
                          final email = emailController.text.trim();

                          if (number.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Contact number can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Contact email can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (!emailRegex.hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid email format."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final authUser =
                              Supabase.instance.client.auth.currentUser;
                          if (authUser == null) return;

                          final usersResponse = await Supabase.instance.client
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

                          final updateResponse = await Supabase.instance.client
                              .from('company')
                              .update({
                                'contact_number': number,
                                'contact_email': email,
                              })
                              .eq('user_id', userId);

                          onStepChange(Step.finished);
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
        )
      : Container(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Contact Information",
                  style: TextStyle(fontFamily: 'Inter'),
                ),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [NumberFormatter()],
                    controller: numberController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Contact Number',
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
                      hint: Text(
                        'Contact Email',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: screenWidth / 5,
                      height: screenHeight / 17.5,

                      child: TextButton(
                        onPressed: () {
                          onStepChange(Step.company);
                        },
                        child: Text('Back', style: TextStyle(color: orange)),
                      ),
                    ),
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
                          final number = numberController.text.trim();
                          final email = emailController.text.trim();

                          if (number.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Contact number can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Contact email can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (!emailRegex.hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid email format."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final authUser =
                              Supabase.instance.client.auth.currentUser;
                          if (authUser == null) return;

                          final usersResponse = await Supabase.instance.client
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

                          final updateResponse = await Supabase.instance.client
                              .from('company')
                              .update({
                                'contact_number': number,
                                'contact_email': email,
                              })
                              .eq('user_id', userId);

                          onStepChange(Step.finished);
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
        );
}
