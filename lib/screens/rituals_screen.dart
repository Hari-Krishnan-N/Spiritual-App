import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/ritual_model.dart';
import '../widgets/ritual_tab.dart';

class RitualsScreen extends StatefulWidget {
  final int initialTabIndex;

  const RitualsScreen({super.key, this.initialTabIndex = 0});

  @override
  _RitualsScreenState createState() => _RitualsScreenState();
}

class _RitualsScreenState extends State<RitualsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _selectedMonth = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _getTabColor(_tabController.index),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Color _getTabColor(int index) {
    switch (index) {
      case 0:
        return AppTheme.tarapanmTeal;
      case 1:
        return AppTheme.homamOrange;
      case 2:
        return AppTheme.danamGreen;
      default:
        return AppTheme.primaryRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Rituals'),
        backgroundColor: _getTabColor(_tabController.index),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          onTap: (index) {
            setState(() {});
          },
          tabs: const [
            Tab(text: 'Tharpanam', icon: Icon(Icons.water_drop_outlined)),
            Tab(
              text: 'Homam',
              icon: Icon(Icons.local_fire_department_outlined),
            ),
            Tab(text: 'Dhanam', icon: Icon(Icons.spa_outlined)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => _selectMonth(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _getTabColor(_tabController.index).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: _getTabColor(_tabController.index),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_rounded,
                      color: _getTabColor(_tabController.index),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tarapanm Tab
                RitualTab(
                  type: RitualType.tarapanm,
                  selectedMonth: _selectedMonth,
                  color: AppTheme.tarapanmTeal,
                ),

                // Homam Tab
                RitualTab(
                  type: RitualType.homam,
                  selectedMonth: _selectedMonth,
                  color: AppTheme.homamOrange,
                ),

                // Danam Tab
                RitualTab(
                  type: RitualType.danam,
                  selectedMonth: _selectedMonth,
                  color: AppTheme.danamGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
