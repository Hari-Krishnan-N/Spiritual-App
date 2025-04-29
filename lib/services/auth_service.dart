import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Service to handle authentication
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // User data
  late UserModel _userModel;

  // Initialization status
  bool _isInitialized = false;

  /// Initialize the auth service
  Future<void> initialize(UserModel userModel) async {
    if (_isInitialized) return;

    _userModel = userModel;

    // Check if there's a cached user session
    await _trySilentSignIn();

    _isInitialized = true;
  }

  /// Try to sign in silently if there's a cached session
  Future<bool> _trySilentSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account != null) {
        await _updateUserFromGoogleAccount(account);
        return true;
      }

      return false;
    } catch (e) {
      print('Error during silent sign in: $e');
      return false;
    }
  }

  /// Update user model from Google account data
  Future<void> _updateUserFromGoogleAccount(GoogleSignInAccount account) async {
    await _userModel.saveUserData(
      name: account.displayName ?? '',
      email: account.email,
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        await _updateUserFromGoogleAccount(account);
        return true;
      }

      return false;
    } catch (e) {
      print('Error during Google sign in: $e');
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _userModel.logout();

      return true;
    } catch (e) {
      print('Error during sign out: $e');
      return false;
    }
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _userModel.isLoggedIn;
  }

  /// Get current user
  UserModel get currentUser => _userModel;
}
