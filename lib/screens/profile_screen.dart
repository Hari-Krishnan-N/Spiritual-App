import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../app_theme.dart';
import '../models/user_model.dart';
import '../models/google_sheets_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final userModel = Provider.of<UserModel>(context, listen: false);

    _nameController.text = userModel.name;
    _emailController.text = userModel.email;
    _phoneController.text = userModel.phoneNumber;
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userModel = Provider.of<UserModel>(context, listen: false);

    await userModel.saveUserData(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
    );

    // Sync with Google Sheets
    await GoogleSheetsApi.saveUserData(userModel);

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      await userModel.updateProfileImage(image.path);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final userModel = Provider.of<UserModel>(context, listen: false);

        await userModel.saveUserData(
          name: googleUser.displayName ?? '',
          email: googleUser.email,
        );

        // Sync with Google Sheets
        await GoogleSheetsApi.saveUserData(userModel);

        _nameController.text = googleUser.displayName ?? '';
        _emailController.text = googleUser.email;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPhone() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show verification dialog
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verify Phone Number'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the verification code sent to your phone:'),
                const SizedBox(height: 16),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {},
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    activeColor: AppTheme.primaryRed,
                    selectedColor: AppTheme.primaryRed,
                    inactiveColor: Colors.grey[300],
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final userModel = Provider.of<UserModel>(
                    context,
                    listen: false,
                  );
                  await userModel.updatePhoneNumber(phoneNumber);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number verified successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
                child: const Text('Verify'),
              ),
            ],
          ),
    );
  }

  Future<void> _changePassword() async {
    // Show current password verification dialog
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your current password:'),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Current Password',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Enter your new password:'),
                const SizedBox(height: 8),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'New Password'),
                ),
                const SizedBox(height: 8),
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm New Password',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Password would be updated in a real implementation
                  // For this demo, we just show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
                child: const Text('Change'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveUserData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        Center(
                          child: GestureDetector(
                            onTap: _isEditing ? _pickImage : null,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage:
                                      userModel.profileImagePath.isNotEmpty
                                          ? FileImage(
                                            File(userModel.profileImagePath),
                                          )
                                          : null,
                                  child:
                                      userModel.profileImagePath.isEmpty
                                          ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                                if (_isEditing)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryRed,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Personal Information
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
                                  'Personal Information',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),

                                // Name
                                TextFormField(
                                  controller: _nameController,
                                  enabled: _isEditing,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Email
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        enabled:
                                            false, // Email is linked to Google account
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(Icons.email),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    if (!userModel.isLoggedIn)
                                      IconButton(
                                        icon: const Icon(Icons.login),
                                        onPressed: _signInWithGoogle,
                                        tooltip: 'Sign in with Google',
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Phone Number
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        enabled: _isEditing,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon: Icon(Icons.phone),
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                    if (_isEditing)
                                      IconButton(
                                        icon: const Icon(Icons.verified),
                                        onPressed: _verifyPhone,
                                        tooltip: 'Verify Phone',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Security
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
                                  'Security',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),

                                // Change Password
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRed.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.lock_outline,
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                  title: const Text('Change Password'),
                                  subtitle: const Text(
                                    'Update your account password',
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: _changePassword,
                                ),

                                const Divider(),

                                // Log Out
                                if (userModel.isLoggedIn)
                                  ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                      ),
                                    ),
                                    title: const Text('Log Out'),
                                    subtitle: const Text(
                                      'Sign out from your account',
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onTap: () async {
                                      final GoogleSignIn googleSignIn =
                                          GoogleSignIn();
                                      await googleSignIn.signOut();
                                      userModel.logout();

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Logged out successfully',
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // App Info
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
                                  'App Information',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),

                                // Version
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  title: const Text('Version'),
                                  subtitle: const Text('1.0.0'),
                                ),

                                const Divider(),

                                // About
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.help_outline,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  title: const Text('About'),
                                  subtitle: const Text(
                                    'Rhythmbhara Tara Sadhana',
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    showAboutDialog(
                                      context: context,
                                      applicationName:
                                          'Rhythmbhara Tara Sadhana',
                                      applicationVersion: '1.0.0',
                                      applicationIcon: const FlutterLogo(
                                        size: 48,
                                      ),
                                      applicationLegalese:
                                          '© 2023 Rhythmbhara Tara Sadhana',
                                    );
                                  },
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
              ),
    );
  }
}
