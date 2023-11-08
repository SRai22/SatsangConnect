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
  List<int> previousCounts = []; // Stack to keep track of previous counts
  int? lastCount; // To store the last count value for undo functionality
  bool isEditing = false; // To toggle between text view and text field
  // Declare a TextEditingController
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _loadCount();

    _textEditingController = TextEditingController(text: '$count');
  }

  @override
  void dispose() {
    // Dispose the TextEditingController when the state is disposed
    _textEditingController.dispose();
    super.dispose();
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
      previousCounts.add(count);
      //lastCount = count; // Store the last count before incrementing
      count++;
      prefs.setInt(widget.sectionName, count);
    });
  }

  _undoLastAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (lastCount != null) {
      setState(() {
        count = lastCount!;
        prefs.setInt(widget.sectionName, count);
        lastCount = null; // Reset lastCount
      });
    }
  }

  _undoAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (previousCounts.isNotEmpty) {
      setState(() {
        // Revert to the previous count
        count = previousCounts.removeLast();
        prefs.setInt(widget.sectionName, count);
      });
    }
  }

  _clearCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      previousCounts.add(count);
      //lastCount = count; // Store the last count before clearing
      count = 0;
      prefs.remove(widget.sectionName);
    });
  }

  _updateCount(int newCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastCount = count; // Store the last count before manual update
      count = newCount;
      prefs.setInt(widget.sectionName, count);
      isEditing = false;
    });
  }

  Widget _countDisplay() {
    if (!isEditing) {
      return GestureDetector(
        onLongPress: () {
          setState(() {
            isEditing = true;
          });
        },
        child: Text('$count', style: Theme.of(context).textTheme.headline4),
      );
    } else {
      // Ensure the TextEditingController has the current count
      _textEditingController.text = '$count';
      // Set the selection to the entire string
      _textEditingController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textEditingController.text.length,
      );

      return TextField(
        keyboardType: TextInputType.number,
        onSubmitted: (newValue) {
          int? newCount = int.tryParse(newValue);
          if (newCount != null) _updateCount(newCount);
        },
        autofocus: true,
        // Use the existing _textEditingController
        controller: _textEditingController,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionName),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: previousCounts.isNotEmpty
                ? _undoAction
                : null, // Disable if no previous counts
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _countDisplay(),
            ElevatedButton(onPressed: _incrementCounter, child: Text('Count')),
            ElevatedButton(onPressed: _clearCounter, child: Text('Clear')),
            if (lastCount != null)
              ElevatedButton(onPressed: _undoLastAction, child: Text('Undo')),
          ],
        ),
      ),
    );
  }
}
