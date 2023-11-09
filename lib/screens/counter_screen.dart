import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'circle_progress.dart';
import 'package:fl_chart/fl_chart.dart';

class CounterScreen extends StatefulWidget {
  final String sectionName;

  CounterScreen({required this.sectionName});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int count = 0;
  int times = 0;
  List<Map<String, int>> previousCounts =
      []; // Changed to Map to keep track of both count and times
  Timer? _timer;
  bool isEditing = false; // To toggle between text view and text field
  // Declare a TextEditingController
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _loadCount();
    _startEndOfDayListener();
    _textEditingController = TextEditingController(text: '$count');
  }

  @override
  void dispose() {
    // Dispose the TextEditingController when the state is disposed
    _textEditingController.dispose();
    super.dispose();
  }

  void _startEndOfDayListener() {
    _timer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) => _checkEndOfDay());
  }

  void _checkEndOfDay() async {
    var now = DateTime.now();
    if (now.hour == 23 && now.minute == 59 && now.second == 59) {
      await _saveCount();
      setState(() {
        count = 0;
      });
    }
  }

  Future<void> _saveCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCounts = prefs.getStringList('saved_counts') ?? [];
    String dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    savedCounts.add('$dateStamp: $count');
    await prefs.setStringList('saved_counts', savedCounts);
    await prefs.setInt(widget.sectionName, 0);
  }

  _loadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedCount = prefs.getInt(widget.sectionName) ?? 0;
    String lastDate = prefs.getString('${widget.sectionName}_date') ?? '';
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // If it's a new day and the app wasn't opened, save the count and reset it.
    if (lastDate.isNotEmpty && lastDate != today) {
      List<String> savedCounts =
          prefs.getStringList('${widget.sectionName}_counts') ?? [];
      savedCounts.add('$lastDate: $savedCount');
      await prefs.setStringList('${widget.sectionName}_counts', savedCounts);
      savedCount = 0; // Reset the count for the new day
    }

    setState(() {
      count = savedCount;
      prefs.setInt(widget.sectionName, savedCount);
      prefs.setString(
          '${widget.sectionName}_date', today); // Save the current date
    });
  }

  void _incrementCounter() {
    setState(() {
      previousCounts
          .add({'count': count, 'times': times}); // Save previous state
      count++;
      if (count > 108) {
        count = 0;
        times++;
      }
    });
  }

  void _undoAction() {
    if (previousCounts.isNotEmpty) {
      setState(() {
        // Retrieve the last state from the list of previous states.
        Map<String, int> previousState = previousCounts.removeLast();
        // Use the retrieved values to update the count and times.
        count = previousState['count'] ?? 0; // Fallback to 0 if null
        times = previousState['times'] ?? 0; // Fallback to 0 if null
      });
    }
  }

  void _clearCounter() {
    setState(() {
      previousCounts.add({
        'count': count,
        'times': times
      }); // Save previous state before clearing
      count = 0;
      times = 0;
    });
  }

  _updateCount(int newCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      count = newCount;
      prefs.setInt(widget.sectionName, count);
      isEditing = false;
    });
  }

  Widget _buildSavedCountsTable() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        List<String>? savedCounts =
            snapshot.data?.getStringList('saved_counts');
        if (savedCounts == null || savedCounts.isEmpty) {
          return const Center(child: Text('No saved counts'));
        }
        return ListView.separated(
          itemCount: savedCounts.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(savedCounts[index]),
            );
          },
        );
      },
    );
  }

  Widget _timesDisplay() {
    return Text(
      'Times: $times',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _countDisplay() {
    if (!isEditing) {
      return GestureDetector(
        onLongPress: () {
          setState(() {
            isEditing = true;
          });
        },
        child: Text('$count', style: Theme.of(context).textTheme.headlineLarge),
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
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            const SizedBox(height: 20), // Spacing
            GestureDetector(
              onTap: _incrementCounter, // Increment counter on tap
              child: CustomPaint(
                painter: CircleProgress(
                    count / 108 * 100), // Adjust the ratio as per the goal
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[_countDisplay(), _timesDisplay()],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Spacing
            ElevatedButton(
                onPressed: _clearCounter, child: const Text('Clear')),
          ],
        ),
      ),
    );
  }
}
