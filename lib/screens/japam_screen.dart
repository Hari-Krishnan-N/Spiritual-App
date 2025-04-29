import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/japam_model.dart';

class JapamScreen extends StatefulWidget {
  const JapamScreen({super.key});

  @override
  _JapamScreenState createState() => _JapamScreenState();
}

class _JapamScreenState extends State<JapamScreen> {
  late DateTime _selectedDate;
  late int _standardCount;
  late int _extraCount;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Initialize counts with the default or saved values
    _standardCount = 112; // Default
    _extraCount = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load the current entry if it exists
    final japamModel = Provider.of<JapamModel>(context, listen: false);

    // Get default count from the model
    _standardCount = japamModel.defaultJapamCount;

    // Check if we have an entry for today and load it
    final existingEntry = japamModel.getEntryForDate(_selectedDate);
    if (existingEntry != null) {
      _standardCount = existingEntry.standardCount;
      _extraCount = existingEntry.extraCount;
    }
  }

  void _saveEntry() {
    final japamModel = Provider.of<JapamModel>(context, listen: false);

    japamModel.addEntry(
      date: _selectedDate,
      standardCount: _standardCount,
      extraCount: _extraCount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Japam entry saved for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
        ),
        backgroundColor: AppTheme.japamPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final japamModel = Provider.of<JapamModel>(context);
    final heatmapData = japamModel.getHeatmapData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Japam Tracker'),
        backgroundColor: AppTheme.japamPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppTheme.japamPurple,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (date != null) {
                            setState(() {
                              _selectedDate = date;

                              // Check if we have an entry for this date
                              final existingEntry = japamModel.getEntryForDate(
                                _selectedDate,
                              );
                              if (existingEntry != null) {
                                _standardCount = existingEntry.standardCount;
                                _extraCount = existingEntry.extraCount;
                              } else {
                                // Use default values
                                _standardCount = japamModel.defaultJapamCount;
                                _extraCount = 0;
                              }
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.japamPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'MMMM d, yyyy',
                                ).format(_selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Japam Counter
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Japam Count',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Standard Count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Standard (${japamModel.defaultJapamCount})',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.japamPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed:
                                      _standardCount > 0
                                          ? () {
                                            setState(() {
                                              _standardCount =
                                                  0; // Reset to zero
                                            });
                                          }
                                          : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    _standardCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _standardCount =
                                          japamModel.defaultJapamCount;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Extra Count
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Extra',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.japamPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed:
                                      _extraCount > 0
                                          ? () {
                                            setState(() {
                                              _extraCount--;
                                            });
                                          }
                                          : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    _extraCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _extraCount++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Total
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.japamPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Count',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (_standardCount + _extraCount).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                                color: AppTheme.japamPurple,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.japamPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Heatmap Calendar
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity Calendar',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      HeatMapCalendar(
                        datasets: heatmapData,
                        colorMode: ColorMode.color,
                        colorsets: {
                          1: AppTheme.japamPurple.withOpacity(0.3),
                          112: AppTheme.japamPurple.withOpacity(0.5),
                          224: AppTheme.japamPurple.withOpacity(0.7),
                          336: AppTheme.japamPurple,
                        },
                        onClick: (date) {
                          setState(() {
                            _selectedDate = date;

                            // Check if we have an entry for this date
                            final existingEntry = japamModel.getEntryForDate(
                              _selectedDate,
                            );
                            if (existingEntry != null) {
                              _standardCount = existingEntry.standardCount;
                              _extraCount = existingEntry.extraCount;
                            } else {
                              // Use default values
                              _standardCount = japamModel.defaultJapamCount;
                              _extraCount = 0;
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('No Japam', Colors.white),
                          const SizedBox(width: 16),
                          _buildLegendItem(
                            '1 Set',
                            AppTheme.japamPurple.withOpacity(0.3),
                          ),
                          const SizedBox(width: 16),
                          _buildLegendItem(
                            '2+ Sets',
                            AppTheme.japamPurple.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Monthly Stats
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Stats',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      _buildStatItem(
                        'Current Month Total',
                        japamModel.currentMonthTotal.toString(),
                      ),
                      const SizedBox(height: 12),
                      _buildStatItem(
                        'All-Time Total',
                        japamModel.totalJapamCount.toString(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.japamPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTheme.japamPurple,
            ),
          ),
        ],
      ),
    );
  }
}
