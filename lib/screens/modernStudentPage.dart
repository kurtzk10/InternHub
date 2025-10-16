import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'dart:async';

enum Focus { home, applied, profile, settings }

class ModernStudentPage extends StatefulWidget {
  @override
  _ModernStudentPageState createState() => _ModernStudentPageState();
}

class _ModernStudentPageState extends State<ModernStudentPage> {
  final _searchController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _skillsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Settings controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _resumeController = TextEditingController();
  final _courseController = TextEditingController();
  final _yrController = TextEditingController();
  
  // Settings form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _personalFormKey = GlobalKey<FormState>();
  final _uniFormKey = GlobalKey<FormState>();

  Focus focus = Focus.home;
  Map<String, dynamic>? studentDetails;
  List<dynamic> _results = [];
  List<dynamic> _applied = [];
  Timer? _debounce;
  bool _loading = false;
  bool _isEditingProfile = false;
  final supabase = Supabase.instance.client;
  
  // Settings editing states
  bool isEditingEmail = false;
  bool isEditingPassword = false;
  bool isEditingName = false;
  bool isEditingResume = false;
  bool isEditingCourse = false;
  bool isEditingYr = false;
  bool isVisible = false;
  
  // Settings change states
  bool emailChanged = false;
  bool passwordChanged = false;
  bool nameChanged = false;
  bool resumeChanged = false;
  bool courseChanged = false;
  bool yrChanged = false;

  Map<String, bool> activeFilters = {
    'name': false,
    'industry': false,
    'location': false,
    'position': false,
  };

  @override
  void initState() {
    super.initState();
    _getStudentDetails();
    _searchController.addListener(_onSearchChanged);
    
    // Initialize email controller
    final user = supabase.auth.currentUser;
    final userEmail = user?.email;
    _emailController.text = userEmail ?? '';
    
    // Add listeners for settings
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
    
    _nameController.addListener(() {
      setState(() {
        nameChanged = _nameController.text.trim() != (studentDetails?['name'] ?? '');
      });
    });
    
    _resumeController.addListener(() {
      setState(() {
        resumeChanged = _resumeController.text.trim() != (studentDetails?['resume_url'] ?? '');
      });
    });
    
    _courseController.addListener(() {
      setState(() {
        courseChanged = _courseController.text.trim() != (studentDetails?['course'] ?? '');
      });
    });
    
    _yrController.addListener(() {
      setState(() {
        yrChanged = _yrController.text.trim() != (studentDetails?['yr_level']?.toString() ?? '');
      });
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
      getListings();
      getAppliedListings();
      _checkProfileCompletion();
    });
  }

  Future<void> _checkProfileCompletion() async {
    // Wait a bit for student details to load
    await Future.delayed(Duration(milliseconds: 500));
    
    if (studentDetails != null && (studentDetails!['name'] == null || studentDetails!['name'].toString().trim().isEmpty)) {
      _showProfileSetupDialog();
    }
  }

  void _showProfileSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF02243F),
          title: Text(
            'Complete Your Profile',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Please complete your profile information to unlock all features.',
            style: TextStyle(color: const Color(0xFFB8C5D1)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  focus = Focus.profile;
                });
              },
              child: Text(
                'Complete Profile',
                style: TextStyle(color: const Color(0xFFF55119)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getStudentDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final usersResponse = await Supabase.instance.client
          .from('users')
          .select('user_id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (usersResponse == null) {
        print('User not found in users table');
        return;
      }

      final userId = usersResponse['user_id'];

      final student = await Supabase.instance.client
          .from('students')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (student != null) {
        setState(() {
          studentDetails = student;
          _aboutMeController.text = student['about_me'] ?? '';
          _skillsController.text = (student['skills'] as List?)?.join(', ') ?? '';
          _phoneController.text = student['phone_number'] ?? '';
          _linkedinController.text = student['linkedin_url'] ?? '';
          _githubController.text = student['github_url'] ?? '';
          _portfolioController.text = student['portfolio_url'] ?? '';
          _locationController.text = student['location'] ?? '';
          
          // Settings controllers
          _nameController.text = student['name'] ?? '';
          _resumeController.text = student['resume_url'] ?? '';
          _courseController.text = student['course'] ?? '';
          _yrController.text = student['yr_level']?.toString() ?? '';
        });
      } else {
        print('Student profile not found');
        // Create a basic student profile
        setState(() {
          studentDetails = {
            'student_id': null,
            'name': null,
            'about_me': null,
            'skills': null,
            'phone_number': null,
            'linkedin_url': null,
            'github_url': null,
            'portfolio_url': null,
            'location': null,
            'resume_url': null,
            'course': null,
            'yr_level': null,
          };
        });
      }
    } catch (e) {
      print('Error fetching student details: $e');
      // Set empty details on error
      setState(() {
        studentDetails = {
          'student_id': null,
          'name': null,
          'about_me': null,
          'skills': null,
          'phone_number': null,
          'linkedin_url': null,
          'github_url': null,
          'portfolio_url': null,
          'location': null,
          'resume_url': null,
          'course': null,
          'yr_level': null,
        };
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loading = true);

      if (studentDetails == null) {
        setState(() => _loading = false);
        return;
      }

      final queryText = _searchController.text.trim();
      
      if (studentDetails == null || studentDetails!['student_id'] == null) {
        setState(() {
          _results = [];
          _loading = false;
        });
        return;
      }
      
      final applied = await supabase
          .from('application')
          .select('listing_id')
          .eq('student_id', studentDetails!['student_id']);

      final appliedListingIds = applied
          .map((app) => app['listing_id'])
          .toList();

      var query = supabase.from('listing').select('*, company:company(*)');

      if (appliedListingIds.isNotEmpty) {
        query = query.not(
          'listing_id',
          'in',
          '(${appliedListingIds.join(',')})',
        );
      }

      if (queryText.isNotEmpty) {
        List<String> conditions = [];
        if (activeFilters['name'] == true) {
          conditions.add('company.name.ilike.%$queryText%');
        }
        if (activeFilters['industry'] == true) {
          conditions.add('company.industry.ilike.%$queryText%');
        }
        if (activeFilters['location'] == true) {
          conditions.add('location.ilike.%$queryText%');
        }
        if (activeFilters['position'] == true) {
          conditions.add('position.ilike.%$queryText%');
        }

        if (conditions.isNotEmpty) query = query.or(conditions.join(','));
      }

      final response = await query;
      setState(() {
        _results = response as List<dynamic>;
        _loading = false;
      });
    });
  }

  Future<void> getListings() async {
    _onSearchChanged();
  }

  Future<void> getAppliedListings() async {
    if (studentDetails == null || studentDetails!['student_id'] == null) {
      setState(() {
        _applied = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final applications = await supabase
          .from('application')
          .select()
          .eq('student_id', studentDetails!['student_id']);

      final appliedListingIds = applications
          .map((app) => app['listing_id'])
          .toList();

      if (appliedListingIds.isEmpty) {
        setState(() {
          _applied = [];
          _loading = false;
        });
        return;
      }

      final listings = await supabase
          .from('listing')
          .select('*, company:company(*)')
          .inFilter('listing_id', appliedListingIds);

      final appliedWithStatus = <Map<String, dynamic>>[];
      
      for (var listing in listings) {
        final application = applications.firstWhere(
          (app) => app['listing_id'] == listing['listing_id'],
        );
        
        final listingData = {
          'listing_id': listing['listing_id'],
          'title': listing['title'],
          'position': listing['position'],
          'location': listing['location'],
          'duration': listing['duration'],
          'description': listing['description'],
          'requirements': listing['requirements'],
          'link': listing['link'],
          'company': {
            'company_id': listing['company']['company_id'],
            'name': listing['company']['name'],
            'industry': listing['company']['industry'],
            'contact_email': listing['company']['contact_email'],
            'contact_number': listing['company']['contact_number'],
          },
          'application_status': application['status'],
        };
        
        appliedWithStatus.add(listingData);
      }

      setState(() {
        _applied = appliedWithStatus;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching applied listings: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    try {
      final skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if student profile exists
      if (studentDetails == null || studentDetails!['student_id'] == null) {
        // First, ensure user exists in users table
        final existingUser = await supabase
            .from('users')
            .select('user_id')
            .eq('auth_id', user.id)
            .maybeSingle();
        
        String userId;
        if (existingUser == null) {
          // Create user record first
          final newUser = await supabase.from('users').insert({
            'auth_id': user.id,
            'email': user.email,
            'role': 'students',
          }).select('user_id').single();
          userId = newUser['user_id'];
        } else {
          userId = existingUser['user_id'];
        }
        
        // Create new student profile
        await supabase.from('students').insert({
          'user_id': userId,
          'name': _nameController.text.trim(),
          'course': _courseController.text.trim(),
          'yr_level': int.tryParse(_yrController.text.trim()) ?? 1,
          'about_me': _aboutMeController.text.trim(),
          'skills': skillsList,
          'phone_number': _phoneController.text.trim(),
          'linkedin_url': _linkedinController.text.trim(),
          'github_url': _githubController.text.trim(),
          'portfolio_url': _portfolioController.text.trim(),
          'location': _locationController.text.trim(),
        });
      } else {
        // Update existing student profile
        await supabase
            .from('students')
            .update({
              'name': _nameController.text.trim(),
              'course': _courseController.text.trim(),
              'yr_level': int.tryParse(_yrController.text.trim()) ?? 1,
              'about_me': _aboutMeController.text.trim(),
              'skills': skillsList,
              'phone_number': _phoneController.text.trim(),
              'linkedin_url': _linkedinController.text.trim(),
              'github_url': _githubController.text.trim(),
              'portfolio_url': _portfolioController.text.trim(),
              'location': _locationController.text.trim(),
            })
            .eq('student_id', studentDetails!['student_id']);
      }

      setState(() {
        _isEditingProfile = false;
      });

      await _getStudentDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
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
        body: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(screenHeight, screenWidth, isWide),
              
              // Main Content
              Expanded(
                child: focus == Focus.home
                    ? _buildHomePage()
                    : focus == Focus.applied
                    ? _buildAppliedPage()
                    : focus == Focus.profile
                    ? _buildProfilePage()
                    : _buildSettingsPage(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildModernBottomNav(),
      ),
    );
  }

  Widget _buildModernHeader(double screenHeight, double screenWidth, bool isWide) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF04305A), const Color(0xFF02243F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04305A).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row with logo and user info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF55119).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/logo-no-text.png',
                  height: 32,
                  width: 32,
                ),
              ),
              
              // User info
              if (studentDetails != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04305A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF55119), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFF55119),
                        child: Text(
                          (studentDetails!['name']?.isNotEmpty == true ? studentDetails!['name']!.substring(0, 1).toUpperCase() : 'S'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hi, ${studentDetails!['name']?.split(' ')[0] ?? 'Student'}!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Search bar (only on home page)
          if (focus == Focus.home)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF04305A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF04305A), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search internships...',
                  hintStyle: TextStyle(color: const Color(0xFF7A8B9A)),
                  prefixIcon: Icon(Icons.search, color: const Color(0xFFB8C5D1)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () => _searchController.clear(),
                          icon: Icon(Icons.clear, color: const Color(0xFFB8C5D1)),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      backgroundColor: const Color(0xFF02243F),
      color: const Color(0xFFF55119),
      onRefresh: getListings,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Section
            _buildFiltersSection(),
            
            SizedBox(height: 20),
            
            // Listings Section
            Text(
              'Available Internships',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            _loading
                ? Center(child: CircularProgressIndicator(color: const Color(0xFFF55119)))
                : _results.isNotEmpty
                    ? Column(
                        children: _results.map<Widget>((listing) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: _buildModernListingCard(listing),
                          );
                        }).toList(),
                      )
                    : Container(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline,
                                size: 64,
                                color: const Color(0xFF7A8B9A),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No internships available",
                                style: TextStyle(
                                  color: const Color(0xFFB8C5D1),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF04305A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Filters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildFilterChip('Company Name', activeFilters['name']!, (value) {
                setState(() => activeFilters['name'] = value);
                getListings();
              }),
              _buildFilterChip('Industry', activeFilters['industry']!, (value) {
                setState(() => activeFilters['industry'] = value);
                getListings();
              }),
              _buildFilterChip('Location', activeFilters['location']!, (value) {
                setState(() => activeFilters['location'] = value);
                getListings();
              }),
              _buildFilterChip('Position', activeFilters['position']!, (value) {
                setState(() => activeFilters['position'] = value);
                getListings();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFFB8C5D1),
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: onChanged,
      backgroundColor: const Color(0xFF02243F),
      selectedColor: const Color(0xFFF55119),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFFF55119) : const Color(0xFF04305A),
        width: 1,
      ),
    );
  }

  Widget _buildModernListingCard(Map<String, dynamic> listing) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04305A), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04305A).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        listing['company']['name'],
                        style: TextStyle(
                          color: const Color(0xFFF2A13B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF55119),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.location_on, color: const Color(0xFFB8C5D1), size: 16),
                SizedBox(width: 4),
                Text(
                  listing['location'],
                  style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
                ),
                SizedBox(width: 16),
                Icon(Icons.business, color: const Color(0xFFB8C5D1), size: 16),
                SizedBox(width: 4),
                Text(
                  listing['company']['industry'],
                  style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Position: ${listing['position']}',
              style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
            ),
            
            SizedBox(height: 16),
            
            Text(
              listing['description'],
              style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedPage() {
    return RefreshIndicator(
      backgroundColor: const Color(0xFF02243F),
      color: const Color(0xFFF55119),
      onRefresh: getAppliedListings,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applied Internships',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            _loading
                ? Center(child: CircularProgressIndicator(color: const Color(0xFFF55119)))
                : _applied.isNotEmpty
                    ? Column(
                        children: _applied.map<Widget>((listing) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: _buildAppliedListingCard(listing),
                          );
                        }).toList(),
                      )
                    : Container(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 64,
                                color: const Color(0xFF7A8B9A),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "No applications yet",
                                style: TextStyle(
                                  color: const Color(0xFFB8C5D1),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedListingCard(Map<String, dynamic> listing) {
    Color statusColor;
    switch (listing['application_status']) {
      case 'Accepted':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = const Color(0xFFF2A13B);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF04305A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF04305A), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04305A).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        listing['company']['name'],
                        style: TextStyle(
                          color: const Color(0xFFF2A13B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    listing['application_status'] ?? 'Pending',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.location_on, color: const Color(0xFFB8C5D1), size: 16),
                SizedBox(width: 4),
                Text(
                  listing['location'],
                  style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
                ),
                SizedBox(width: 16),
                Icon(Icons.business, color: const Color(0xFFB8C5D1), size: 16),
                SizedBox(width: 4),
                Text(
                  listing['company']['industry'],
                  style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Position: ${listing['position']}',
              style: TextStyle(color: const Color(0xFFB8C5D1), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF04305A), const Color(0xFF02243F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF04305A).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF55119),
                  child: Text(
                    (studentDetails?['name']?.isNotEmpty == true ? studentDetails!['name']!.substring(0, 1).toUpperCase() : 'S'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentDetails?['name'] ?? 'Student Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${studentDetails?['course'] ?? 'Course'} • Year ${studentDetails?['yr_level'] ?? 'N/A'}',
                        style: TextStyle(
                          color: const Color(0xFFB8C5D1),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (studentDetails?['location'] != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, color: const Color(0xFFF2A13B), size: 16),
                            SizedBox(width: 4),
                            Text(
                              studentDetails!['location'],
                              style: TextStyle(
                                color: const Color(0xFFB8C5D1),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditingProfile = !_isEditingProfile;
                    });
                  },
                  icon: Icon(
                    _isEditingProfile ? Icons.close : Icons.edit,
                    color: const Color(0xFFF2A13B),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Name Section
          _buildProfileSection(
            'Full Name',
            Icons.person,
            _nameController,
            hintText: 'Enter your full name',
          ),
          
          SizedBox(height: 16),
          
          // Course and Year Section
          Row(
            children: [
              Expanded(
                child: _buildProfileSection(
                  'Course',
                  Icons.school,
                  _courseController,
                  hintText: 'Enter your course',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildProfileSection(
                  'Year Level',
                  Icons.calendar_today,
                  _yrController,
                  hintText: 'Enter year level',
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // About Me Section
          _buildProfileSection(
            'About Me',
            Icons.person_outline,
            _aboutMeController,
            maxLines: 5,
          ),
          
          SizedBox(height: 16),
          
          // Skills Section
          _buildProfileSection(
            'Skills',
            Icons.star_outline,
            _skillsController,
            hintText: 'Enter skills separated by commas',
          ),
          
          SizedBox(height: 16),
          
          // Contact Information
          _buildProfileSection(
            'Phone Number',
            Icons.phone_outlined,
            _phoneController,
          ),
          
          SizedBox(height: 16),
          
          _buildProfileSection(
            'LinkedIn URL',
            Icons.link,
            _linkedinController,
          ),
          
          SizedBox(height: 16),
          
          _buildProfileSection(
            'GitHub URL',
            Icons.code,
            _githubController,
          ),
          
          SizedBox(height: 16),
          
          _buildProfileSection(
            'Portfolio URL',
            Icons.web,
            _portfolioController,
          ),
          
          SizedBox(height: 16),
          
          _buildProfileSection(
            'Location',
            Icons.location_on_outlined,
            _locationController,
          ),
          
          SizedBox(height: 24),
          
          // Save Button
          if (_isEditingProfile)
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF55119).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _updateProfile,
                child: Text(
                  'Save Changes',
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

  Widget _buildProfileSection(String title, IconData icon, TextEditingController controller, {String? hintText, int maxLines = 1}) {
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
          SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: _isEditingProfile,
            maxLines: maxLines,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter $title',
              hintStyle: TextStyle(color: const Color(0xFF7A8B9A)),
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
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
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
          
          // Login Information Section
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
          
          // Personal Information Section
          _buildSettingsSection(
            'Personal Information',
            Icons.person_outline,
            [
              _buildSettingsField(
                'Full Name',
                _nameController,
                isEditingName,
                () => setState(() => isEditingName = !isEditingName),
                nameChanged,
                _updatePersonalInfo,
              ),
              _buildSettingsField(
                'Resume Link',
                _resumeController,
                isEditingResume,
                () => setState(() => isEditingResume = !isEditingResume),
                resumeChanged,
                _updatePersonalInfo,
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // University Information Section
          _buildSettingsSection(
            'University Information',
            Icons.school_outlined,
            [
              _buildDropdownField(
                'Course',
                _courseController,
                isEditingCourse,
                () => setState(() => isEditingCourse = !isEditingCourse),
                courseChanged,
                _updateUniversityInfo,
                [
                  DropdownMenuEntry(value: 'NetAd', label: 'NetAd'),
                  DropdownMenuEntry(value: 'WebDev', label: 'WebDev'),
                  DropdownMenuEntry(value: 'EMC', label: 'EMC'),
                  DropdownMenuEntry(value: 'ComSci', label: 'ComSci'),
                  DropdownMenuEntry(value: 'Cybersecurity', label: 'Cybersecurity'),
                ],
              ),
              _buildDropdownField(
                'Year Level',
                _yrController,
                isEditingYr,
                () => setState(() => isEditingYr = !isEditingYr),
                yrChanged,
                _updateUniversityInfo,
                [
                  DropdownMenuEntry(value: '1', label: '1st Year'),
                  DropdownMenuEntry(value: '2', label: '2nd Year'),
                  DropdownMenuEntry(value: '3', label: '3rd Year'),
                  DropdownMenuEntry(value: '4', label: '4th Year'),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 30),
          
          // Logout Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to log out: $e'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
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
          _buildNavItem(Focus.home, Icons.home_outlined, 'Home'),
          _buildNavItem(Focus.applied, Icons.assignment_turned_in_outlined, 'Applied'),
          _buildNavItem(Focus.profile, Icons.person_outline, 'Profile'),
          _buildNavItem(Focus.settings, Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(Focus focusType, IconData icon, String label) {
    final isSelected = focus == focusType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            focus = focusType;
          });
          if (focusType == Focus.home) {
            getListings();
          } else if (focusType == Focus.applied) {
            getAppliedListings();
          }
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

  // Settings helper methods
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
              obscureText: !isVisible,
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
                        onPressed: () => setState(() => isVisible = !isVisible),
                        icon: Icon(
                          isVisible ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFB8C5D1),
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

  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    bool isEditing,
    VoidCallback onEditToggle,
    bool hasChanges,
    VoidCallback onUpdate,
    List<DropdownMenuEntry<String>> entries,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<String>(
              controller: controller,
              enabled: isEditing,
              label: Text(
                label,
                style: TextStyle(color: const Color(0xFFB8C5D1)),
              ),
              dropdownMenuEntries: entries,
              onSelected: isEditing ? (value) {
                controller.text = value ?? '';
                onUpdate();
              } : null,
              inputDecorationTheme: InputDecorationTheme(
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
        ],
      ),
    );
  }

  Future<void> _updateLoginInfo() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email can't be empty."),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password.isEmpty ? null : password,
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A confirmation email has been sent to $email. Confirm to change your email.',
            ),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      setState(() {
        isEditingEmail = false;
        isEditingPassword = false;
        emailChanged = false;
        passwordChanged = false;
      });
      
      await _getStudentDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating login info: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _updatePersonalInfo() async {
    final name = _nameController.text.trim();
    final resume = _resumeController.text.trim();

    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Full name can't be empty."),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (resume.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Resume can't be empty."),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final regex = RegExp(
      r'^(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9\-\_]+\/?$',
    );

    if (!regex.hasMatch(resume)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Must be a valid LinkedIn link."),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (studentDetails == null) return;

    try {
      await supabase
          .from('students')
          .update({
            'name': name,
            'resume_url': resume,
          })
          .eq('student_id', studentDetails!['student_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated!'),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      setState(() {
        isEditingName = false;
        isEditingResume = false;
        nameChanged = false;
        resumeChanged = false;
      });
      
      await _getStudentDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating personal info: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _updateUniversityInfo() async {
    final course = _courseController.text.trim();
    final year = _yrController.text.trim();

    if (studentDetails == null) return;

    try {
      await supabase
          .from('students')
          .update({
            'course': course,
            'yr_level': int.parse(year),
          })
          .eq('student_id', studentDetails!['student_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated!'),
            backgroundColor: const Color(0xFFF55119),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      setState(() {
        isEditingCourse = false;
        isEditingYr = false;
        courseChanged = false;
        yrChanged = false;
      });
      
      await _getStudentDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating university info: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
