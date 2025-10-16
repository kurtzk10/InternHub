import 'package:flutter/material.dart';
import 'package:internhub/screens/viewApplicants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'package:internhub/screens/editListing.dart';
import 'package:flutter/services.dart';
import 'dart:async';

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

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

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

class CompanyPage extends StatefulWidget {
  @override
  _CompanyPageState createState() => _CompanyPageState();
}

enum Focus { home, add, settings }

class _CompanyPageState extends State<CompanyPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _contactController = TextEditingController();
  final _numberController = TextEditingController();
  String? number;


  final _listingFormKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = [TextEditingController()];

  final _titleController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _linkController = TextEditingController();

  Focus focus = Focus.home;

  bool isEditingEmail = false;
  bool isEditingPassword = false;
  bool isPasswordPlain = false;

  List<Map<String, dynamic>?> listings = [];

  Map<String, dynamic>? companyDetails;
  bool isEditingName = false;
  bool isEditingIndustry = false;
  bool isEditingContact = false;
  bool isEditingNumber = false;

  bool emailChanged = false;
  bool passwordChanged = false;
  bool nameChanged = false;
  bool industryChanged = false;
  bool contactChanged = false;
  bool numberChanged = false;

  void _addRequirement() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  Future<void> _getCompanyDetails() async {
    final user = Supabase.instance.client.auth.currentUser;

    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user!.id)
        .single();

    final userId = usersResponse['user_id'];

    final company = await Supabase.instance.client
        .from('company')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (company != null) {
      setState(() {
        companyDetails = company;
        _nameController.text = companyDetails!['name'];
        _industryController.text = companyDetails!['industry'];
        _contactController.text = companyDetails!['contact_email'];
        String contactNumber = companyDetails!['contact_number'];
        number =
            "${contactNumber.substring(0, 4)} ${contactNumber.substring(4, 8)} ${contactNumber.substring(8)}";
        _numberController.text = number!;
      });
    }
  }

  Future<void> getListings() async {
    await _getCompanyDetails();
    final query = await Supabase.instance.client
        .from('listing')
        .select()
        .eq('company_id', companyDetails!['company_id']);
    setState(() {
      listings = query as List<Map<String, dynamic>?>;
    });
  }

  @override
  void initState() {
    super.initState();

    getListings();

    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email;

    _emailController.text = userEmail ?? '';

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
        nameChanged = _nameController.text.trim() != companyDetails!['name'];
      });
    });

    _industryController.addListener(() {
      setState(() {
        industryChanged =
            _industryController.text.trim() != companyDetails!['industry'];
      });
    });

    _contactController.addListener(() {
      setState(() {
        contactChanged =
            _contactController.text.trim() != companyDetails!['contact'];
      });
    });

    _numberController.addListener(() {
      setState(() {
        numberChanged = _numberController.text.trim() != number;
      });
    });

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
                        'Company',
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
                child: focus == Focus.home
                    ? _buildHomePage(context, screenHeight, screenWidth, isWide, companyDetails, listings)
                    : focus == Focus.add
                    ? _buildAddPage(context, screenHeight, screenWidth, isWide, companyDetails)
                    : _buildSettingsPage(context, screenHeight, screenWidth, isWide),
              ),
            ],
          ),
        ),

        bottomNavigationBar: _buildModernBottomNav(),
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
          _buildNavItem(Focus.add, Icons.add_circle_outline, 'Create'),
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

  Widget _buildHomePage(BuildContext context, double screenHeight, double screenWidth, bool isWide, companyDetails, listings) {
    return RefreshIndicator(
      color: const Color(0xFFF55119),
      backgroundColor: const Color(0xFF02243F),
      onRefresh: getListings,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Listings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            listings.isNotEmpty
                ? Column(
                    children: listings.map<Widget>((listing) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _buildModernListingCard(listing),
                      );
                    }).toList(),
                  )
                : Container(
                    height: screenHeight * 0.5,
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
                            "You don't have any posted listings.",
                            style: TextStyle(
                              color: const Color(0xFF7A8B9A),
                              fontSize: 16,
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

  Widget _buildModernListingCard(Map<String, dynamic> listing) {
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
              Expanded(
                child: Text(
                  listing['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ViewApplicantsPage(listing),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                icon: Icon(Icons.people_outline, color: const Color(0xFFF55119)),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildListingInfo('Position', listing['position'], Icons.work_outline),
          _buildListingInfo('Location', listing['location'], Icons.location_on_outlined),
          _buildListingInfo('Duration', listing['duration'], Icons.schedule),
          if (listing['description']?.isNotEmpty == true) ...[
            SizedBox(height: 12),
            Text(
              'Description',
              style: TextStyle(
                color: const Color(0xFFF2A13B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              listing['description'],
              style: TextStyle(
                color: const Color(0xFFB8C5D1),
                fontSize: 14,
              ),
            ),
          ],
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04305A),
                    foregroundColor: const Color(0xFFF55119),
                    side: BorderSide(color: const Color(0xFFF55119)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => EditListingPage(listing),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Text('Edit'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showDeleteDialog(listing),
                  child: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingInfo(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF2A13B), size: 16),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: const Color(0xFFF2A13B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: const Color(0xFFB8C5D1),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF02243F),
          title: Text(
            'Confirm',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete this listing?',
            style: TextStyle(color: const Color(0xFFB8C5D1)),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFFB8C5D1)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
              onPressed: () async {
                try {
                  await Supabase.instance.client
                      .from('listing')
                      .delete()
                      .eq('listing_id', listing['listing_id']);
                  await getListings();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully deleted."),
                      backgroundColor: const Color(0xFF04305A),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
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
  }

  Widget _buildAddPage(BuildContext context, double screenHeight, double screenWidth, bool isWide, companyDetails) {
    if (companyDetails == null || !companyDetails['is_verified']) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 64,
                color: const Color(0xFF7A8B9A),
              ),
              SizedBox(height: 16),
              Text(
                'Verification Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'You are currently unverified. Contact a coordinator or administrator to help you get verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFB8C5D1),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Create Listing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                onPressed: () => setState(() => focus = Focus.home),
                icon: Icon(Icons.close, color: const Color(0xFFB8C5D1)),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildAddForm(),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Form(
      key: _listingFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddField('Title', _titleController, true, Icons.title),
          SizedBox(height: 16),
          _buildAddField('Job Position', _positionController, true, Icons.work_outline),
          SizedBox(height: 16),
          _buildAddField('Job Location', _locationController, true, Icons.location_on_outlined),
          SizedBox(height: 16),
          _buildDurationDropdown(),
          SizedBox(height: 16),
          _buildAddField('Description', _descriptionController, false, Icons.description_outlined, maxLines: 5),
          SizedBox(height: 16),
          _buildRequirementsSection(),
          SizedBox(height: 16),
          _buildAddField('LinkedIn Link', _linkController, true, Icons.link),
          SizedBox(height: 30),
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildAddField(String label, TextEditingController controller, bool required, IconData icon, {int maxLines = 1}) {
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
                label + (required ? ' *' : ''),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter $label',
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

  Widget _buildDurationDropdown() {
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
              Icon(Icons.schedule, color: const Color(0xFFF2A13B), size: 20),
              SizedBox(width: 8),
              Text(
                'Duration Type *',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF02243F),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF04305A)),
            ),
            child: DropdownMenu<String>(
              width: double.infinity,
              hintText: 'Select Duration',
              enableSearch: false,
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 'Part Time', label: 'Part Time'),
                DropdownMenuEntry(value: 'Full Time', label: 'Full Time'),
              ],
              onSelected: (value) => setState(() => _durationController.text = value ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
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
              Icon(Icons.list_alt, color: const Color(0xFFF2A13B), size: 20),
              SizedBox(width: 8),
              Text(
                'Requirements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ..._controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final controller = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF02243F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF04305A)),
                      ),
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Requirement ${index + 1}',
                          hintStyle: TextStyle(color: const Color(0xFF7A8B9A)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _controllers.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                  ),
                ],
              ),
            );
          }),
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF55119),
                side: BorderSide(color: const Color(0xFFF55119)),
              ),
              onPressed: _addRequirement,
              icon: Icon(Icons.add),
              label: Text('Add Requirement'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
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
        onPressed: _createListing,
        child: Text(
          'Create Listing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _createListing() async {
    final title = _titleController.text.trim();
    final position = _positionController.text.trim();
    final location = _locationController.text.trim();
    final duration = _durationController.text.trim();
    final description = _descriptionController.text.trim();
    final requirements = _controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');
    final link = _linkController.text.trim();

    // Validation
    if (title.isEmpty) {
      _showSnackBar("Title can't be empty.");
      return;
    }
    if (position.isEmpty) {
      _showSnackBar("Job position can't be empty.");
      return;
    }
    if (location.isEmpty) {
      _showSnackBar("Location can't be empty.");
      return;
    }
    if (duration.isEmpty) {
      _showSnackBar("Please pick a duration type.");
      return;
    }
    if (link.isEmpty) {
      _showSnackBar("LinkedIn link can't be empty.");
      return;
    }

    final linkedInPostRegex = RegExp(
      r'^https?:\/\/(?:www\.|m\.)?linkedin\.com\/(?:feed\/update\/urn:li:(?:activity|share):(\d+)|posts\/([^\/?]+)|company\/[^\/]+\/posts\/([^\/?]+))(?:[\/?].*)?$',
      caseSensitive: false,
    );

    if (!linkedInPostRegex.hasMatch(link)) {
      _showSnackBar("Must be a valid LinkedIn link.");
      return;
    }

    try {
      await Supabase.instance.client.from('listing').insert({
        'company_id': companyDetails!['company_id'],
        'title': title,
        'position': position,
        'location': location,
        'duration': duration,
        'description': description,
        'requirements': requirements,
        'link': link,
      });
      _showSnackBar("Successfully posted!", isSuccess: true);
      _clearForm();
      setState(() => focus = Focus.home);
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  void _clearForm() {
    setState(() {
      _controllers.clear();
      _controllers.add(TextEditingController());
      _titleController.clear();
      _positionController.clear();
      _locationController.clear();
      _durationController.clear();
      _descriptionController.clear();
      _requirementsController.clear();
      _linkController.clear();
    });
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

  Widget _buildSettingsPage(BuildContext context, double screenHeight, double screenWidth, bool isWide) {
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
            'Company Information',
            Icons.business_outlined,
            [
              _buildSettingsField(
                'Company Name',
                _nameController,
                isEditingName,
                () => setState(() => isEditingName = !isEditingName),
                nameChanged,
                _updateCompanyInfo,
              ),
              _buildSettingsField(
                'Industry',
                _industryController,
                isEditingIndustry,
                () => setState(() => isEditingIndustry = !isEditingIndustry),
                industryChanged,
                _updateCompanyInfo,
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSettingsSection(
            'Contact Information',
            Icons.contact_phone_outlined,
            [
              _buildSettingsField(
                'Contact Email',
                _contactController,
                isEditingContact,
                () => setState(() => isEditingContact = !isEditingContact),
                contactChanged,
                _updateContactInfo,
              ),
              _buildSettingsField(
                'Contact Number',
                _numberController,
                isEditingNumber,
                () => setState(() => isEditingNumber = !isEditingNumber),
                numberChanged,
                _updateContactInfo,
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

  Future<void> _updateCompanyInfo() async {
    final name = _nameController.text.trim();
    final industry = _industryController.text.trim();

    if (name.isEmpty) {
      _showSnackBar("Company Name can't be empty.");
      return;
    }
    if (industry.isEmpty) {
      _showSnackBar("Industry can't be empty.");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user!.id)
        .single();
    final userId = usersResponse['user_id'];

    try {
      await Supabase.instance.client
          .from('company')
          .update({
            'name': name,
            'industry': industry,
          })
          .eq('user_id', userId);
      _showSnackBar('Successfully updated.', isSuccess: true);
      setState(() {
        isEditingName = false;
        isEditingIndustry = false;
      });
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _updateContactInfo() async {
    final contact = _contactController.text.trim();
    final number = _numberController.text.replaceAll(' ', '');

    if (contact.isEmpty) {
      _showSnackBar("Contact Email can't be empty.");
      return;
    }
    if (number.isEmpty) {
      _showSnackBar("Contact Number can't be empty.");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user!.id)
        .single();
    final userId = usersResponse['user_id'];

    try {
      await Supabase.instance.client
          .from('company')
          .update({
            'contact_email': contact,
            'contact_number': number,
          })
          .eq('user_id', userId);
      _showSnackBar('Successfully updated.', isSuccess: true);
      setState(() {
        isEditingContact = false;
        isEditingNumber = false;
      });
    } catch (e) {
      _showSnackBar("Error: $e");
    }
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

