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
    final isWide = screenWidth > 600;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF02243F),
        appBar: null,
        body: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo-no-text.png',
                      height: 32,
                      width: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'InternHub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF04305A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Admin',
                        style: TextStyle(
                          color: const Color(0xFFF2A13B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: firstTime
                    ? _buildFirstTimePage(context, screenWidth, screenHeight, isWide)
                    : homeFocus
                    ? _buildHomePage(context, screenWidth, screenHeight, isWide)
                    : _buildSettingsPage(context, screenWidth, screenHeight, isWide),
              ),
            ],
          ),
        ),
        bottomNavigationBar: firstTime ? null : _buildModernBottomNav(),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04305A).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(true, Icons.home_outlined, 'Home'),
          _buildNavItem(false, Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(bool isHome, IconData icon, String label) {
    final isSelected = homeFocus == isHome;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            homeFocus = isHome;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFF55119) : const Color(0xFF7A8B9A),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFF55119) : const Color(0xFF7A8B9A),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstTimePage(BuildContext context, double screenWidth, double screenHeight, bool isWide) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04305A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF04305A), width: 1),
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
                                        color: Colors.white,
                                      ),
                                      children: [
                                        TextSpan(text: 'Welcome to '),
                                        TextSpan(
                                          text: 'InternHub',
                                          style: TextStyle(
                                            color: const Color(0xFFF55119),
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
                                      color: const Color(0xFFB8C5D1),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 40),
                            Container(
                              width: screenWidth / 3,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Name", style: TextStyle(fontFamily: 'Inter', color: Colors.white)),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF02243F),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF04305A)),
                                      ),
                                      child: TextFormField(
                                        controller: _nameController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Coordinator Name',
                                          hintStyle: TextStyle(color: const Color(0xFF7A8B9A)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [const Color(0xFFF55119), const Color(0xFFF27B12)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextButton(
                                        onPressed: () async {
                                          final name = _nameController.text.trim();

                                          if (name.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Coordinator name can't be empty"),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          final authUser = Supabase.instance.client.auth.currentUser;
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
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          final userId = usersResponse['user_id'];

                                          await Supabase
                                              .instance
                                              .client
                                              .from('admin')
                                              .update({'name': name})
                                              .eq('user_id', userId);

                                          setState(() {
                                            _newNameController.text = name;
                                            firstTime = false;
                                          });
                                        },
                                        child: Text(
                                          'Finish',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
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
                                  color: Colors.white,
                                ),
                                children: [
                                  TextSpan(text: 'Welcome to '),
                                  TextSpan(
                                    text: 'InternHub',
                                    style: TextStyle(
                                      color: const Color(0xFFF55119),
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
                                color: const Color(0xFFB8C5D1),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 30),
                            Container(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Name", style: TextStyle(fontFamily: 'Inter', color: Colors.white)),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF02243F),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF04305A)),
                                      ),
                                      child: TextFormField(
                                        controller: _nameController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Coordinator Name',
                                          hintStyle: TextStyle(color: const Color(0xFF7A8B9A)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [const Color(0xFFF55119), const Color(0xFFF27B12)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextButton(
                                        onPressed: () async {
                                          final name = _nameController.text.trim();

                                          if (name.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Coordinator name can't be empty"),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          final authUser = Supabase.instance.client.auth.currentUser;
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
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          final userId = usersResponse['user_id'];

                                          await Supabase
                                              .instance
                                              .client
                                              .from('admin')
                                              .update({'name': name})
                                              .eq('user_id', userId);

                                          setState(() {
                                            _newNameController.text = name;
                                            firstTime = false;
                                          });
                                        },
                                        child: Text(
                                          'Finish',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomePage(BuildContext context, double screenWidth, double screenHeight, bool isWide) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: _buildAdminCard(
              'Manage Students',
              Icons.people_outline,
              () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ManageUserPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildAdminCard(
              'Manage Companies',
              Icons.business_outlined,
              () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ManageCompanyPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildAdminCard(
              'View Logs',
              Icons.assessment_outlined,
              () {
                // TODO: Implement logs functionality
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String title, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF04305A), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFFF55119),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPage(BuildContext context, double screenWidth, double screenHeight, bool isWide) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildSettingsSection(
            'Login Information',
            Icons.lock_outline,
            [
              _buildSettingsField(
                'Email',
                _emailController,
                isEditingEmail,
                () => setState(() => isEditingEmail = !isEditingEmail),
                emailChanged,
                _updateLoginInfo,
              ),
              _buildPasswordField(
                'New Password',
                _passwordController,
                isEditingPassword,
                () => setState(() => isEditingPassword = !isEditingPassword),
                passwordChanged,
                _updateLoginInfo,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSettingsSection(
            'Personal Information',
            Icons.person_outline,
            [
              _buildSettingsField(
                'Name',
                _newNameController,
                isEditingName,
                () => setState(() => isEditingName = !isEditingName),
                true,
                _updateNameInfo,
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => _showLogoutDialog(),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF04305A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF2A13B), size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsField(
    String label,
    TextEditingController controller,
    bool isEditing,
    VoidCallback onEditToggle,
    bool hasChanges,
    VoidCallback onUpdate,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEditing,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: const Color(0xFFB8C5D1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF04305A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF04305A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFF55119)),
                ),
                filled: true,
                fillColor: const Color(0xFF02243F),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: onEditToggle,
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isEditing ? const Color(0xFFF55119) : const Color(0xFFB8C5D1),
            ),
          ),
          if (isEditing && hasChanges)
            IconButton(
              onPressed: onUpdate,
              icon: Icon(
                Icons.save,
                color: const Color(0xFFF55119),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isEditing,
    VoidCallback onEditToggle,
    bool hasChanges,
    VoidCallback onUpdate,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEditing,
              obscureText: !isPasswordPlain,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: const Color(0xFFB8C5D1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF04305A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF04305A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFFF55119)),
                ),
                filled: true,
                fillColor: const Color(0xFF02243F),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: isEditing
                    ? IconButton(
                        onPressed: () => setState(() => isPasswordPlain = !isPasswordPlain),
                        icon: Icon(
                          isPasswordPlain ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFF55119),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: onEditToggle,
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: isEditing ? const Color(0xFFF55119) : const Color(0xFFB8C5D1),
            ),
          ),
          if (isEditing && hasChanges)
            IconButton(
              onPressed: onUpdate,
              icon: Icon(
                Icons.save,
                color: const Color(0xFFF55119),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updateLoginInfo() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Email can't be empty.");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            email: email,
            password: password.isEmpty ? null : password,
          ),
        );
        _showSnackBar('A confirmation email has been sent to $email. Confirm to change your email.', isSuccess: true);
        setState(() {
          isEditingEmail = false;
          isEditingPassword = false;
        });
      } catch (e) {
        _showSnackBar("Error: $e");
      }
    }
  }

  Future<void> _updateNameInfo() async {
    final name = _newNameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar("Name can't be empty");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    final usersResponse = await Supabase
        .instance
        .client
        .from('users')
        .select('user_id')
        .eq('auth_id', user!.id)
        .maybeSingle();

    final userId = usersResponse!['user_id'];

    try {
      await Supabase
          .instance
          .client
          .from('admin')
          .update({'name': name})
          .eq('user_id', userId);
      _showSnackBar('Successfully updated!', isSuccess: true);
      setState(() {
        isEditingName = false;
      });
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF04305A) : Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF02243F),
          title: Text('Confirm Logout', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to log out?', style: TextStyle(color: const Color(0xFFB8C5D1))),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: const Color(0xFFB8C5D1))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Logout'),
              onPressed: () async {
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
                  _showSnackBar('Failed to log out: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
