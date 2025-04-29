import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _phoneNumber = '';
  String _profileImagePath = '';

  String get name => _name;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get profileImagePath => _profileImagePath;

  bool get isLoggedIn => _email.isNotEmpty;

  UserModel() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    _name = prefs.getString('user_name') ?? '';
    _email = prefs.getString('user_email') ?? '';
    _phoneNumber = prefs.getString('user_phone') ?? '';
    _profileImagePath = prefs.getString('user_profile_image') ?? '';

    notifyListeners();
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    String phoneNumber = '',
    String profileImagePath = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _name = name;
    _email = email;

    if (phoneNumber.isNotEmpty) {
      _phoneNumber = phoneNumber;
    }

    if (profileImagePath.isNotEmpty) {
      _profileImagePath = profileImagePath;
    }

    await prefs.setString('user_name', _name);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_phone', _phoneNumber);
    await prefs.setString('user_profile_image', _profileImagePath);

    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();

    _profileImagePath = path;
    await prefs.setString('user_profile_image', _profileImagePath);

    notifyListeners();
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();

    _phoneNumber = phoneNumber;
    await prefs.setString('user_phone', _phoneNumber);

    notifyListeners();
  }

  Future<void> updatePassword() async {
    // Password update will be handled via Google auth or secure storage
    // This is a placeholder
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear only authentication data but keep preferences
    await prefs.remove('user_email');
    _email = '';

    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {'name': _name, 'email': _email, 'phoneNumber': _phoneNumber};
  }
}
