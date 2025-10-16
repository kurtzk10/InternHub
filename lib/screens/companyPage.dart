import 'package:flutter/material.dart';
import 'package:internhub/screens/viewApplicants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'package:internhub/screens/editListing.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final _loginFormKey = GlobalKey<FormState>();
  final _companyFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

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
    final orange = Color(0xffF5761A);
    final selectedOrange = Color(0xffD26217);
    final isWide = screenWidth > 600;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
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

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth / 10),
          child: focus == Focus.home
              ? _homePage(
                  getListings,
                  context,
                  screenHeight,
                  screenWidth,
                  orange,
                  isWide,
                  companyDetails,
                  listings,
                )
              : focus == Focus.add
              ? _addPage(
                  context,
                  screenHeight,
                  screenWidth,
                  orange,
                  _listingFormKey,
                  isWide,
                  companyDetails!['is_verified'],
                  _titleController,
                  _positionController,
                  _locationController,
                  _durationController,
                  _descriptionController,
                  _requirementsController,
                  _linkController,
                  (value) => setState(() {
                    _durationController.text = value;
                  }),
                  _controllers,
                  _addRequirement,
                  () => setState(() {
                    _controllers
                      ..clear()
                      ..add(TextEditingController());
                    _titleController.text = '';
                    _positionController.text = '';
                    _locationController.text = '';
                    _durationController.text = '';
                    _descriptionController.text = '';
                    _requirementsController.text = '';
                    _linkController.text = '';
                  }),
                  () => setState(() {
                    focus = Focus.home;
                  }),
                  companyDetails!['company_id'],
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
                  _industryController,
                  _contactController,
                  _numberController,
                  _loginFormKey,
                  _companyFormKey,
                  _contactFormKey,
                  isEditingEmail,
                  isEditingPassword,
                  isEditingName,
                  isEditingIndustry,
                  isEditingContact,
                  isEditingNumber,
                  isPasswordPlain,
                  emailChanged,
                  passwordChanged,
                  nameChanged,
                  industryChanged,
                  contactChanged,
                  numberChanged,
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
                    isEditingIndustry = !isEditingIndustry;
                  }),
                  () => setState(() {
                    isEditingContact = !isEditingContact;
                  }),
                  () => setState(() {
                    isEditingNumber = !isEditingNumber;
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
                            isEditingIndustry = false;
                            isEditingContact = false;
                            isEditingNumber = false;
                          });

                          await getListings();
                        },
                  child: Icon(Icons.home, color: Colors.white, size: 25),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: focus == Focus.add
                        ? selectedOrange
                        : orange,
                    minimumSize: Size(screenHeight, double.infinity),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: focus == Focus.add
                      ? null
                      : () {
                          setState(() {
                            focus = Focus.add;
                            isEditingEmail = false;
                            isEditingPassword = false;
                            isEditingName = false;
                            isEditingIndustry = false;
                            isEditingContact = false;
                            isEditingNumber = false;
                          });
                        },
                  child: Icon(Icons.add, color: Colors.white, size: 25),
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
  bool isWide,
  companyDetails,
  listings,
) {
  return RefreshIndicator(
    color: orange,
    backgroundColor: Colors.white,
    onRefresh: refreshListings,
    child: SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your Listings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          listings.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: listings.map<Widget>((listing) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: ListingCard(listing, orange, refreshListings),
                    );
                  }).toList(),
                )
              : SizedBox(
                  height: screenHeight * 0.7,
                  child: Center(
                    child: Text(
                      "You don't have any posted listings.",
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
  final Future<void> Function() onRefresh;

  const ListingCard(this.listing, this.orange, this.onRefresh, {super.key});
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
    final collapsedHeight = 160.0;
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
                  const SizedBox(height: 4),
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
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (isExpanded) ...[
                    const SizedBox(height: 10),
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
                        Icon(Icons.link, color: widget.orange),
                        GestureDetector(
                          onTap: () {
                            String link = widget.listing['link'];
                            if (!link.startsWith('http://') &&
                                !link.startsWith('https://')) {
                              link = 'https://$link';
                            }
                            if (link != null && link.isNotEmpty) openLink(link);
                          },
                          child: Text(
                            'LinkedIn',
                            style: TextStyle(
                              color: widget.orange,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: widget.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: widget.orange,
                          ),
                          onPressed: () {
                            print(requirements);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    EditListingPage(widget.listing),
                                transitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Text('Edit'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text(
                                    'Confirm',
                                    style: TextStyle(color: widget.orange),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to delete this listing?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: widget.orange),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: widget.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Confirm'),
                                      onPressed: () async {
                                        try {
                                          final delete = await Supabase
                                              .instance
                                              .client
                                              .from('listing')
                                              .delete()
                                              .eq(
                                                'listing_id',
                                                widget.listing['listing_id'],
                                              );
                                          await widget.onRefresh();
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Successfully deleted.",
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        } on AuthException catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(e.message),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              Positioned(
                right: 0,
                child: Center(
                  child: Container(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                ViewApplicantsPage(widget.listing, false),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      },
                      icon: Icon(Icons.group, color: widget.orange),
                    ),
                  ),
                ),
              ),
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

Widget _addPage(
  BuildContext context,
  double screenHeight,
  double screenWidth,
  orange,
  formKey,
  bool isWide,
  bool isVerified,
  titleController,
  positionController,
  locationController,
  durationController,
  descriptionController,
  requirementsController,
  linkController,
  void Function(dynamic) setDuration,
  controllers,
  VoidCallback addRequirement,
  VoidCallback clearControllers,
  VoidCallback backHome,
  companyId,
) {
  return isVerified
      ? SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: screenHeight / 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Text(
                'Create Listing',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: isWide ? screenHeight / 8 : screenHeight / 16,
                      child: TextFormField(
                        controller: titleController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: isWide ? screenHeight / 10 : screenHeight / 20,
                      child: TextFormField(
                        controller: positionController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Job Position *',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: isWide ? screenHeight / 10 : screenHeight / 20,
                      child: TextFormField(
                        controller: locationController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Job Location *',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DropdownMenu<String>(
                          width: screenWidth * 0.8,
                          hintText: 'Duration Type *',
                          enableSearch: false,
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: 'Part Time',
                              label: 'Part Time',
                            ),
                            DropdownMenuEntry(
                              value: 'Full Time',
                              label: 'Full Time',
                            ),
                          ],
                          onSelected: (value) {
                            setDuration(value);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: TextFormField(
                        minLines: 5,
                        maxLines: 5,
                        controller: descriptionController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Listing Description',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Requirements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      spacing: 10,
                      children: [
                        ...controllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;

                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: isWide
                                      ? screenHeight / 10
                                      : screenHeight / 20,
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      hintText: 'Requirement',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      border: _inputBorder(),
                                      enabledBorder: _inputBorder(),
                                      focusedBorder: _inputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  controllers.removeAt(index);
                                  (context as Element).markNeedsBuild();
                                },
                              ),
                            ],
                          );
                        }),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              elevation: 5,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: addRequirement,
                            child: Icon(Icons.add, color: orange),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: isWide ? screenHeight / 10 : screenHeight / 20,
                      child: TextFormField(
                        controller: linkController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: 'LinkedIn Link *',
                          suffixIcon: IconButton(
                            style: IconButton.styleFrom(
                              overlayColor: Colors.transparent,
                            ),
                            onPressed: () {
                              linkController.text = '';
                            },
                            icon: Icon(Icons.close),
                          ),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final position = positionController.text.trim();
                          final location = locationController.text.trim();
                          final duration = durationController.text.trim();
                          final description = descriptionController.text.trim();
                          final requirements = controllers
                              .map((controller) => controller.text.trim())
                              .where((text) => true && text.isNotEmpty)
                              .join('\n');
                          final link = linkController.text.trim();

                          final linkedInPostRegex = RegExp(
                            r'^https?:\/\/(?:www\.|m\.)?linkedin\.com\/(?:feed\/update\/urn:li:(?:activity|share):(\d+)|posts\/([^\/?]+)|company\/[^\/]+\/posts\/([^\/?]+))(?:[\/?].*)?$',
                            caseSensitive: false,
                          );

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Title can't be empty."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (position.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Job position can't be empty."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (location.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Location can't be empty."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (duration.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please pick a duration type."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          if (link.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("LinkedIn link can't be empty."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (!linkedInPostRegex.hasMatch(link)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Must be a valid LinkedIn link."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          try {
                            final addListing = await Supabase.instance.client
                                .from('listing')
                                .insert({
                                  'company_id': companyId,
                                  'title': title,
                                  'position': position,
                                  'location': location,
                                  'duration': duration,
                                  'description': description,
                                  'requirements': requirements,
                                  'link': link,
                                });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Successfully posted!"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            clearControllers();
                          } on AuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Create',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        )
      : Center(
          child: Text(
            'You are currently unverified. Contact a coordinator or administrator to help you get verified.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
  industryController,
  contactController,
  numberController,
  loginFormKey,
  companyFormKey,
  contactFormKey,
  bool isEditingEmail,
  bool isEditingPassword,
  bool isEditingName,
  bool isEditingIndustry,
  bool isEditingContact,
  bool isEditingNumber,
  bool isPasswordPlain,
  bool emailChanged,
  bool passwordChanged,
  bool nameChanged,
  bool industryChanged,
  bool contactChanged,
  bool numberChanged,
  VoidCallback editEmailChange,
  VoidCallback editPasswordChange,
  VoidCallback editNameChange,
  VoidCallback editIndustryChange,
  VoidCallback editContactChange,
  VoidCallback editNumberChange,
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
            padding: const EdgeInsetsGeometry.all(16),
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
        SizedBox(height: 20),
        Material(
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsetsGeometry.all(16),
            child: Form(
              key: companyFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Information',
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
                              labelText: 'Company Name',
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
                    children: [
                      Expanded(
                        child: Container(
                          height: isWide
                              ? screenHeight / 10
                              : screenHeight / 20,
                          child: TextFormField(
                            controller: industryController,
                            enabled: isEditingIndustry,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Type of Industry',
                              floatingLabelStyle: TextStyle(
                                color: isEditingIndustry ? orange : null,
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
                        onPressed: () => editIndustryChange(),
                        icon: Icon(
                          isEditingIndustry ? Icons.edit_off : Icons.edit,
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
                              (isEditingIndustry && industryChanged))
                          ? () async {
                              final name = nameController.text.trim();
                              final industry = industryController.text.trim();

                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Company Name can't be empty.",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              if (industry.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Type of Industry can't be empty.",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              final usersResponse = await Supabase
                                  .instance
                                  .client
                                  .from('users')
                                  .select('user_id')
                                  .eq('auth_id', user!.id)
                                  .single();

                              final userId = usersResponse['user_id'];

                              try {
                                final update = await Supabase.instance.client
                                    .from('company')
                                    .update({
                                      'name': name,
                                      'industry': industry,
                                    })
                                    .eq('user_id', userId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Successfully updated.'),
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
                            }
                          : null,
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color:
                              ((isEditingName && nameChanged) ||
                                  (isEditingIndustry && industryChanged))
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
            padding: const EdgeInsetsGeometry.all(16),
            child: Form(
              key: contactFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
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
                            controller: contactController,
                            enabled: isEditingContact,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Contact Email',
                              floatingLabelStyle: TextStyle(
                                color: isEditingContact ? orange : null,
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
                        onPressed: () => editContactChange(),
                        icon: Icon(
                          isEditingContact ? Icons.edit_off : Icons.edit,
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
                            controller: numberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [NumberFormatter()],
                            enabled: isEditingNumber,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              labelText: 'Contact Number',
                              floatingLabelStyle: TextStyle(
                                color: isEditingNumber ? orange : null,
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
                        onPressed: () => editNumberChange(),
                        icon: Icon(
                          isEditingNumber ? Icons.edit_off : Icons.edit,
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
                          ((isEditingContact && contactChanged) ||
                              (isEditingNumber && numberChanged))
                          ? () async {
                              final contact = nameController.text.trim();
                              final number = numberController.text.replaceAll(
                                ' ',
                                '',
                              );

                              if (contact.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Contact Email Adress can't be empty.",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              if (number.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Contact Number can't be empty.",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }

                              final user =
                                  Supabase.instance.client.auth.currentUser;

                              final usersResponse = await Supabase
                                  .instance
                                  .client
                                  .from('users')
                                  .select('user_id')
                                  .eq('auth_id', user!.id)
                                  .single();

                              final userId = usersResponse['user_id'];

                              try {
                                final update = await Supabase.instance.client
                                    .from('company')
                                    .update({
                                      'contact_email': contact,
                                      'contact_number': number,
                                    })
                                    .eq('user_id', userId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Successfully updated.'),
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
                            }
                          : null,
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color:
                              ((isEditingContact && contactChanged) ||
                                  (isEditingNumber && numberChanged))
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
                    color: Colors.black,
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

OutlineInputBorder _inputBorder() => const OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black),
  borderRadius: BorderRadius.all(Radius.circular(12.5)),
);
