import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestUsersPage extends StatefulWidget {
  @override
  _TestUsersPageState createState() => _TestUsersPageState();
}

class _TestUsersPageState extends State<TestUsersPage> {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _showCredentials = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02243F),
      appBar: AppBar(
        title: Text('Test Users Setup'),
        backgroundColor: const Color(0xFF02243F),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF04305A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Users Setup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create test users for Student, Company, and Admin roles for testing purposes.',
                    style: TextStyle(
                      color: const Color(0xFFB8C5D1),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅') 
                      ? Colors.green.withOpacity(0.1)
                      : _statusMessage.contains('❌')
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF04305A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusMessage.contains('✅') 
                        ? Colors.green
                        : _statusMessage.contains('❌')
                        ? Colors.red
                        : const Color(0xFF04305A),
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            
            SizedBox(height: 20),
            
            // Create Users Button
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
                onPressed: _isLoading ? null : _createTestUsers,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Create Test Users',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Show Credentials Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF55119),
                side: BorderSide(color: const Color(0xFFF55119)),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _showCredentials = !_showCredentials;
                });
              },
              child: Text(_showCredentials ? 'Hide Credentials' : 'Show Credentials'),
            ),
            
            SizedBox(height: 20),
            
            // Credentials Display
            if (_showCredentials)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF04305A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test User Credentials',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    _buildCredentialCard(
                      '👨‍🎓 STUDENT USER',
                      'student@internhub.test',
                      'student123',
                      'Browse listings, apply to jobs, manage profile',
                      const Color(0xFF4CAF50),
                    ),
                    
                    SizedBox(height: 12),
                    
                    _buildCredentialCard(
                      '🏢 COMPANY USER',
                      'company@internhub.test',
                      'company123',
                      'Create listings, view applicants, manage company profile',
                      const Color(0xFF2196F3),
                    ),
                    
                    SizedBox(height: 12),
                    
                    _buildCredentialCard(
                      '👨‍💼 ADMIN USER',
                      'admin@internhub.test',
                      'admin123',
                      'Manage users, companies, view logs, system administration',
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ),
            
            Spacer(),
            
            // Warning
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These are test accounts for development purposes only.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialCard(String role, String email, String password, String features, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Email: $email',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            'Password: $password',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Features: $features',
            style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _createTestUsers() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      _statusMessage = '🚀 Starting test users setup...\n';
      setState(() {});

      // Create Student User
      _statusMessage += '👨‍🎓 Creating Student user...\n';
      setState(() {});
      await _createStudentUser();

      // Create Company User
      _statusMessage += '🏢 Creating Company user...\n';
      setState(() {});
      await _createCompanyUser();

      // Create Admin User
      _statusMessage += '👨‍💼 Creating Admin user...\n';
      setState(() {});
      await _createAdminUser();

      _statusMessage += '\n✅ All test users created successfully!';
      
    } catch (e) {
      _statusMessage += '\n❌ Error: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createStudentUser() async {
    try {
      // Create auth user
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: 'student@internhub.test',
        password: 'student123',
        data: {
          'user_type': 'student',
          'name': 'John Student',
        },
      );

      if (authResponse.user == null) {
        _statusMessage += '⚠️ Student user might already exist, skipping...\n';
        return;
      }

      final userId = authResponse.user!.id;

      // Insert into users table
      await Supabase.instance.client.from('users').insert({
        'auth_id': userId,
        'user_type': 'student',
      });

      // Get the user_id from users table
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('user_id')
          .eq('auth_id', userId)
          .single();

      final userTableId = userResponse['user_id'];

      // Insert into students table
      await Supabase.instance.client.from('students').insert({
        'user_id': userTableId,
        'name': 'John Student',
        'course': 'Computer Science',
        'year_level': '3',
        'resume_link': 'https://example.com/john-resume.pdf',
        'about_me': 'Passionate computer science student with interests in web development and machine learning.',
        'skills': 'Flutter, Dart, JavaScript, Python, React',
        'phone': '09123456789',
        'linkedin_url': 'https://linkedin.com/in/johnstudent',
        'github_url': 'https://github.com/johnstudent',
        'portfolio_url': 'https://johnstudent.dev',
        'location': 'Manila, Philippines',
      });

      _statusMessage += '✅ Student user created\n';
    } catch (e) {
      _statusMessage += '❌ Student user error: $e\n';
    }
  }

  Future<void> _createCompanyUser() async {
    try {
      // Create auth user
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: 'company@internhub.test',
        password: 'company123',
        data: {
          'user_type': 'company',
          'name': 'TechCorp Solutions',
        },
      );

      if (authResponse.user == null) {
        _statusMessage += '⚠️ Company user might already exist, skipping...\n';
        return;
      }

      final userId = authResponse.user!.id;

      // Insert into users table
      await Supabase.instance.client.from('users').insert({
        'auth_id': userId,
        'user_type': 'company',
      });

      // Get the user_id from users table
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('user_id')
          .eq('auth_id', userId)
          .single();

      final userTableId = userResponse['user_id'];

      // Insert into company table
      await Supabase.instance.client.from('company').insert({
        'user_id': userTableId,
        'name': 'TechCorp Solutions',
        'industry': 'Technology',
        'contact_email': 'hr@techcorp.test',
        'contact_number': '09123456789',
        'is_verified': true, // Set as verified for testing
      });

      _statusMessage += '✅ Company user created\n';
    } catch (e) {
      _statusMessage += '❌ Company user error: $e\n';
    }
  }

  Future<void> _createAdminUser() async {
    try {
      // Create auth user
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: 'admin@internhub.test',
        password: 'admin123',
        data: {
          'user_type': 'admin',
          'name': 'Admin Coordinator',
        },
      );

      if (authResponse.user == null) {
        _statusMessage += '⚠️ Admin user might already exist, skipping...\n';
        return;
      }

      final userId = authResponse.user!.id;

      // Insert into users table
      await Supabase.instance.client.from('users').insert({
        'auth_id': userId,
        'user_type': 'admin',
      });

      // Get the user_id from users table
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('user_id')
          .eq('auth_id', userId)
          .single();

      final userTableId = userResponse['user_id'];

      // Insert into admin table
      await Supabase.instance.client.from('admin').insert({
        'user_id': userTableId,
        'name': 'Admin Coordinator',
      });

      _statusMessage += '✅ Admin user created\n';
    } catch (e) {
      _statusMessage += '❌ Admin user error: $e\n';
    }
  }
}
