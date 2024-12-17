import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late UserService _userService;
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _photoUrlController = TextEditingController();
  File? _selectedImage;
  bool _isEditingField = false;

  @override
  void initState() {
    super.initState();
    _initializeUserService();
  }

  Future<void> _initializeUserService() async {
    _userService = await UserService.getInstance();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = _userService.getUserData();
    if (userData != null) {
      _displayNameController.text = userData['displayName'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _photoUrlController.text = userData['photoURL'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    if (await Permission.photos.request().isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _photoUrlController.text = pickedFile.path;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access gallery.')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Update user's display name and photo URL
      await currentUser.updateDisplayName(_displayNameController.text);
      await currentUser.updatePhotoURL(_photoUrlController.text);

      // Save user data to UserService
      final updatedUser = {
        'uid': currentUser.uid,
        'email': _emailController.text,
        'displayName': _displayNameController.text,
        'photoURL': _photoUrlController.text,
        'lastLoginAt': DateTime.now().toIso8601String(),
      };
      await _userService.saveUserData(currentUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in!')),
      );
    }
  }

  Widget _buildEditableField(
      {required TextEditingController controller, required String labelText}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: _isEditingField,
            decoration: InputDecoration(labelText: labelText),
          ),
        ),
        IconButton(
          icon: Icon(_isEditingField ? Icons.check : Icons.edit),
          onPressed: () {
            setState(() {
              _isEditingField = !_isEditingField;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_photoUrlController.text.isNotEmpty
                    ? NetworkImage(_photoUrlController.text) as ImageProvider
                    : AssetImage('assets/default_avatar.png')),
                child: Icon(Icons.edit, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            _buildEditableField(
              controller: _displayNameController,
              labelText: 'Display Name',
            ),
            _buildEditableField(
              controller: _emailController,
              labelText: 'Email',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }
}
