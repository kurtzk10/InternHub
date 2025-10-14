import 'package:flutter/material.dart';
import 'package:internhub/screens/studentPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';

enum Step { name, uni, resume, finished }

class FirstTimeStudentPage extends StatefulWidget {
  @override
  _FirstTimeStudentPageState createState() => _FirstTimeStudentPageState();
}

class _FirstTimeStudentPageState extends State<FirstTimeStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _yearController = TextEditingController();
  final _courseController = TextEditingController();
  final _urlController = TextEditingController();

  Map<String, dynamic>? studentProfile;

  Step step = Step.name;

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
                      _firstController,
                      _lastController,
                      _yearController,
                      _courseController,
                      _urlController,
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
                              transitionDuration: Duration.zero
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
  firstController,
  lastController,
  yearController,
  courseController,
  urlController,
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
                      'Please complete your profile information to unlock internship opportunities and connect with potential employers.',
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
              step == Step.name
                  ? _nameForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      firstController,
                      lastController,
                      onStepChange,
                    )
                  : step == Step.uni
                  ? _uniForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      yearController,
                      courseController,
                      onStepChange,
                    )
                  : step == Step.resume
                  ? _resumeForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      urlController,
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
                'Please complete your profile information to unlock internship opportunities and connect with potential employers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight / 60,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              step == Step.name
                  ? _nameForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      firstController,
                      lastController,
                      onStepChange,
                    )
                  : step == Step.uni
                  ? _uniForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      yearController,
                      courseController,
                      onStepChange,
                    )
                  : step == Step.resume
                  ? _resumeForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      urlController,
                      onStepChange,
                    )
                  : _nameForm(
                      context,
                      screenWidth,
                      screenHeight,
                      formKey,
                      orange,
                      isWide,
                      firstController,
                      lastController,
                      onStepChange,
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

Widget _nameForm(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  formKey,
  orange,
  bool isWide,
  firstController,
  lastController,
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
                    controller: firstController,
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
                    controller: lastController,
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
                          final fName = firstController.text.trim();
                          final lName = lastController.text.trim();

                          if (fName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("First name can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (lName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Last name can't be empty"),
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

                          final fullName = '$fName $lName';

                          final updateResponse = await Supabase.instance.client
                              .from('students')
                              .update({'name': fullName})
                              .eq('user_id', userId);

                          onStepChange(Step.uni);
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
                    controller: firstController,
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
                    controller: lastController,
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
                          final fName = firstController.text.trim();
                          final lName = lastController.text.trim();

                          if (fName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("First name can't be empty"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          } else if (lName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Last name can't be empty"),
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

                          final fullName = '$fName $lName';

                          final updateResponse = await Supabase.instance.client
                              .from('students')
                              .update({'name': fullName})
                              .eq('user_id', userId);

                          onStepChange(Step.uni);
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

Widget _uniForm(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  formKey,
  orange,
  bool isWide,
  yearController,
  courseController,
  Function(Step) onStepChange,
) {
  return isWide
      ? Container(
          width: screenWidth / 3,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'University Information',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
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
                  ),
                  child: DropdownMenu<String>(
                    controller: yearController,
                    width: screenWidth / 3,
                    inputDecorationTheme: InputDecorationTheme(
                      constraints: BoxConstraints.tight(
                        Size.fromHeight(screenHeight / 9),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                    ),
                    label: Text('Year Level'),
                    textStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: screenHeight / 30,
                    ),
                    dropdownMenuEntries: <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: '1', label: '1st Year'),
                      DropdownMenuEntry(value: '2', label: '2nd Year'),
                      DropdownMenuEntry(value: '3', label: '3rd Year'),
                      DropdownMenuEntry(value: '4', label: '4th Year'),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
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
                  ),
                  child: DropdownMenu<String>(
                    controller: courseController,
                    width: screenWidth / 3,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                      constraints: BoxConstraints.tight(
                        Size.fromHeight(screenHeight / 9),
                      ),
                    ),
                    label: Text('Course'),
                    textStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: screenHeight / 30,
                    ),
                    dropdownMenuEntries: <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: 'NetAd', label: 'NetAd'),
                      DropdownMenuEntry(value: 'WebDev', label: 'WebDev'),
                      DropdownMenuEntry(value: 'EMC', label: 'EMC'),
                      DropdownMenuEntry(value: 'ComSci', label: 'ComSci'),
                      DropdownMenuEntry(
                        value: 'Cybersecurity',
                        label: 'Cybersecurity',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: screenWidth / 3,
                  child: Row(
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
                            onStepChange(Step.name);
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
                            final yr = yearController.text;
                            final course = courseController.text;

                            int year = yr == '1st Year'
                                ? 1
                                : yr == '2nd Year'
                                ? 2
                                : yr == '3rd Year'
                                ? 3
                                : 4;

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

                            final updateResponse = await Supabase
                                .instance
                                .client
                                .from('students')
                                .update({'yr_level': year, 'course': course})
                                .eq('user_id', userId);

                            onStepChange(Step.resume);
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
                ),
              ],
            ),
          ),
        )
      : Container(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'University Information',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
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
                  ),
                  child: DropdownMenu<String>(
                    controller: yearController,
                    inputDecorationTheme: InputDecorationTheme(
                      constraints: BoxConstraints.tight(
                        Size.fromHeight(screenHeight / 15),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                    ),
                    width: screenWidth,
                    label: Text('Year Level'),
                    textStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: screenHeight / 50,
                    ),
                    dropdownMenuEntries: <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: '1', label: '1st Year'),
                      DropdownMenuEntry(value: '2', label: '2nd Year'),
                      DropdownMenuEntry(value: '3', label: '3rd Year'),
                      DropdownMenuEntry(value: '4', label: '4th Year'),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
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
                  ),
                  child: DropdownMenu<String>(
                    controller: courseController,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                      constraints: BoxConstraints.tight(
                        Size.fromHeight(screenHeight / 15),
                      ),
                    ),
                    width: screenWidth,
                    label: Text('Course'),
                    textStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: screenHeight / 50,
                    ),
                    dropdownMenuEntries: <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: 'NetAd', label: 'NetAd'),
                      DropdownMenuEntry(value: 'WebDev', label: 'WebDev'),
                      DropdownMenuEntry(value: 'EMC', label: 'EMC'),
                      DropdownMenuEntry(value: 'ComSci', label: 'ComSci'),
                      DropdownMenuEntry(
                        value: 'Cybersecurity',
                        label: 'Cybersecurity',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
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
                            onStepChange(Step.name);
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
                            final yr = yearController.text;
                            final course = courseController.text;

                            int year = yr == '1st Year'
                                ? 1
                                : yr == '2nd Year'
                                ? 2
                                : yr == '3rd Year'
                                ? 3
                                : 4;

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

                            final updateResponse = await Supabase
                                .instance
                                .client
                                .from('students')
                                .update({'yr_level': year, 'course': course})
                                .eq('user_id', userId);

                            onStepChange(Step.resume);
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
                ),
              ],
            ),
          ),
        );
}

Widget _resumeForm(
  BuildContext context,
  double screenWidth,
  double screenHeight,
  formKey,
  orange,
  bool isWide,
  urlController,
  Function(Step) onStepChange,
) {
  return isWide
      ? Container(
          width: screenWidth / 3,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Resume Link', style: TextStyle(fontFamily: 'Inter')),
                SizedBox(height: 20),
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
                    controller: urlController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Resume Link',
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
                  width: screenWidth / 3,
                  child: Row(
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
                            onStepChange(Step.uni);
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
                            final resume = urlController.text.trim().toLowerCase();

                            if (resume.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Field can't be empty."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            final pattern =
                                r'^(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9\-\_]+\/?$';
                            final regex = RegExp(pattern);

                            if (!regex.hasMatch(resume)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Must be a valid LinkedIn link.",
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

                            final updateResponse = await Supabase
                                .instance
                                .client
                                .from('students')
                                .update({'resume_url': resume})
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
                ),
              ],
            ),
          ),
        )
      : Container(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Resume Link', style: TextStyle(fontFamily: 'Inter')),
                SizedBox(height: 20),
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
                    controller: urlController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hoverColor: Colors.white,
                      hint: Text(
                        'Resume Link',
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
                  child: Row(
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
                            onStepChange(Step.uni);
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
                            final resume = urlController.text.trim();

                            if (resume.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Field can't be empty."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            final pattern =
                                r'^(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9\-\_]+\/?$';
                            final regex = RegExp(pattern);

                            if (!regex.hasMatch(resume)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Must be a valid LinkedIn link.",
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

                            final updateResponse = await Supabase
                                .instance
                                .client
                                .from('students')
                                .update({'resume_url': resume})
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
                ),
              ],
            ),
          ),
        );
}
