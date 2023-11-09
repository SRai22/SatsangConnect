import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'circle_progress.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

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
  List<Map<String, dynamic>> dailyCounts = [];
  Timer? _timer;
  bool isEditing = false; // To toggle between text view and text field
  // Declare a TextEditingController
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadCount());
    // _startEndOfDayListener();
    _textEditingController = TextEditingController(text: '$count');
  }

  @override
  void dispose() {
    // Dispose the TextEditingController when the state is disposed
    _textEditingController.dispose();
    super.dispose();
  }

  void _loadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check for day change
    String lastDay = prefs.getString('lastDay') ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (DateFormat('yyyy-MM-dd').format(DateTime.now()) != lastDay) {
      await _saveDailyCount(lastDay, count * times);
      setState(() {
        // Reset count and times after saving
        count = 0;
        times = 0;
      });
      // Update lastDay after state is updated
      await prefs.setString(
          'lastDay', DateFormat('yyyy-MM-dd').format(DateTime.now()));
    }

    // Load daily counts outside setState
    String? dailyCountsStr = prefs.getString('dailyCounts');
    if (dailyCountsStr != null) {
      setState(() {
        dailyCounts =
            List<Map<String, dynamic>>.from(json.decode(dailyCountsStr));
      });
    }
  }

  // Method to save daily count
  Future<void> _saveDailyCount(String date, int dailyTotal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dailyCounts.add({'date': date, 'total': dailyTotal});
    // Save the updated daily counts list
    await prefs.setString('dailyCounts', json.encode(dailyCounts));
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

  List<Map<String, dynamic>> getDailyTotals() {
    // Sort the list by date in descending order.
    dailyCounts.sort((a, b) => b["date"].compareTo(a["date"]));

    // If there's more than 30 entries, take only the last 30 days.
    if (dailyCounts.length > 30) {
      dailyCounts = dailyCounts.sublist(0, 30);
    }

    // Reverse the list to have the oldest date first for the chart display.
    dailyCounts = dailyCounts.reversed.toList();

    return dailyCounts;
  }

  // This function converts your daily totals data into BarChartGroupData for the chart.
  List<BarChartGroupData> getBarGroups(List<Map<String, dynamic>> dailyTotals) {
    return List.generate(dailyTotals.length, (index) {
      final data = dailyTotals[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
              toY: data['total'].toDouble(), color: Colors.lightBlueAccent)
        ],
        showingTooltipIndicators: [0],
      );
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
    // Retrieve daily totals for the bar chart.
    List<Map<String, dynamic>> dailyTotals = getDailyTotals();
    // Convert daily totals into BarChartGroupData for the chart.
    List<BarChartGroupData> barGroups = getBarGroups(dailyTotals);
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
            Expanded(
                child: BarChart(BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final date = DateFormat('MM-dd').format(
                        DateTime.now()
                            .subtract(Duration(days: 30 - value.toInt())),
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 16,
                        child: Text(
                          date,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: false,
              ),
              borderData: FlBorderData(
                show: false,
              ),
            )))
          ],
        ),
      ),
    );
  }
}
