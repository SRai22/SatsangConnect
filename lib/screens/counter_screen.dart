import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterScreen extends StatefulWidget {
  final String sectionName;

  CounterScreen({required this.sectionName});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  _loadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt(widget.sectionName) ?? 0;
    });
  }

  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      count++;
      prefs.setInt(widget.sectionName, count);
    });
  }

  _clearCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      count = 0;
      prefs.remove(widget.sectionName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.sectionName),
            Text('$count'),
            ElevatedButton(onPressed: _incrementCounter, child: Text('Count')),
            ElevatedButton(onPressed: _clearCounter, child: Text('Clear'))
          ],
        ),
      ),
    );
  }
}
