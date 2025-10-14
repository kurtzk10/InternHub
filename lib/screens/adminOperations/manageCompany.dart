import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageCompanyPage extends StatefulWidget {
  @override
  _ManageCompanyPageState createState() => _ManageCompanyPageState();
}

class _ManageCompanyPageState extends State<ManageCompanyPage> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  Timer? _debounce;
  bool _loading = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetHelper.monitor(context);
    });
    _onSearchChanged();
    _searchController.addListener(_onSearchChanged);
  }

  void updateCompanyInList(
    Map<String, dynamic> company,
    String name,
    String industry,
    bool isVerified,
  ) {
    final index = _results.indexWhere(
      (e) => e['company_id'] == company['company_id'],
    );
    if (index != 1) {
      setState(() {
        _results[index]['name'] = name;
        _results[index]['industry'] = industry;
        _results[index]['is_verified'] = isVerified;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loading = true);
      final queryText = _searchController.text.trim();
      var query = supabase
          .from('company')
          .select('*, users:users(auth_id, email)');
      if (queryText.isNotEmpty) query = query.ilike('name', '%$queryText%');
      final response = await query;
      setState(() {
        _results = response as List<dynamic>;
        _loading = false;
      });
    });
  }

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
            isWide ? screenHeight * 0.12 : screenHeight * 0.08,
          ),
          child: AppBar(
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
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search company name',
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
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _loading
                  ? SizedBox(
                      height: screenHeight - kToolbarHeight,
                      child: Center(
                        child: CircularProgressIndicator(color: orange),
                      ),
                    )
                  : _results.isEmpty
                  ? SizedBox(
                      height: screenHeight - kToolbarHeight,
                      child: Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : Column(
                      children: _results.map((company) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: CompanyCard(
                            company: company,
                            orange: orange,
                            isWide: isWide,

                            onDone: updateCompanyInList,
                            // onDelete: deleteCompany,
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyCard extends StatefulWidget {
  final Map<String, dynamic> company;
  final Color orange;
  final bool isWide;
  final void Function(Map<String, dynamic>, String, String, bool) onDone;
  // final void Function(Map<String, dynamic>) onDelete;

  const CompanyCard({
    required this.company,
    required this.orange,
    required this.isWide,
    required this.onDone,
    // required this.onDelete,
    super.key,
  });

  @override
  _CompanyCardPageState createState() => _CompanyCardPageState();
}

class _CompanyCardPageState extends State<CompanyCard> {
  late TextEditingController nameController;
  late TextEditingController industryController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  bool isEditing = false;
  bool isVerified = false;

  final supabase = Supabase.instance.client;

  @override
  initState() {
    super.initState();
    nameController = TextEditingController(text: widget.company['name']);
    industryController = TextEditingController(
      text: widget.company['industry'],
    );
    emailController = TextEditingController(
      text: widget.company['contact_email'],
    );
    numberController = TextEditingController(
      text: widget.company['contact_number'],
    );
    isVerified = widget.company['is_verified'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          width: widget.isWide
              ? MediaQuery.of(context).size.width / 1.5
              : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  floatingLabelStyle: TextStyle(
                    color: isEditing ? Colors.black : Colors.grey,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.orange, width: 2),
                  ),
                ),
                enabled: isEditing,
              ),
              TextFormField(
                controller: industryController,
                decoration: InputDecoration(
                  labelText: 'Type of Industry',
                  floatingLabelStyle: TextStyle(
                    color: isEditing ? Colors.black : Colors.grey,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.orange, width: 2),
                  ),
                ),
                enabled: isEditing,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Contact Email',
                  floatingLabelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.orange, width: 2),
                  ),
                ),
                enabled: false,
              ),
              TextFormField(
                controller: numberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  floatingLabelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.orange, width: 2),
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 16,
                      color: isEditing ? Colors.black : Colors.grey,
                    ),
                  ),
                  Checkbox(
                    value: isVerified,
                    onChanged: isEditing
                        ? (bool? value) {
                            setState(() {
                              isVerified = !isVerified;
                            });
                          }
                        : null,
                    activeColor: widget.orange,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !isEditing
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: widget.orange,
                          ),
                          onPressed: () => setState(() => isEditing = true),
                          child: Text('Edit'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey,
                          ),
                          onPressed: () => setState(() {
                            isEditing = false;
                            nameController.text = widget.company['name'];
                            industryController.text =
                                widget.company['industry'];
                            isVerified = widget.company['is_verified'];
                          }),
                          child: Text('Cancel'),
                        ),
                  !isEditing
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: Text('Delete'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final updatedName = nameController.text.trim();
                            final updatedIndustry = industryController.text
                                .trim();
                            final updatedVerificationStatus = isVerified;

                            await supabase
                                .from('company')
                                .update({
                                  'name': updatedName,
                                  'industry': updatedIndustry,
                                  'is_verified': updatedVerificationStatus,
                                })
                                .eq('company_id', widget.company['company_id']);
                            widget.onDone(
                              widget.company,
                              updatedName,
                              updatedIndustry,
                              updatedVerificationStatus,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Company record updated.'),
                              ),
                            );

                            setState(() => isEditing = false);
                          },
                          child: Text('Done'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _inputBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.circular(12.5),
  );
}
