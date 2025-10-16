import 'package:flutter/material.dart';
import 'package:internhub/screens/viewApplicants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'package:internhub/screens/login.dart';
import 'package:internhub/screens/editListing.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewLogsPage extends StatefulWidget {
  @override
  _ViewLogsPageState createState() => _ViewLogsPageState();
}

enum Focus { home, add, settings }

class _ViewLogsPageState extends State<ViewLogsPage> {
  List<Map<String, dynamic>?> listings = [];

  Future<void> getListings() async {
    final query = await Supabase.instance.client
        .from('listing')
        .select('*, company(*)');
    setState(() {
      listings = query as List<Map<String, dynamic>?>;
    });
  }

  @override
  void initState() {
    super.initState();

    getListings();

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
          child: _listingPage(
            getListings,
            context,
            screenHeight,
            screenWidth,
            orange,
            isWide,
            listings,
          ),
        ),
      ),
    );
  }
}

Widget _listingPage(
  Future<void> Function() refreshListings,
  BuildContext context,
  double screenHeight,
  double screenWidth,
  orange,
  bool isWide,
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
            'Listings',
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
                      "There are no posted listings.",
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
    final collapsedHeight = 175.0;
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
                        Icon(
                          Icons.link,
                          color: widget.listing['link'].isNotEmpty
                              ? widget.orange
                              : Colors.grey,
                        ),
                        GestureDetector(
                          onTap: () {
                            String link = widget.listing['link'];
                            if (link.isNotEmpty) openLink(link);
                          },
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
                                ViewApplicantsPage(widget.listing, true),
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

OutlineInputBorder _inputBorder() => const OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black),
  borderRadius: BorderRadius.all(Radius.circular(12.5)),
);
