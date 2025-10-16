import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

enum Focus { home, applied, settings }

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _resumeController = TextEditingController();
  final _courseController = TextEditingController();
  final _yrController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _personalFormKey = GlobalKey<FormState>();
  final _uniFormKey = GlobalKey<FormState>();

  Focus focus = Focus.home;

  Map<String, dynamic>? studentDetails;
  bool isEditingEmail = false;
  bool isEditingPassword = false;
  bool isEditingName = false;
  bool isEditingResume = false;
  bool isEditingCourse = false;
  bool isEditingYr = false;
  bool isVisible = false;

  bool emailChanged = false;
  bool passwordChanged = false;
  bool nameChanged = false;
  bool resumeChanged = false;
  bool courseChanged = false;
  bool yrChanged = false;

  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  List<dynamic> _applied = [];
  Timer? _debounce;
  bool _loading = false;
  final supabase = Supabase.instance.client;

  Map<String, bool> activeFilters = {
    'name': false,
    'industry': false,
    'location': false,
    'position': false,
  };

  Future<void> _getStudentDetails() async {
    final user = Supabase.instance.client.auth.currentUser;

    final usersResponse = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', user!.id)
        .single();

    final userId = usersResponse['user_id'];

    final student = await Supabase.instance.client
        .from('students')
        .select()
        .eq('user_id', userId)
        .single();

    setState(() {
      studentDetails = student;
      _nameController.text = student['name'];
      _resumeController.text = student['resume_url'];
      _courseController.text = student['course'];
      _yrController.text = student['yr_level'].toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _getStudentDetails();

    final user = supabase.auth.currentUser;
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

    _nameController.addListener(() {
      setState(() {
        nameChanged = _nameController.text.trim() != studentDetails!['name'];
      });
    });

    _resumeController.addListener(() {
      setState(() {
        resumeChanged =
            _resumeController.text.trim() != studentDetails!['resume_url'];
      });
    });

    _courseController.addListener(() {
      setState(() {
        courseChanged =
            _courseController.text.trim() != studentDetails!['course'];
      });
    });

    _yrController.addListener(() {
      setState(() {
        yrChanged =
            _yrController.text.trim() != studentDetails!['yr_level'].toString();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
      getListings();
      getAppliedListings();
    });

    _searchController.addListener(_onSearchChanged);
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
  if (studentDetails == null) return;

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isWide ? screenHeight * 0.12 : screenHeight * 0.08,
          ),
          child: focus == Focus.home
              ? AppBar(
                  backgroundColor: orange,
                  iconTheme: IconThemeData(color: Colors.white),
                  automaticallyImplyLeading: true,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                    ),
                    child: Center(
                      child: Container(
                        height: isWide ? 30 : 40,
                        width: screenWidth * 0.7,
                        child: TextFormField(
                          controller: _searchController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search keywords...',
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    style: IconButton.styleFrom(
                                      overlayColor: Colors.transparent,
                                    ),
                                    onPressed: () {
                                      _searchController.text = '';
                                    },
                                    icon: Icon(Icons.close),
                                  )
                                : null,
                            hintStyle: TextStyle(color: Colors.grey),
                            border: _inputBorder(),
                            enabledBorder: _inputBorder(),
                            focusedBorder: _inputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                          ),
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
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.1,
                      ),
                      child: Image.asset(
                        'assets/logo-no-text.png',
                        height: isWide ? 30 : 35,
                        width: isWide ? 30 : 35,
                      ),
                    ),
                  ),
                ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth / 10),
          child: focus == Focus.home
              ? _homePage(
                  getListings,
                  context,
                  screenHeight,
                  screenWidth,
                  orange,
                  focus,
                  isWide,
                  _results,
                  _loading,
                  activeFilters,
                  (val) => setState(() {
                    activeFilters['name'] = val;
                  }),
                  (val) => setState(() {
                    activeFilters['industry'] = val;
                  }),
                  (val) => setState(() {
                    activeFilters['location'] = val;
                  }),
                  (val) => setState(() {
                    activeFilters['position'] = val;
                  }),
                )
              : focus == Focus.applied
              ? _appliedPage(
                  getAppliedListings,
                  context,
                  screenHeight,
                  screenWidth,
                  orange,
                  focus,
                  isWide,
                  _applied,
                  _loading,
                )
              : _settingsPage(
                  context,
                  screenHeight,
                  screenWidth,
                  orange,
                  isWide,
                  _emailController,
                  _passwordController,
                  _nameController,
                  _resumeController,
                  _courseController,
                  _yrController,
                  _loginFormKey,
                  _personalFormKey,
                  _uniFormKey,
                  isEditingEmail,
                  isEditingPassword,
                  isEditingName,
                  isEditingResume,
                  isEditingCourse,
                  isEditingYr,
                  isVisible,
                  emailChanged,
                  passwordChanged,
                  nameChanged,
                  resumeChanged,
                  courseChanged,
                  yrChanged,
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
                    isEditingResume = !isEditingResume;
                  }),
                  () => setState(() {
                    isEditingCourse = !isEditingCourse;
                  }),
                  () => setState(() {
                    isEditingYr = !isEditingYr;
                  }),
                  (val) => setState(() => _courseController.text = val!),
                  (val) => setState(() => _yrController.text = val!),
                  () => setState(() {
                    isVisible = !isVisible;
                  }),
                  _getStudentDetails,
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
                    backgroundColor: focus == Focus.home
                        ? selectedOrange
                        : orange,
                    minimumSize: Size(screenHeight, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: focus == Focus.home
                      ? null
                      : () async {
                          setState(() {
                            focus = Focus.home;
                            isEditingEmail = false;
                            isEditingPassword = false;
                            isEditingName = false;
                            isEditingResume = false;
                            isEditingCourse = false;
                            isEditingYr = false;
                          });

                          await getListings();
                        },
                  child: Icon(Icons.home, color: Colors.white, size: 25),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: focus == Focus.applied
                        ? selectedOrange
                        : orange,
                    minimumSize: Size(screenHeight, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: focus == Focus.applied
                      ? null
                      : () async {
                          setState(() {
                            focus = Focus.applied;
                            isEditingEmail = false;
                            isEditingPassword = false;
                            isEditingName = false;
                            isEditingResume = false;
                            isEditingCourse = false;
                            isEditingYr = false;
                          });

                          await getAppliedListings();
                        },
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: focus == Focus.settings
                        ? selectedOrange
                        : orange,
                    minimumSize: Size(screenHeight, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: focus == Focus.settings
                      ? null
                      : () {
                          setState(() {
                            focus = Focus.settings;
                          });
                        },
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

Widget _homePage(
  Future<void> Function() refreshListings,
  BuildContext context,
  double screenHeight,
  double screenWidth,
  orange,
  focus,
  bool isWide,
  listings,
  bool loading,
  filters,
  void Function(dynamic) activateName,
  void Function(dynamic) activateInd,
  void Function(dynamic) activateLoc,
  void Function(dynamic) activatePos,
) {
  return RefreshIndicator(
    backgroundColor: Colors.white,
    color: orange,
    onRefresh: refreshListings,
    child: SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Company Name', style: TextStyle(fontSize: 15)),
                    Checkbox(
                      value: filters['name'],
                      onChanged: (val) {
                        activateName(val);
                        refreshListings();
                      },
                      activeColor: orange,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Industry Type', style: TextStyle(fontSize: 15)),
                    Checkbox(
                      value: filters['industry'],
                      onChanged: (val) {
                        activateInd(val);
                        refreshListings();
                      },
                      activeColor: orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Location', style: TextStyle(fontSize: 15)),
                    Checkbox(
                      value: filters['location'],
                      onChanged: (val) {
                        activateLoc(val);
                        refreshListings();
                      },
                      activeColor: orange,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Job Position', style: TextStyle(fontSize: 15)),
                    Checkbox(
                      value: filters['position'],
                      onChanged: (val) {
                        activatePos(val);
                        refreshListings();
                      },
                      activeColor: orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            'Listings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          listings.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: listings.map<Widget>((listing) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: ListingCard(
                        listing,
                        orange,
                        focus,
                        refreshListings,
                      ),
                    );
                  }).toList(),
                )
              : SizedBox(
                  height: screenHeight * 0.7,
                  child: Center(
                    child: Text(
                      "No listings available.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
        ],
      ),
    ),
  );
}

class ListingCard extends StatefulWidget {
  final Map<String, dynamic> listing;
  final Color orange;
  final Focus focus;
  final Future<void> Function() onRefresh;

  const ListingCard(
    this.listing,
    this.orange,
    this.focus,
    this.onRefresh, {
    super.key,
  });
  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool isExpanded = false;

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final collapsedHeight = 170.0;
    final requirements = widget.listing['requirements']
        .toString()
        .split('\n')
        .map((req) => req.replaceAll(RegExp(r'[\u00A0\t]'), '').trim())
        .where((req) => req.isNotEmpty)
        .toList();

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Material(
        color: Colors.white,
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: isExpanded ? double.infinity : collapsedHeight,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.listing['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Posted by: ',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  'Company Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Company Name: ${widget.listing['company']['name']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Type of Industry: ${widget.listing['company']['industry']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Contact Email: ${widget.listing['company']['contact_email']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Contact Number: ${widget.listing['company']['contact_number']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'Done',
                                      style: TextStyle(color: widget.orange),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          widget.listing['company']['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.orange,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                            decorationColor: widget.orange,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text.rich(
                    maxLines: isExpanded ? null : 1,
                    TextSpan(
                      style: TextStyle(
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Position: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: widget.listing['position'],
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    maxLines: isExpanded ? null : 1,
                    TextSpan(
                      style: TextStyle(
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Location: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: widget.listing['location'],
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Type of Industry: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: widget.listing['company']['industry'],
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (isExpanded) ...[
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Duration: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: widget.listing['duration'],
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.listing['description'].isNotEmpty
                          ? widget.listing['description']
                          : 'No description',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Requirements',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    requirements.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: requirements.map((req) {
                              final trimmed = req.trim();
                              if (trimmed.isEmpty) return SizedBox.shrink();
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '- ',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Expanded(
                                    child: Text(
                                      trimmed,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )
                        : Text(
                            'No requirements',
                            style: const TextStyle(fontSize: 16),
                          ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: widget.listing['link'].isNotEmpty
                              ? widget.orange
                              : Colors.grey,
                        ),
                        GestureDetector(
                          onTap: widget.listing['link'].isNotEmpty
                              ? () {
                                  String link = widget.listing['link'];
                                  openLink(link);
                                }
                              : null,
                          child: Text(
                            widget.listing['link'].isNotEmpty
                                ? 'LinkedIn'
                                : 'No link available',
                            style: widget.listing['link'].isNotEmpty
                                ? TextStyle(
                                    color: widget.orange,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: widget.orange,
                                  )
                                : TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ],
              ),
              widget.focus == Focus.home
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.orange,
                          foregroundColor: Colors.white,
                          fixedSize: Size(100, 10),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text(
                                  'Confirm Application',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to apply to ${widget.listing['company']['name']} with the position of ${widget.listing['position']}?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: widget.orange,
                                    ),
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: widget.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Confirm'),
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();

                                      try {
                                        final user = Supabase
                                            .instance
                                            .client
                                            .auth
                                            .currentUser;
                                        final usersResponse = await Supabase
                                            .instance
                                            .client
                                            .from('users')
                                            .select('user_id')
                                            .eq('auth_id', user!.id)
                                            .single();
                                        final userId = usersResponse['user_id'];

                                        final studentResponse = await Supabase
                                            .instance
                                            .client
                                            .from('students')
                                            .select('student_id')
                                            .eq('user_id', userId)
                                            .single();
                                        final studentId =
                                            studentResponse['student_id'];

                                        await Supabase.instance.client
                                            .from('application')
                                            .insert({
                                              'student_id': studentId,
                                              'listing_id':
                                                  widget.listing['listing_id'],
                                            });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Successfully applied.',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );

                                        await widget.onRefresh();
                                      } on AuthException catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(e.message),
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
                        child: Text('Apply'),
                      ),
                    )
                  : widget.focus == Focus.applied
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          color: Colors.transparent,
                          child: Text(
                            widget.listing['application_status'] ?? 'Pending',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              if (!isExpanded)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      color: Colors.transparent,
                      child: const Text(
                        '...',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _appliedPage(
  Future<void> Function() refreshListings,
  BuildContext context,
  double screenHeight,
  double screenWidth,
  orange,
  focus,
  bool isWide,
  listings,
  bool loading,
) {
  return RefreshIndicator(
    backgroundColor: Colors.white,
    color: orange,
    onRefresh: refreshListings,
    child: SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Applied Listings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 10),
          listings.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: listings.map<Widget>((listing) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: ListingCard(
                        listing,
                        orange,
                        focus,
                        refreshListings,
                      ),
                    );
                  }).toList(),
                )
              : SizedBox(
                  height: screenHeight * 0.7,
                  child: Center(
                    child: Text(
                      "No applied listings yet.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
        ],
      ),
    ),
  );
}

Widget _settingsPage(
  BuildContext context,
  double screenHeight,
  double screenWidth,
  orange,
  bool isWide,
  emailController,
  passwordController,
  nameController,
  resumeController,
  courseController,
  yrController,
  loginFormKey,
  personalFormKey,
  uniFormKey,
  bool isEditingEmail,
  bool isEditingPassword,
  bool isEditingName,
  bool isEditingResume,
  bool isEditingCourse,
  bool isEditingYr,
  bool isVisible,
  bool emailChanged,
  bool passwordChanged,
  bool nameChanged,
  bool resumeChanged,
  bool courseChanged,
  bool yrChanged,
  VoidCallback editEmailChange,
  VoidCallback editPasswordChange,
  VoidCallback editNameChange,
  VoidCallback editResumeChange,
  VoidCallback editCourseChange,
  VoidCallback editYrChange,
  void Function(dynamic) changeCourse,
  void Function(dynamic) changeYr,
  VoidCallback passwordVisibilityChange,
  VoidCallback refresh,
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
            padding: const EdgeInsets.all(16),
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
                            obscureText: !isVisible,
                            enabled: isEditingPassword,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              floatingLabelStyle: TextStyle(
                                color: isEditingPassword ? orange : Colors.grey,
                              ),
                              border: _inputBorder(),
                              enabledBorder: _inputBorder(),
                              focusedBorder: _inputBorder(),
                              contentPadding: EdgeInsets.all(10),
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: passwordVisibilityChange,
                                icon: Icon(
                                  isVisible
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
                                  await Supabase.instance.client.auth
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
                                refresh();
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
        SizedBox(height: 20),
        Material(
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: personalFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
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
                            controller: nameController,
                            enabled: isEditingName,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 10
                              : screenHeight / 20,
                          child: TextFormField(
                            controller: resumeController,
                            enabled: isEditingResume,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Resume Link',
                              floatingLabelStyle: TextStyle(
                                color: isEditingResume ? orange : null,
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
                        onPressed: () => editResumeChange(),
                        icon: Icon(
                          isEditingResume ? Icons.edit_off : Icons.edit,
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
                          ((isEditingName && nameChanged) ||
                              (isEditingResume && resumeChanged))
                          ? () async {
                              bool valid = false;

                              final name = nameController.text.trim();
                              final resume = resumeController.text.trim();

                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Full name can't be empty."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              if (resume.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Resume can't be empty."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              final regex = RegExp(
                                r'^(https?:\/\/)?(www\.)?linkedin\.com\/in\/[a-zA-Z0-9\-\_]+\/?$',
                              );

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

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              if (user != null) {
                                try {
                                  final usersResponse = await Supabase
                                      .instance
                                      .client
                                      .from('users')
                                      .select('user_id')
                                      .eq('auth_id', user.id)
                                      .single();
                                  final userId = usersResponse['user_id'];

                                  final student = await Supabase.instance.client
                                      .from('students')
                                      .select('student_id')
                                      .eq('user_id', userId)
                                      .single();

                                  await Supabase.instance.client
                                      .from('students')
                                      .update({
                                        'name': name,
                                        'resume_url': resume,
                                      })
                                      .eq('student_id', student['student_id']);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Successfully updated!'),
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
                                if (isEditingName) editNameChange();
                                if (isEditingResume) editResumeChange();
                                refresh();
                              }
                            }
                          : null,
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color:
                              ((isEditingName && nameChanged) ||
                                  (isEditingResume && resumeChanged))
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
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: uniFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'University Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 7.5
                              : screenHeight / 13,
                          child: DropdownMenu<String>(
                            initialSelection: courseController.text,
                            label: Text(
                              'Course',
                              style: TextStyle(
                                color: isEditingCourse ? orange : Colors.grey,
                              ),
                            ),
                            enableSearch: false,
                            textStyle: TextStyle(
                              color: isEditingCourse
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            enabled: isEditingCourse,
                            dropdownMenuEntries: [
                              DropdownMenuEntry(value: 'NetAd', label: 'NetAd'),
                              DropdownMenuEntry(
                                value: 'WebDev',
                                label: 'WebDev',
                              ),
                              DropdownMenuEntry(value: 'EMC', label: 'EMC'),
                              DropdownMenuEntry(
                                value: 'ComSci',
                                label: 'ComSci',
                              ),
                              DropdownMenuEntry(
                                value: 'Cybersecurity',
                                label: 'Cybersecurity',
                              ),
                            ],
                            onSelected: isEditingCourse
                                ? (value) {
                                    changeCourse(value);
                                  }
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          editCourseChange();
                        },
                        icon: Icon(
                          isEditingCourse ? Icons.edit_off : Icons.edit,
                          color: orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 7.5
                              : screenHeight / 13,
                          child: DropdownMenu<String>(
                            initialSelection: yrController.text,
                            label: Text(
                              'Year Level',
                              style: TextStyle(
                                color: isEditingYr ? orange : Colors.grey,
                              ),
                            ),
                            enableSearch: false,
                            textStyle: TextStyle(
                              color: isEditingYr ? Colors.black : Colors.grey,
                            ),
                            enabled: isEditingYr,
                            dropdownMenuEntries: [
                              DropdownMenuEntry(value: '1', label: '1st Year'),
                              DropdownMenuEntry(value: '2', label: '2nd Year'),
                              DropdownMenuEntry(value: '3', label: '3rd Year'),
                              DropdownMenuEntry(value: '4', label: '4th Year'),
                            ],
                            onSelected: isEditingYr
                                ? (value) {
                                    changeYr(value);
                                  }
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          editYrChange();
                        },
                        icon: Icon(
                          isEditingYr ? Icons.edit_off : Icons.edit,
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
                          ((isEditingCourse && courseChanged) ||
                              (isEditingYr && yrChanged))
                          ? () async {
                              bool valid = false;

                              final course = courseController.text.trim();
                              final year = yrController.text.trim();

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              if (user != null) {
                                try {
                                  final usersResponse = await Supabase
                                      .instance
                                      .client
                                      .from('users')
                                      .select('user_id')
                                      .eq('auth_id', user.id)
                                      .single();
                                  final userId = usersResponse['user_id'];

                                  final student = await Supabase.instance.client
                                      .from('students')
                                      .select('student_id')
                                      .eq('user_id', userId)
                                      .single();

                                  await Supabase.instance.client
                                      .from('students')
                                      .update({
                                        'course': course,
                                        'yr_level': int.parse(year),
                                      })
                                      .eq('student_id', student['student_id']);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Successfully updated!'),
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
                                if (isEditingCourse) editCourseChange();
                                if (isEditingYr) editYrChange();
                                refresh();
                              }
                            }
                          : null,
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color:
                              ((isEditingCourse && courseChanged) ||
                                  (isEditingYr && yrChanged))
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
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text('Confirm', style: TextStyle(color: orange)),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel', style: TextStyle(color: orange)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Confirm'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Log out',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
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