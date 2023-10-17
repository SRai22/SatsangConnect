import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'counter_screen.dart';
import 'instruction_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> sections = ['Naam Jaap', 'Hanuman Chalisa'];
  TextEditingController newSectionNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  _loadSections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sections = prefs.getStringList('sections') ?? sections;
    });
  }

  _addSection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sections.add(newSectionNameController.text);
      prefs.setStringList('sections', sections);
      newSectionNameController.clear();
    });
  }

  // Additional methods for handleLongPress, editSection, and deleteSection should be defined similarly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ...sections.map((section) => ListTile(
                title: Text(section),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CounterScreen(sectionName: section))),
              )),
          TextField(controller: newSectionNameController),
          ElevatedButton(onPressed: _addSection, child: Text('Add Section'))
        ],
      ),
    );
  }
}
