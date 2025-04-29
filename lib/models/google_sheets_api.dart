import 'package:gsheets/gsheets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'user_model.dart';
import 'japam_model.dart';
import 'ritual_model.dart';

class GoogleSheetsApi {
  // You would replace these with your actual credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "rhts-458310",
  "private_key_id": "038c8cbbdbe1baffac24c23b9cc5ad0ddea2d9fa",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCq2MToV07nNHsU\n+2sWEmRuBXJDaOlayMRKLo21yREphHj4YFLvxkWkLTvInq+/N7nUOInvliSCbbP5\nZgKTae9RzBDfJNdROsefx0+Vtk8hX9mER3SZhOozawRwSk4MUgo3KdCiLu0b5EV0\nUPIjU4yzux7KMYoEWPm9oPjz7a4EytGV+LhWmU6cXtO4mu3Q6XZWl/iafom8ucQi\nGb3sLYDgNVRCXWjt4omCOdgTkdxzgy3XrFdCUClqk64pZUJ6EL2HK2cSukdRjq26\nnL+FJPslur2OqPXVMlzSKHkpxs7UVLHc1j5kcAaJvGUVtcaqBrWcnWI16QUB3q9A\nHTcf4wc7AgMBAAECggEAHt7gZaMxDLH884Oii/By2TZ+uROB5veUEFttG8XjJf9b\n5HVzRwQqnUnXHZ8e3oxxNZmpwvL8Ud0EwjHekUh5B+y5t7hud60JWSOoi8LPdZZe\nNXq75OmRcA0MVkX26F8CnYkeu8+C5KFQs33U4vE74VYUcDCXYcW6CrvFgD4YTaEU\nIuII9/ikQMsgN+4nto6EQuBBONJxfEpoX6+JYfSDw/xWGZIaZtJf9fjQA7bR/Q67\nXhfS5UD05TDF3deHk3+Xf2S1URv21W6KzlJcOSCyNXrGj6V2VAcJzMcWL1+Jp2D8\n3j6VZcjHEHquJm5CRgbCj8IyfhDo91vY4up7zLl50QKBgQDtU08IvrKIMN073RkX\nzfScRlSsebgYV3xQV4wuppdp7nBIdSxSG6e4kop4xQCOS2//hbGPivrFi4J/MVU/\nnchU5fUH/UDRpdjrXUx+N5GTAnvNvyCcI0YGYYw28q5LLrTvgLngD2AXL/cCArvv\nEGDwxQhxIdEPTEJx/DyZSJ27HQKBgQC4Sk/YRztL5skKUsl8Uyd2ok1/unx1qPMo\nmhZg2O/EWlrxeQzbp4oB6kOKyna4vFvO4XQ1YecMfQPjHq9vRiR1Rs00zZawOarF\nrMyXAfrBSVC/xDRM3W6njfLL00UcjXwKfnO2e37GCH41APsfwTq0OnIssfX/TU7B\nVZ4lv6LkNwKBgGRD1hgzuOmg+1bXSkqsULPVYuCbbBOcooCu/CKZb07p1bZHCrqF\nxI5OGwJ6+IklhePGcAXdCaV8E135UbLWzlRP8v21GTV5g/OsLy0D/RTG79c08GoG\n3QbFH5/3V3ub+AVXtS/cTxR8xzaqQQv3N32BQNfLGbAE3+2YS2HXNAxhAoGAMGoN\nWdM0x7bkf9rJ5ehuiKMQ2wph4gM1higc0uqK6rmWBLP5Zcc44VHq1o5j7BpHwCzI\ne7Gxoj1BhSwtiH0T3N9xz3pnKPqtW2sPAGjbuGWLWiWwW7UcedY3v8ZL9LlSqesY\neQsufdYDWeddEbWQt4JXNli2OJDVrMLSXjZfE7cCgYA3Rl/oViijHQfCkaM2vhKQ\nk0/Yoh5/ga2VWT9ekQJ8l11ON5EiwI4mTX2Vg6yoLLKLNv3u1266Oso+Dxju/kWI\n4/rEjNw5XVbIbA2hsDC2Ri99EsKQItBX5ot22vXpWRSwrjaCln/i62bYL7Xh5kFA\n1DoXMmQfwfjFqShhqRq3zw==\n-----END PRIVATE KEY-----\n",
  "client_email": "hari-7@rhts-458310.iam.gserviceaccount.com",
  "client_id": "116729338189840043485",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/hari-7%40rhts-458310.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

  // Your spreadsheet ID
  static const _spreadsheetId = '1JDrdPfo1FWPc6D32-ijwWGoE-KB6kbjrM88LkAQDIk4';

  // Initialize GSheets
  static final _gsheets = GSheets(_credentials);
  static Spreadsheet? _spreadsheet;
  static Worksheet? _userSheet;
  static Worksheet? _japamSheet;
  static Worksheet? _ritualSheet;

  // Initialize the sheets
  static Future<bool> init() async {
    try {
      _spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);

      // Get or create worksheets
      _userSheet = await _getOrCreateWorksheet(_spreadsheet!, 'Users');
      _japamSheet = await _getOrCreateWorksheet(_spreadsheet!, 'Japam');
      _ritualSheet = await _getOrCreateWorksheet(_spreadsheet!, 'Rituals');

      // Set up headers for each sheet
      await _setUpUserSheet(_userSheet!);
      await _setUpJapamSheet(_japamSheet!);
      await _setUpRitualSheet(_ritualSheet!);

      return true;
    } catch (e) {
      print('Error initializing Google Sheets: $e');
      return false;
    }
  }

  // Get or create worksheet
  static Future<Worksheet> _getOrCreateWorksheet(
    Spreadsheet spreadsheet,
    String title,
  ) async {
    var worksheet = spreadsheet.worksheetByTitle(title);
    worksheet ??= await spreadsheet.addWorksheet(title);
    return worksheet;
  }

  // Set up the user sheet with headers
  static Future<void> _setUpUserSheet(Worksheet sheet) async {
    await sheet.values.insertRow(1, [
      'ID',
      'Name',
      'Email',
      'Phone',
      'Last Updated',
    ]);
  }

  // Set up the japam sheet with headers
  static Future<void> _setUpJapamSheet(Worksheet sheet) async {
    await sheet.values.insertRow(1, [
      'User Email',
      'Date',
      'Standard Count',
      'Extra Count',
      'Total Count',
      'Last Updated',
    ]);
  }

  // Set up the ritual sheet with headers
  static Future<void> _setUpRitualSheet(Worksheet sheet) async {
    await sheet.values.insertRow(1, [
      'User Email',
      'Ritual Type',
      'Date',
      'Completed',
      'Notes',
      'Last Updated',
    ]);
  }

  // Save user data to Google Sheets
  static Future<bool> saveUserData(UserModel user) async {
    if (_userSheet == null) {
      if (!await init()) {
        return false;
      }
    }

    try {
      // Check if user already exists
      final email = user.email;
      final userRow = await _userSheet!.values.allRows();

      int? existingRowIndex;
      for (int i = 1; i < userRow.length; i++) {
        if (userRow[i].length > 2 && userRow[i][2] == email) {
          existingRowIndex = i + 1; // +1 because row index starts at 1
          break;
        }
      }

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      if (existingRowIndex != null) {
        // Update existing user
        await _userSheet!.values.insertRow(existingRowIndex, [
          existingRowIndex - 1, // Preserve ID
          user.name,
          user.email,
          user.phoneNumber,
          now,
        ]);
      } else {
        // Add new user
        final lastRow = userRow.length;
        await _userSheet!.values.appendRow([
          lastRow, // New ID
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

  // Sync japam data with Google Sheets
  static Future<bool> syncJapamData(
    String userEmail,
    List<JapamEntry> entries,
  ) async {
    if (_japamSheet == null) {
      if (!await init()) {
        return false;
      }
    }

    try {
      // Get last sync time
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString('last_japam_sync') ?? '2000-01-01';
      final lastSyncDate = DateTime.parse(lastSync);

      // Filter entries that are new or updated since last sync
      final entriesToSync =
          entries
              .where(
                (entry) =>
                    entry.date.isAfter(lastSyncDate) ||
                    entry.date.isAtSameMomentAs(lastSyncDate),
              )
              .toList();

      if (entriesToSync.isEmpty) {
        return true; // Nothing to sync
      }

      // Delete existing entries for these dates
      final allRows = await _japamSheet!.values.allRows();
      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i].length > 1 && allRows[i][0] == userEmail) {
          final entryDate = allRows[i][1];

          if (entriesToSync.any((e) => e.formattedDate == entryDate)) {
            await _japamSheet!.deleteRow(
              i + 1,
            ); // +1 because row index starts at 1
          }
        }
      }

      // Add new entries
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      for (final entry in entriesToSync) {
        await _japamSheet!.values.appendRow([
          userEmail,
          entry.formattedDate,
          entry.standardCount,
          entry.extraCount,
          entry.totalCount,
          now,
        ]);
      }

      // Update last sync time
      await prefs.setString(
        'last_japam_sync',
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      return true;
    } catch (e) {
      print('Error syncing japam data: $e');
      return false;
    }
  }

  // Sync ritual data with Google Sheets
  static Future<bool> syncRitualData(
    String userEmail,
    List<RitualEntry> entries,
  ) async {
    if (_ritualSheet == null) {
      if (!await init()) {
        return false;
      }
    }

    try {
      // Get last sync time
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getString('last_ritual_sync') ?? '2000-01-01';
      final lastSyncDate = DateTime.parse(lastSync);

      // Filter entries that are new or updated since last sync
      final entriesToSync =
          entries
              .where(
                (entry) =>
                    entry.date.isAfter(lastSyncDate) ||
                    entry.date.isAtSameMomentAs(lastSyncDate),
              )
              .toList();

      if (entriesToSync.isEmpty) {
        return true; // Nothing to sync
      }

      // Delete existing entries for these months
      final allRows = await _ritualSheet!.values.allRows();
      for (int i = 1; i < allRows.length; i++) {
        if (allRows[i].length > 2 && allRows[i][0] == userEmail) {
          final ritualType = int.parse(allRows[i][1]);
          final entryDate = DateFormat('yyyy-MM-dd').parse(allRows[i][2]);

          if (entriesToSync.any(
            (e) =>
                e.type.index == ritualType &&
                e.date.year == entryDate.year &&
                e.date.month == entryDate.month,
          )) {
            await _ritualSheet!.deleteRow(
              i + 1,
            ); // +1 because row index starts at 1
          }
        }
      }

      // Add new entries
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      for (final entry in entriesToSync) {
        await _ritualSheet!.values.appendRow([
          userEmail,
          entry.type.index,
          DateFormat('yyyy-MM-dd').format(entry.date),
          entry.completed ? 'true' : 'false',
          entry.notes,
          now,
        ]);
      }

      // Update last sync time
      await prefs.setString(
        'last_ritual_sync',
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      return true;
    } catch (e) {
      print('Error syncing ritual data: $e');
      return false;
    }
  }

  // Perform a full sync of all data
  static Future<bool> syncAllData(
    UserModel user,
    List<JapamEntry> japamEntries,
    List<RitualEntry> ritualEntries,
  ) async {
    bool success = true;

    if (!await saveUserData(user)) {
      success = false;
    }

    if (!await syncJapamData(user.email, japamEntries)) {
      success = false;
    }

    if (!await syncRitualData(user.email, ritualEntries)) {
      success = false;
    }

    return success;
  }
}
