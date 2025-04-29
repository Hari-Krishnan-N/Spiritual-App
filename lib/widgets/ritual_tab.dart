import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/ritual_model.dart';

class RitualTab extends StatefulWidget {
  final RitualType type;
  final DateTime selectedMonth;
  final Color color;

  const RitualTab({
    super.key,
    required this.type,
    required this.selectedMonth,
    required this.color,
  });

  @override
  _RitualTabState createState() => _RitualTabState();
}

class _RitualTabState extends State<RitualTab> {
  bool _completed = false;
  TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _loadRitualStatus();
  }

  @override
  void didUpdateWidget(RitualTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth ||
        oldWidget.type != widget.type) {
      _loadRitualStatus();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadRitualStatus() {
    final ritualModel = Provider.of<RitualModel>(context, listen: false);
    final status = ritualModel.getRitualStatus(
      widget.type,
      widget.selectedMonth,
    );

    setState(() {
      _completed = status?.completed ?? false;
      _notesController.text = status?.notes ?? '';
    });
  }

  void _saveRitualStatus() {
    final ritualModel = Provider.of<RitualModel>(context, listen: false);

    ritualModel.setRitualStatus(
      type: widget.type,
      date: widget.selectedMonth,
      completed: _completed,
      notes: _notesController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.type.name} status saved for ${DateFormat('MMMM yyyy').format(widget.selectedMonth)}',
        ),
        backgroundColor: widget.color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ritual Info Card
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
                      widget.type.name,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: widget.color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.type.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Divider(color: widget.color.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 16),

                    // Selected Month Status
                    Text(
                      'Status for ${DateFormat('MMMM yyyy').format(widget.selectedMonth)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Yes/No Question
                    Text(
                      'Did you complete ${widget.type.name} this month?',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Yes/No Toggle
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _completed = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _completed
                                        ? widget.color
                                        : widget.color.withOpacity(0.1),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _completed
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _completed = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    !_completed
                                        ? widget.color
                                        : widget.color.withOpacity(0.1),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'No',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      !_completed
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Card
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
                      'Notes',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    // Notes Text Field
                    TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            'Add any notes about your ritual practice here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.color.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: widget.color, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Year Overview Card
            Consumer<RitualModel>(
              builder: (context, ritualModel, _) {
                final currentYear = widget.selectedMonth.year;
                final yearlyStatus = ritualModel.getYearlyStatus(currentYear);
                final monthsCompleted =
                    yearlyStatus[widget.type]!
                        .where((completed) => completed)
                        .length;

                return Card(
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
                          '$currentYear Overview',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),

                        // Yearly progress
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Months Completed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$monthsCompleted / 12',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Completion Rate',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(monthsCompleted / 12 * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: widget.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Month indicators
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            final monthName = DateFormat(
                              'MMM',
                            ).format(DateTime(currentYear, index + 1));
                            final isCompleted =
                                yearlyStatus[widget.type]![index];

                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    isCompleted
                                        ? widget.color
                                        : widget.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                monthName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCompleted
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRitualStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
