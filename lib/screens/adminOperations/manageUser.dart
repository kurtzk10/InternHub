import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageUserPage extends StatefulWidget {
  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  Timer? _debounce;
  bool _loading = false;
  String? selectedCourse;
  String? selectedYear;
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loading = true);
      final queryText = _searchController.text.trim();
      var query = supabase
          .from('students')
          .select('*, users:users(auth_id, email)');
      if (queryText.isNotEmpty) query = query.ilike('name', '%$queryText%');
      if (selectedCourse != null && selectedCourse!.isNotEmpty)
        query = query.eq('course', selectedCourse ?? '');
      if (selectedYear != null && selectedYear!.isNotEmpty)
        query = query.eq('yr_level', selectedYear ?? '');
      final response = await query;
      setState(() {
        _results = response as List<dynamic>;
        _loading = false;
      });
    });
  }

  void updateStudentInList(
    Map<String, dynamic> student,
    String name,
    String course,
    int year,
  ) {
    final index = _results.indexWhere(
      (e) => e['student_id'] == student['student_id'],
    );
    if (index != -1) {
      setState(() {
        _results[index]['name'] = name;
        _results[index]['course'] = course;
        _results[index]['yr_level'] = year;
      });
    }
  }

  Future<void> deleteStudent(Map<String, dynamic> student) async {
    final url = Uri.parse(
      'https://mgmvynmmdqbnzlandlmr.supabase.co/functions/v1/delete_student',
    );
    final authId = student['users']['auth_id'];
    final studentId = student['student_id'];
    setState(() => _results.remove(student));

    final serviceRoleKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nbXZ5bm1tZHFibnpsYW5kbG1yIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTc3MDM1MSwiZXhwIjoyMDc1MzQ2MzUxfQ.-AXDwz7s1PApG5zlComqe6QnDBNvu2TEbwqN_Ez-e9U';
    final response = await http.post(
      url,
      body: jsonEncode({'student_id': studentId, 'auth_id': authId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serviceRoleKey',
      },
    );

    if (response.statusCode != 200) {
      setState(() => _results.add(student));
      try {
        final data = jsonDecode(response.body);
        print('Delete error: $data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${data['error'] ?? 'Unknown'}')),
        );
      } catch (e) {
        print('Delete error: ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
      }
    } else {
      final data = jsonDecode(response.body);
      print('Delete success: $data');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Student deleted')));
    }
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
                      hintText: 'Search student name',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Expanded(
                    child: Center(
                      child: DropdownMenu<String>(
                        initialSelection: 'All Courses',
                        dropdownMenuEntries: [
                          DropdownMenuEntry(value: 'NetAd', label: 'NetAd'),
                          DropdownMenuEntry(value: 'WebDev', label: 'WebDev'),
                          DropdownMenuEntry(value: 'EMC', label: 'EMC'),
                          DropdownMenuEntry(value: 'ComSci', label: 'ComSci'),
                          DropdownMenuEntry(
                            value: 'Cybersecurity',
                            label: 'Cybersecurity',
                          ),
                          DropdownMenuEntry(
                            value: 'All Courses',
                            label: 'All Courses',
                          ),
                        ],
                        onSelected: (value) {
                          setState(() {
                            selectedCourse = value == 'All Courses'
                                ? ''
                                : value;
                            _onSearchChanged();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: DropdownMenu<String>(
                        initialSelection: 'All Years',
                        dropdownMenuEntries: [
                          DropdownMenuEntry(value: '1', label: '1st Year'),
                          DropdownMenuEntry(value: '2', label: '2nd Year'),
                          DropdownMenuEntry(value: '3', label: '3rd Year'),
                          DropdownMenuEntry(value: '4', label: '4th Year'),
                          DropdownMenuEntry(
                            value: 'All Years',
                            label: 'All Years',
                          ),
                        ],
                        onSelected: (value) {
                          setState(() {
                            selectedYear = value == 'All Years' ? '' : value;
                            _onSearchChanged();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _loading
                  ? SizedBox(
                      height: screenHeight * 0.7 - kToolbarHeight,
                      child: Center(
                        child: CircularProgressIndicator(color: orange),
                      ),
                    )
                  : _results.isEmpty
                  ? SizedBox(
                      height: screenHeight * 0.7 - kToolbarHeight,
                      child: Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : Column(
                      children: _results
                          .where(
                            (student) =>
                                !student.values.any((value) => value == null),
                          )
                          .map((student) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: StudentCard(
                                student: student,
                                orange: orange,
                                isWide: isWide,
                                onDone: updateStudentInList,
                                onDelete: deleteStudent,
                              ),
                            );
                          })
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentCard extends StatefulWidget {
  final Map<String, dynamic> student;
  final Color orange;
  final bool isWide;
  final void Function(Map<String, dynamic>, String, String, int) onDone;
  final void Function(Map<String, dynamic>) onDelete;

  const StudentCard({
    required this.student,
    required this.orange,
    required this.isWide,
    required this.onDone,
    required this.onDelete,
    super.key,
  });

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  late TextEditingController nameController;
  late String selectedCourse;
  late String selectedYear;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student['name']);
    selectedCourse = widget.student['course'];
    selectedYear = widget.student['yr_level'].toString();
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(
      text: widget.student['users']['email'],
    );
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
              SizedBox(height: 10),
              DropdownMenu<String>(
                initialSelection: selectedCourse,
                label: Text('Course'),
                enableSearch: false,
                textStyle: TextStyle(
                  color: isEditing ? Colors.black : Colors.grey,
                ),
                enabled: isEditing,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: 'NetAd', label: 'NetAd'),
                  DropdownMenuEntry(value: 'WebDev', label: 'WebDev'),
                  DropdownMenuEntry(value: 'EMC', label: 'EMC'),
                  DropdownMenuEntry(value: 'ComSci', label: 'ComSci'),
                  DropdownMenuEntry(
                    value: 'Cybersecurity',
                    label: 'Cybersecurity',
                  ),
                ],
                onSelected: isEditing
                    ? (value) => setState(() => selectedCourse = value!)
                    : null,
              ),
              SizedBox(height: 10),
              DropdownMenu<String>(
                initialSelection: selectedYear,
                label: Text('Year Level'),
                enableSearch: false,
                textStyle: TextStyle(
                  color: isEditing ? Colors.black : Colors.grey,
                ),
                enabled: isEditing,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: '1', label: '1st Year'),
                  DropdownMenuEntry(value: '2', label: '2nd Year'),
                  DropdownMenuEntry(value: '3', label: '3rd Year'),
                  DropdownMenuEntry(value: '4', label: '4th Year'),
                ],
                onSelected: isEditing
                    ? (value) => setState(() => selectedYear = value!)
                    : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                  !isEditing
                      ? ElevatedButton(
                          onPressed: () => setState(() => isEditing = true),
                          child: Text('Edit'),
                        )
                      : ElevatedButton(
                          onPressed: () => setState(() {
                            isEditing = false;
                            selectedCourse = widget.student['course'];
                            selectedYear = widget.student['yr_level']
                                .toString();
                            nameController.text = widget.student['name'];
                          }),
                          child: Text('Cancel'),
                        ),
                  !isEditing
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => widget.onDelete(widget.student),
                          child: Text('Delete'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final updatedName = nameController.text.trim();
                            final updatedCourse = selectedCourse;
                            final updatedYear = int.parse(selectedYear);
                            await Supabase.instance.client
                                .from('students')
                                .update({
                                  'name': updatedName,
                                  'course': updatedCourse,
                                  'yr_level': updatedYear,
                                })
                                .eq('student_id', widget.student['student_id']);
                            widget.onDone(
                              widget.student,
                              updatedName,
                              updatedCourse,
                              updatedYear,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Student record updated.'),
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
