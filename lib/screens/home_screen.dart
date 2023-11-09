import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counter_screen.dart';
import 'instruction_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //List<String> sections = ['Naam Jaap', 'Hanuman Chalisa'];
  List<Map<String, dynamic>> sections = [
    {'title': 'Namm Jaap', 'icon': Icons.api},
    {'title': 'Hanuman Chalisa', 'icon': Icons.api},
    // Add other sections as necessary
  ];

  TextEditingController titleController = TextEditingController();
  IconData selectedIcon = Icons.device_unknown; // default icon

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  _loadSections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  void _addSectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Section"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // Clear the text controllers if needed
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addSection();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addSection() async {
    // Create a new section map
    Map<String, dynamic> newSection = {
      'title': titleController.text,
      'icon': selectedIcon, // This could be chosen by the user
    };

    // Add to the local list
    setState(() {
      sections.add(newSection);
    });

    // Clear the text controllers
    titleController.clear();

    // Save to shared preferences if needed
    await _saveSections();
  }

  Future<void> _saveSections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert your list of maps to a list of strings using json encode
    List<String> sectionsString =
        sections.map((section) => json.encode(section)).toList();
    await prefs.setStringList('sections', sectionsString);
  }
  // Additional methods for handleLongPress, editSection, and deleteSection should be defined similarly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Adjust the number of columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5, // Adjust the aspect ratio of the card
                ),
                itemCount: sections.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CounterScreen(
                                    sectionName: sections[index]['title'])));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            sections[index]['icon'],
                            size: 48, // Icon size
                          ),
                          SizedBox(height: 20),
                          Text(
                            sections[index]['title'],
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
