import 'package:gsheets/gsheets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Models
import '../models/user_model.dart';
import '../models/japam_model.dart';
import '../models/ritual_model.dart';

class SheetsService {
  // Singleton instance
  static final SheetsService _instance = SheetsService._internal();
  factory SheetsService() => _instance;
  SheetsService._internal();

  // GSheets instance
  late GSheets _gsheets;
  Spreadsheet? _spreadsheet;

  // Worksheet references
  Worksheet? _userSheet;
  Worksheet? _japamSheet;
  Worksheet? _ritualSheet;

  // Initialization status
  bool _isInitialized = false;

  // Initialize the GSheets instance and connect to the spreadsheet
  Future<bool> initialize(String credentials, String spreadsheetId) async {
    if (_isInitialized) return true;

    try {
      _gsheets = GSheets(credentials);
      _spreadsheet = await _gsheets.spreadsheet(spreadsheetId);

      // Get or create worksheets
      _userSheet = await _getWorksheet('Users');
      _japamSheet = await _getWorksheet('Japam');
      _ritualSheet = await _getWorksheet('Rituals');

      // Set headers if sheets are newly created
      await _setupHeaders();

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing sheets service: $e');
      return false;
    }
  }

  // Get or create a worksheet
  Future<Worksheet?> _getWorksheet(String title) async {
    if (_spreadsheet == null) return null;

    var worksheet = _spreadsheet!.worksheetByTitle(title);
    worksheet ??= await _spreadsheet!.addWorksheet(title);

    return worksheet;
  }

  // Set up headers for all worksheets
  Future<void> _setupHeaders() async {
    // User sheet headers
    if (_userSheet != null) {
      final firstRow = await _userSheet!.values.row(1);
      if (firstRow.isEmpty || firstRow.length < 5) {
        await _userSheet!.values.insertRow(1, [
          'ID',
          'Name',
          'Email',
          'Phone',
          'Last Updated',
        ]);
      }
    }

    // Japam sheet headers
    if (_japamSheet != null) {
      final firstRow = await _japamSheet!.values.row(1);
      if (firstRow.isEmpty || firstRow.length < 6) {
        await _japamSheet!.values.insertRow(1, [
          'User Email',
          'Date',
          'Standard Count',
          'Extra Count',
          'Total Count',
          'Last Updated',
        ]);
      }
    }

    // Ritual sheet headers
    if (_ritualSheet != null) {
      final firstRow = await _ritualSheet!.values.row(1);
      if (firstRow.isEmpty || firstRow.length < 6) {
        await _ritualSheet!.values.insertRow(1, [
          'User Email',
          'Ritual Type',
          'Date',
          'Completed',
          'Notes',
          'Last Updated',
        ]);
      }
    }
  }

  // Save or update user data
  Future<bool> saveUserData(UserModel user) async {
    if (!_isInitialized || _userSheet == null) return false;

    try {
      // Look for existing user by email
      final userRows = await _userSheet!.values.allRows();
      int? existingRowIndex;

      for (int i = 1; i < userRows.length; i++) {
        if (userRows[i].length > 2 && userRows[i][2] == user.email) {
          existingRowIndex = i + 1; // +1 because sheet rows are 1-indexed
          break;
        }
      }

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      if (existingRowIndex != null) {
        // Update existing user
        await _userSheet!.values.insertRow(existingRowIndex, [
          existingRowIndex - 1, // ID (row number - 1)
          user.name,
          user.email,
          user.phoneNumber,
          now,
        ]);
      } else {
        // Add new user
        final newId = userRows.length;
        await _userSheet!.values.appendRow([
          newId,
          user.name,
          user.email,
          user.phoneNumber,
          now,
        ]);
      }

      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // Save japam entries
  Future<bool> saveJapamEntries(
    String userEmail,
    List<JapamEntry> entries,
  ) async {
    if (!_isInitialized || _japamSheet == null) return false;

    try {
      // Get last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      final lastSync =
          prefs.getString('last_japam_sync') ?? '2000-01-01 00:00:00';
      final lastSyncDate = DateTime.parse(lastSync);

      // Filter entries that need to be synced (newer than last sync)
      final entriesToSync =
          entries
              .where(
                (entry) =>
                    entry.date.isAfter(lastSyncDate) ||
                    entry.date.isAtSameMomentAs(lastSyncDate),
              )
              .toList();

      if (entriesToSync.isEmpty) return true; // Nothing to sync

      // Get all existing rows
      final allRows = await _japamSheet!.values.allRows();

      // Create a set of dates to delete
      final Set<String> datesToUpdate =
          entriesToSync.map((e) => e.formattedDate).toSet();

      // Delete existing entries for this user with the same dates
      for (int i = allRows.length - 1; i >= 1; i--) {
        if (allRows[i].length > 1 &&
            allRows[i][0] == userEmail &&
            datesToUpdate.contains(allRows[i][1])) {
          await _japamSheet!.deleteRow(i + 1);
        }
      }

      // Add new entries
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      for (final entry in entriesToSync) {
        await _japamSheet!.values.appendRow([
          userEmail,
          entry.formattedDate,
          entry.standardCount.toString(),
          entry.extraCount.toString(),
          entry.totalCount.toString(),
          now,
        ]);
      }

      // Update last sync time
      await prefs.setString('last_japam_sync', now);

      return true;
    } catch (e) {
      print('Error saving japam entries: $e');
      return false;
    }
  }

  // Save ritual entries
  Future<bool> saveRitualEntries(
    String userEmail,
    List<RitualEntry> entries,
  ) async {
    if (!_isInitialized || _ritualSheet == null) return false;

    try {
      // Get last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      final lastSync =
          prefs.getString('last_ritual_sync') ?? '2000-01-01 00:00:00';
      final lastSyncDate = DateTime.parse(lastSync);

      // Filter entries that need to be synced (newer than last sync)
      final entriesToSync =
          entries
              .where(
                (entry) =>
                    entry.date.isAfter(lastSyncDate) ||
                    entry.date.isAtSameMomentAs(lastSyncDate),
              )
              .toList();

      if (entriesToSync.isEmpty) return true; // Nothing to sync

      // Get all existing rows
      final allRows = await _ritualSheet!.values.allRows();

      // Create a map of ritual types and months to update
      final Map<String, Set<String>> toUpdate = {};

      for (final entry in entriesToSync) {
        final key = entry.type.index.toString();
        final month = DateFormat('yyyy-MM').format(entry.date);

        if (!toUpdate.containsKey(key)) {
          toUpdate[key] = {};
        }

        toUpdate[key]!.add(month);
      }

      // Delete existing entries for this user with the same ritual and month
      for (int i = allRows.length - 1; i >= 1; i--) {
        if (allRows[i].length > 2 && allRows[i][0] == userEmail) {
          final ritualType = allRows[i][1];
          final date = DateFormat('yyyy-MM-dd').parse(allRows[i][2]);
          final month = DateFormat('yyyy-MM').format(date);

          if (toUpdate.containsKey(ritualType) &&
              toUpdate[ritualType]!.contains(month)) {
            await _ritualSheet!.deleteRow(i + 1);
          }
        }
      }

      // Add new entries
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      for (final entry in entriesToSync) {
        await _ritualSheet!.values.appendRow([
          userEmail,
          entry.type.index.toString(),
          DateFormat('yyyy-MM-dd').format(entry.date),
          entry.completed ? 'true' : 'false',
          entry.notes,
          now,
        ]);
      }

      // Update last sync time
      await prefs.setString('last_ritual_sync', now);

      return true;
    } catch (e) {
      print('Error saving ritual entries: $e');
      return false;
    }
  }

  // Sync all data
  Future<bool> syncAllData(
    UserModel user,
    List<JapamEntry> japamEntries,
    List<RitualEntry> ritualEntries,
  ) async {
    if (!_isInitialized) return false;

    try {
      // Save user data
      final userSuccess = await saveUserData(user);

      // Save japam entries
      final japamSuccess = await saveJapamEntries(user.email, japamEntries);

      // Save ritual entries
      final ritualSuccess = await saveRitualEntries(user.email, ritualEntries);

      return userSuccess && japamSuccess && ritualSuccess;
    } catch (e) {
      print('Error syncing all data: $e');
      return false;
    }
  }
}
