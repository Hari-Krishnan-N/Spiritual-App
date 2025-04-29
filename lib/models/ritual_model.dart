import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

enum RitualType { tarapanm, homam, danam }

extension RitualTypeExtension on RitualType {
  String get name {
    switch (this) {
      case RitualType.tarapanm:
        return 'Tarapanm';
      case RitualType.homam:
        return 'Homam';
      case RitualType.danam:
        return 'Danam';
    }
  }

  String get description {
    switch (this) {
      case RitualType.tarapanm:
        return 'Monthly ritual tracking';
      case RitualType.homam:
        return 'Fire ritual status';
      case RitualType.danam:
        return 'Meditation tracker';
    }
  }

  Color get color {
    switch (this) {
      case RitualType.tarapanm:
        return const Color(0xFF26A69A); // Teal
      case RitualType.homam:
        return const Color(0xFFFF9800); // Orange
      case RitualType.danam:
        return const Color(0xFF8BC34A); // Green
    }
  }

  IconData get icon {
    switch (this) {
      case RitualType.tarapanm:
        return Icons.water_drop_outlined;
      case RitualType.homam:
        return Icons.local_fire_department_outlined;
      case RitualType.danam:
        return Icons.spa_outlined;
    }
  }
}

class RitualEntry {
  final RitualType type;
  final DateTime date;
  final bool completed;
  final String notes;

  RitualEntry({
    required this.type,
    required this.date,
    required this.completed,
    this.notes = '',
  });

  String get formattedMonth => DateFormat('MMMM yyyy').format(date);

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'completed': completed,
      'notes': notes,
    };
  }

  factory RitualEntry.fromJson(Map<String, dynamic> json) {
    return RitualEntry(
      type: RitualType.values[json['type']],
      date: DateFormat('yyyy-MM-dd').parse(json['date']),
      completed: json['completed'],
      notes: json['notes'] ?? '',
    );
  }
}

class RitualModel extends ChangeNotifier {
  List<RitualEntry> _entries = [];

  List<RitualEntry> get entries => _entries;

  RitualModel() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final entriesJson = prefs.getStringList('ritual_entries') ?? [];
    _entries =
        entriesJson
            .map((json) => RitualEntry.fromJson(jsonDecode(json)))
            .toList();

    // Sort entries by date (newest first)
    _entries.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final entriesJson =
        _entries.map((entry) => jsonEncode(entry.toJson())).toList();

    await prefs.setStringList('ritual_entries', entriesJson);

    notifyListeners();
  }

  // Add or update ritual entry
  Future<void> setRitualStatus({
    required RitualType type,
    required DateTime date,
    required bool completed,
    String notes = '',
  }) async {
    // Find entry for this ritual and month
    final yearMonth = DateTime(date.year, date.month);

    final existingIndex = _entries.indexWhere(
      (entry) =>
          entry.type == type &&
          entry.date.year == yearMonth.year &&
          entry.date.month == yearMonth.month,
    );

    if (existingIndex >= 0) {
      // Update existing entry
      _entries[existingIndex] = RitualEntry(
        type: type,
        date: yearMonth,
        completed: completed,
        notes: notes,
      );
    } else {
      // Add new entry
      _entries.add(
        RitualEntry(
          type: type,
          date: yearMonth,
          completed: completed,
          notes: notes,
        ),
      );
    }

    // Sort entries by date (newest first)
    _entries.sort((a, b) => b.date.compareTo(a.date));

    await _saveData();
  }

  // Get ritual status for specific month
  RitualEntry? getRitualStatus(RitualType type, DateTime date) {
    final yearMonth = DateTime(date.year, date.month);

    try {
      return _entries.firstWhere(
        (entry) =>
            entry.type == type &&
            entry.date.year == yearMonth.year &&
            entry.date.month == yearMonth.month,
      );
    } catch (e) {
      return null;
    }
  }

  // Get completed ritual count for a specific type in the given year
  int getCompletedCount(RitualType type, int year) {
    return _entries
        .where(
          (entry) =>
              entry.type == type && entry.date.year == year && entry.completed,
        )
        .length;
  }

  // Get list of entries for a specific ritual type
  List<RitualEntry> getEntriesForType(RitualType type) {
    return _entries.where((entry) => entry.type == type).toList();
  }

  // Get all ritual entries for a specific month
  List<RitualEntry> getEntriesForMonth(int year, int month) {
    return _entries
        .where((entry) => entry.date.year == year && entry.date.month == month)
        .toList();
  }

  // Get yearly status for all ritual types
  Map<RitualType, List<bool>> getYearlyStatus(int year) {
    final Map<RitualType, List<bool>> result = {
      RitualType.tarapanm: List.filled(12, false),
      RitualType.homam: List.filled(12, false),
      RitualType.danam: List.filled(12, false),
    };

    for (final entry in _entries) {
      if (entry.date.year == year && entry.completed) {
        result[entry.type]![entry.date.month - 1] = true;
      }
    }

    return result;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ritual_entries');
    _entries = [];

    notifyListeners();
  }
}
