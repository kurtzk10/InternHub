import 'package:flutter/material.dart';
import 'package:internhub/screens/companyPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internhub/internetHelper.dart';

class EditListingPage extends StatefulWidget {
  final Map<String, dynamic> listing;

  EditListingPage(this.listing, {super.key});

  @override
  _EditListingPageState createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  final List<TextEditingController> _controllers = [TextEditingController()];

  void loadListing() {
    _titleController.text = widget.listing['title'];
    _positionController.text = widget.listing['position'];
    _locationController.text = widget.listing['location'];
    _durationController.text = widget.listing['duration'];
    _descriptionController.text = widget.listing['description'];
    _linkController.text = widget.listing['link'];

    List<String> requirements = widget.listing['requirements'].split('\n');

    if (requirements != []) {
      _controllers
        ..clear()
        ..addAll(requirements.map((req) => TextEditingController(text: req)));
    }
  }

  void _addRequirement() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  @override
  void initState() {
    super.initState();
    loadListing();

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
            iconTheme: IconThemeData(color: Colors.white),
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
          child: editListing(
            context,
            screenHeight,
            screenWidth,
            orange,
            _formKey,
            isWide,
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
            widget.listing['listing_id'],
          ),
        ),
      ),
    );
  }
}

Widget editListing(
  BuildContext context,
  double screenHeight,
  double screenWidth,
  orange,
  formKey,
  bool isWide,
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
  listingId,
) {
  return SingleChildScrollView(
    padding: EdgeInsets.symmetric(vertical: screenHeight / 100),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 10),
        Text(
          'Edit Listing',
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
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _inputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: isWide ? screenHeight / 10 : screenHeight / 20,
                child: TextFormField(
                  controller: positionController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: 'Job Position *',
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _inputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: isWide ? screenHeight / 10 : screenHeight / 20,
                child: TextFormField(
                  controller: locationController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: 'Job Location *',
                    floatingLabelStyle: TextStyle(color: Colors.black),
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
                    initialSelection: durationController.text,
                    width: screenWidth * 0.8,
                    label: Text(
                      'Duration Type *',
                      style: TextStyle(color: Colors.black),
                    ),
                    enableSearch: false,
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'Part Time', label: 'Part Time'),
                      DropdownMenuEntry(value: 'Full Time', label: 'Full Time'),
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
                    labelText: 'Listing Description',
                    floatingLabelStyle: TextStyle(color: Colors.black),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                hintStyle: TextStyle(color: Colors.grey[400]),
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
                          icon: const Icon(Icons.close, color: Colors.grey),
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
                    labelText: 'LinkedIn Link *',
                    floatingLabelStyle: TextStyle(color: Colors.black),
                    suffixIcon: IconButton(
                        style: IconButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () {
                          linkController.text = '';
                        },
                        icon: Icon(Icons.close),
                      ),
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
                      final updateListing = await Supabase.instance.client
                          .from('listing')
                          .update({
                            'title': title,
                            'position': position,
                            'location': location,
                            'duration': duration,
                            'description': description,
                            'requirements': requirements,
                            'link': link,
                          })
                          .eq('listing_id', listingId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Successfully posted!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      clearControllers();
                      Navigator.pop(context);
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
                    'Update',
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
  );
}

OutlineInputBorder _inputBorder() => const OutlineInputBorder(
  borderSide: BorderSide(color: Colors.black),
  borderRadius: BorderRadius.all(Radius.circular(12.5)),
);
