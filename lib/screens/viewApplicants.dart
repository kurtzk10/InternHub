import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:internhub/emailService.dart';

class ViewApplicantsPage extends StatefulWidget {
  final Map<String, dynamic>? listing;
  final isAdmin;

  const ViewApplicantsPage(this.listing, this.isAdmin, {super.key});

  @override
  ViewApplicantsPageState createState() => ViewApplicantsPageState();
}

class ViewApplicantsPageState extends State<ViewApplicantsPage> {
  late Future<List<Map<String, dynamic>>> _applicationsFuture;

  Future<List<Map<String, dynamic>>> refreshApplications() async {
    final listingId = widget.listing!['listing_id'];

    if (widget.isAdmin) {
      final appResponse = await Supabase.instance.client
          .from('application')
          .select('*, students(*)')
          .eq('listing_id', listingId);
      return (appResponse as List).cast<Map<String, dynamic>>();
    }
    final appResponse = await Supabase.instance.client
        .from('application')
        .select('*, students(*)')
        .eq('listing_id', listingId)
        .neq('status', 'Rejected')
        .neq('status', 'Accepted');
    return (appResponse as List).cast<Map<String, dynamic>>();
  }

  @override
  void initState() {
    super.initState();
    _applicationsFuture = refreshApplications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final orange = const Color(0xffF5761A);
    final isWide = screenWidth > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          isWide ? screenHeight * 0.1 : screenHeight * 0.08,
        ),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: true,
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
        child: RefreshIndicator(
          color: orange,
          backgroundColor: Colors.white,
          onRefresh: () async {
            setState(() {
              _applicationsFuture = refreshApplications();
            });
            await _applicationsFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: screenHeight / 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Application List for Listing "${widget.listing!['title']}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _applicationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: screenHeight * 0.75,
                        child: Center(
                          child: CircularProgressIndicator(color: orange),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        height: screenHeight * 0.75,
                        child: Center(
                          child: Text(
                            'Error loading applicants: ${snapshot.error}',
                          ),
                        ),
                      );
                    }

                    final applications = snapshot.data ?? [];

                    if (applications.isEmpty) {
                      return Container(
                        height: screenHeight * 0.75,
                        child: const Center(
                          child: Text(
                            'There are no applications for this listing.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: applications.map<Widget>((application) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ApplicationCard(
                            application,
                            orange,
                            () async => setState(() {
                              _applicationsFuture = refreshApplications();
                            }),
                            widget.isAdmin,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApplicationCard extends StatefulWidget {
  final Map<String, dynamic> application;
  final Color orange;
  final Future<void> Function() onRefresh;
  final isAdmin;

  const ApplicationCard(
    this.application,
    this.orange,
    this.onRefresh,
    this.isAdmin, {
    super.key,
  });

  @override
  ApplicationCardState createState() => ApplicationCardState();
}

class ApplicationCardState extends State<ApplicationCard> {
  bool isExpanded = false;

  String getYearLevel(int? year) {
    switch (year) {
      case 1:
        return '1st Year';
      case 2:
        return '2nd Year';
      case 3:
        return '3rd Year';
      case 4:
        return '4th Year';
      default:
        return 'N/A';
    }
  }

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
    const collapsedHeight = 140.0;
    final student = widget.application['students'];
    final status = widget.application['status'];

    return GestureDetector(
      onTap: widget.isAdmin
          ? () {}
          : () => setState(
              () => isExpanded = !isExpanded,
            ),
      child: Material(
        color: Colors.white,
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            minHeight: collapsedHeight,
            maxHeight: isExpanded ? double.infinity : collapsedHeight,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    student['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.link, color: widget.orange),
                      GestureDetector(
                        onTap: () {
                          String link = student['resume_url'];
                          if (!link.startsWith('http://') &&
                              !link.startsWith('https://')) {
                            link = 'https://$link';
                          }
                          openLink(link);
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
                  Text(
                    '${getYearLevel(student['yr_level'])} ${student['course']} Student',
                  ),
                  widget.isAdmin ? SizedBox(height: 10) : SizedBox.shrink(),
                  widget.isAdmin
                      ? Text(
                          status,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: isExpanded ? 10 : 0),
                  if (isExpanded && !widget.isAdmin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              final update = await Supabase.instance.client
                                  .from('application')
                                  .update({'status': 'Rejected'})
                                  .eq(
                                    'application_id',
                                    widget.application['application_id'],
                                  );
                              await widget.onRefresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Rejected ${student['name']}.'),
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
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text('Reject'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => Center(
                                  child: CircularProgressIndicator(
                                    color: widget.orange,
                                  ),
                                ),
                              );
                              final update = await Supabase.instance.client
                                  .from('application')
                                  .update({'status': 'Accepted'})
                                  .eq(
                                    'application_id',
                                    widget.application['application_id'],
                                  );

                              final studentEmail = await Supabase
                                  .instance
                                  .client
                                  .from('users')
                                  .select('email')
                                  .eq('user_id', student['user_id'])
                                  .single();
                              final email = studentEmail['email'];

                              print(email);

                              final positionResponse = await Supabase
                                  .instance
                                  .client
                                  .from('listing')
                                  .select('position, company_id')
                                  .eq(
                                    'listing_id',
                                    widget.application['listing_id'],
                                  )
                                  .single();
                              final position = positionResponse['position'];
                              final company = await Supabase.instance.client
                                  .from('company')
                                  .select('name, contact_email, contact_number')
                                  .eq(
                                    'company_id',
                                    positionResponse['company_id'],
                                  )
                                  .single();

                              final success = await EmailService.sendEmail(
                                name: student['name'],
                                email: email,
                                title: position,
                                companyName: company['name'],
                                companyEmail: company['contact_email'],
                                companyContact: company['contact_number'],
                              );
                              await widget.onRefresh();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Accepted ${student['name']} and sent email.',
                                  ),
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
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: widget.orange,
                          ),
                          child: Text('Accept'),
                        ),
                      ],
                    ),
                ],
              ),
              if (!isExpanded && !widget.isAdmin)
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
