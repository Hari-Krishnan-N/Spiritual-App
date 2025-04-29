import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';

class CustomHeatMapCalendar extends StatefulWidget {
  final Map<DateTime, int> datasets;
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelect;
  final Color primaryColor;
  final DateTime? startDate;
  final DateTime? endDate;

  const CustomHeatMapCalendar({
    super.key,
    required this.datasets,
    this.selectedDate,
    this.onDateSelect,
    this.primaryColor = AppTheme.japamPurple,
    this.startDate,
    this.endDate,
  });

  @override
  State<CustomHeatMapCalendar> createState() => _CustomHeatMapCalendarState();
}

class _CustomHeatMapCalendarState extends State<CustomHeatMapCalendar> {
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentStartDate = widget.startDate ?? DateTime(now.year, now.month - 3);
    _currentEndDate = widget.endDate ?? DateTime(now.year, now.month + 3);
  }

  void _previousMonth() {
    setState(() {
      _currentStartDate = DateTime(
        _currentStartDate.year,
        _currentStartDate.month - 1,
      );
      _currentEndDate = DateTime(
        _currentEndDate.year,
        _currentEndDate.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _currentStartDate = DateTime(
        _currentStartDate.year,
        _currentStartDate.month + 1,
      );
      _currentEndDate = DateTime(
        _currentEndDate.year,
        _currentEndDate.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: widget.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Japam Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: widget.primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  tooltip: 'Previous Month',
                ),
                Text(
                  DateFormat('MMM yyyy').format(_currentStartDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  tooltip: 'Next Month',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Heatmap calendar
        HeatMap(
          datasets: widget.datasets,
          colorMode: ColorMode.color,
          colorsets: {
            1: widget.primaryColor.withOpacity(0.2),
            112: widget.primaryColor.withOpacity(0.4),
            224: widget.primaryColor.withOpacity(0.7),
            336: widget.primaryColor,
          },
          defaultColor: Colors.white,
          textColor: Colors.black,
          showColorTip: false,
          onClick: widget.onDateSelect,
          margin: const EdgeInsets.all(2),
          borderRadius: 8,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),

        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('None', Colors.white),
            const SizedBox(width: 16),
            _buildLegendItem('1 Set', widget.primaryColor.withOpacity(0.2)),
            const SizedBox(width: 16),
            _buildLegendItem('2 Sets', widget.primaryColor.withOpacity(0.5)),
            const SizedBox(width: 16),
            _buildLegendItem('3+ Sets', widget.primaryColor),
          ],
        ),
      ],
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
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
