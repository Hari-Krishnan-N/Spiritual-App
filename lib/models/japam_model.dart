import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class JapamEntry {
  final DateTime date;
  final int standardCount;
  final int extraCount;

  JapamEntry({
    required this.date,
    required this.standardCount,
    required this.extraCount,
  });

  int get totalCount => standardCount + extraCount;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  Map<String, dynamic> toJson() {
    return {
      'date': formattedDate,
      'standardCount': standardCount,
      'extraCount': extraCount,
      'totalCount': totalCount,
    };
  }

  factory JapamEntry.fromJson(Map<String, dynamic> json) {
    return JapamEntry(
      date: DateFormat('yyyy-MM-dd').parse(json['date']),
      standardCount: json['standardCount'],
      extraCount: json['extraCount'],
    );
  }
}

class JapamModel extends ChangeNotifier {
  List<JapamEntry> _entries = [];
  int _defaultJapamCount = 112; // Default count is 112

  List<JapamEntry> get entries => _entries;
  int get defaultJapamCount => _defaultJapamCount;

  // Get total count for the current month
  int get currentMonthTotal {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    return _entries
        .where(
          (entry) =>
              entry.date.isAfter(
                currentMonth.subtract(const Duration(days: 1)),
              ) &&
              entry.date.isBefore(nextMonth),
        )
        .fold(0, (sum, entry) => sum + entry.totalCount);
  }

  // Get total all-time count
  int get totalJapamCount {
    return _entries.fold(0, (sum, entry) => sum + entry.totalCount);
  }

  JapamModel() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load default japam count
    _defaultJapamCount = prefs.getInt('default_japam_count') ?? 112;

    // Load entries
    final entriesJson = prefs.getStringList('japam_entries') ?? [];
    _entries =
        entriesJson
            .map((json) => JapamEntry.fromJson(jsonDecode(json)))
            .toList();

    // Sort entries by date (newest first)
    _entries.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save default japam count
    await prefs.setInt('default_japam_count', _defaultJapamCount);

    // Save entries
    final entriesJson =
        _entries.map((entry) => jsonEncode(entry.toJson())).toList();

    await prefs.setStringList('japam_entries', entriesJson);

    notifyListeners();
  }

  Future<void> setDefaultJapamCount(int count) async {
    if (count > 0) {
      _defaultJapamCount = count;
      await _saveData();
    }
  }

  // Add a new japam entry
  Future<void> addEntry({
    DateTime? date,
    int? standardCount,
    int extraCount = 0,
  }) async {
    final entryDate = date ?? DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(entryDate);

    // Check if entry for this date already exists
    final existingIndex = _entries.indexWhere(
      (entry) => DateFormat('yyyy-MM-dd').format(entry.date) == formattedDate,
    );

    if (existingIndex >= 0) {
      // Update existing entry
      _entries[existingIndex] = JapamEntry(
        date: entryDate,
        standardCount: standardCount ?? _defaultJapamCount,
        extraCount: extraCount,
      );
    } else {
      // Add new entry
      _entries.add(
        JapamEntry(
          date: entryDate,
          standardCount: standardCount ?? _defaultJapamCount,
          extraCount: extraCount,
        ),
      );
    }

    // Sort entries by date (newest first)
    _entries.sort((a, b) => b.date.compareTo(a.date));

    await _saveData();
  }

  // Update an existing entry
  Future<void> updateEntry({
    required DateTime date,
    int? standardCount,
    int? extraCount,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final existingIndex = _entries.indexWhere(
      (entry) => DateFormat('yyyy-MM-dd').format(entry.date) == formattedDate,
    );

    if (existingIndex >= 0) {
      final existing = _entries[existingIndex];

      _entries[existingIndex] = JapamEntry(
        date: date,
        standardCount: standardCount ?? existing.standardCount,
        extraCount: extraCount ?? existing.extraCount,
      );

      await _saveData();
    }
  }

  // Delete an entry
  Future<void> deleteEntry(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    _entries.removeWhere(
      (entry) => DateFormat('yyyy-MM-dd').format(entry.date) == formattedDate,
    );

    await _saveData();
  }

  // Get entry for a specific date
  JapamEntry? getEntryForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      return _entries.firstWhere(
        (entry) => DateFormat('yyyy-MM-dd').format(entry.date) == formattedDate,
      );
    } catch (e) {
      return null;
    }
  }

  // Get heatmap data
  Map<DateTime, int> getHeatmapData({DateTime? startDate, DateTime? endDate}) {
    final Map<DateTime, int> heatmapData = {};

    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 365));
    final end = endDate ?? DateTime.now();

    for (final entry in _entries) {
      if (entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)))) {
        // Store just the date part without time
        final dateKey = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        heatmapData[dateKey] = entry.totalCount;
      }
    }

    return heatmapData;
  }

  // Get entries for a specific month
  List<JapamEntry> getEntriesForMonth(int year, int month) {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    return _entries
        .where(
          (entry) =>
              entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              entry.date.isBefore(endDate),
        )
        .toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('japam_entries');
    _entries = [];

    notifyListeners();
  }
}
