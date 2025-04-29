import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/user_model.dart';
import '../models/japam_model.dart';
import '../models/ritual_model.dart';
import '../models/google_sheets_api.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isSyncing = false;
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final japamModel = Provider.of<JapamModel>(context);
    final ritualModel = Provider.of<RitualModel>(context);

    // Get the month name for display
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth);

    // Get entries for the selected month
    final japamEntries = japamModel.getEntriesForMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    // Calculate total count for the month
    final totalJapamCount = japamEntries.fold(
      0,
      (sum, entry) => sum + entry.totalCount,
    );

    // Get ritual statuses for the month
    final tarapanmStatus = ritualModel.getRitualStatus(
      RitualType.tarapanm,
      _selectedMonth,
    );

    final homamStatus = ritualModel.getRitualStatus(
      RitualType.homam,
      _selectedMonth,
    );

    final danamStatus = ritualModel.getRitualStatus(
      RitualType.danam,
      _selectedMonth,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        actions: [
          // Sync button
          if (userModel.isLoggedIn)
            IconButton(
              icon:
                  _isSyncing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.sync),
              onPressed:
                  _isSyncing
                      ? null
                      : () async {
                        setState(() {
                          _isSyncing = true;
                        });

                        // Sync with Google Sheets
                        final success = await GoogleSheetsApi.syncAllData(
                          userModel,
                          japamModel.entries,
                          ritualModel.entries,
                        );

                        setState(() {
                          _isSyncing = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Data synced successfully'
                                  : 'Failed to sync data',
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month selector
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
                        'Monthly Status',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedMonth,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDatePickerMode: DatePickerMode.year,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppTheme.primaryRed,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (date != null) {
                            setState(() {
                              _selectedMonth = DateTime(date.year, date.month);
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                monthName,
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

              // Japam Summary
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
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.japamPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.list_rounded,
                              color: AppTheme.japamPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Japam',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppTheme.japamPurple),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Japam count for the month
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.japamPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Count for $monthName',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalJapamCount.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: AppTheme.japamPurple,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Days practiced
                      Text(
                        'Days Practiced: ${japamEntries.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Average per day
                      Text(
                        'Average per Day: ${japamEntries.isEmpty ? 0 : (totalJapamCount / japamEntries.length).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Rituals Summary
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
                        'Rituals for $monthName',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Tarapanm Status
                      _buildRitualStatusItem(
                        context,
                        'Tharpanam',
                        tarapanmStatus?.completed ?? false,
                        AppTheme.tarapanmTeal,
                        Icons.water_drop_outlined,
                      ),

                      const SizedBox(height: 12),

                      // Homam Status
                      _buildRitualStatusItem(
                        context,
                        'Homam',
                        homamStatus?.completed ?? false,
                        AppTheme.homamOrange,
                        Icons.local_fire_department_outlined,
                      ),

                      const SizedBox(height: 12),

                      // Danam Status
                      _buildRitualStatusItem(
                        context,
                        'Dhanam',
                        danamStatus?.completed ?? false,
                        AppTheme.danamGreen,
                        Icons.spa_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Overall Status
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
                        'Overall Yearly Status',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Yearly progress bar
                      _buildYearlyProgress(
                        context,
                        ritualModel,
                        _selectedMonth.year,
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

  Widget _buildRitualStatusItem(
    BuildContext context,
    String title,
    bool completed,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: completed ? color : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              completed ? 'Completed' : 'Not Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: completed ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyProgress(
    BuildContext context,
    RitualModel ritualModel,
    int year,
  ) {
    // Get yearly status for all ritual types
    final yearlyStatus = ritualModel.getYearlyStatus(year);

    // Calculate completion percentages
    final tarapanmCompleted =
        yearlyStatus[RitualType.tarapanm]!
            .where((completed) => completed)
            .length;
    final homamCompleted =
        yearlyStatus[RitualType.homam]!.where((completed) => completed).length;
    final danamCompleted =
        yearlyStatus[RitualType.danam]!.where((completed) => completed).length;

    // Calculate overall completion
    final totalCompleted = tarapanmCompleted + homamCompleted + danamCompleted;
    final totalPossible = 36; // 3 rituals * 12 months
    final completionPercentage = totalCompleted / totalPossible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall progress
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Completion',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage,
                      backgroundColor: Colors.grey[300],
                      color: AppTheme.primaryRed,
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${(completionPercentage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.primaryRed,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Individual ritual progress
        _buildRitualProgress(
          'Tharpanam',
          tarapanmCompleted / 12,
          AppTheme.tarapanmTeal,
        ),

        const SizedBox(height: 8),

        _buildRitualProgress(
          'Homam',
          homamCompleted / 12,
          AppTheme.homamOrange,
        ),

        const SizedBox(height: 8),

        _buildRitualProgress(
          'Dhanam',
          danamCompleted / 12,
          AppTheme.danamGreen,
        ),
      ],
    );
  }

  Widget _buildRitualProgress(String title, double progress, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}
