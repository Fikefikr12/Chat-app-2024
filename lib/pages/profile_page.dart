import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user profile from Firestore on init
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _bioController.text = userDoc['bio'] ?? '';
        });
      }
    }
  }

  // Choose an image from the gallery or capture from the camera
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    if (pickedFile != null) {
                      _imageFile = File(pickedFile.path);
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    if (pickedFile != null) {
                      _imageFile = File(pickedFile.path);
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Save profile details and image to Firebase
  Future<void> _saveProfile() async {
    if (user != null) {
      setState(() {
        _isSaving = true;
      });

      String? imageUrl;

      // Upload the image to Firebase Storage if an image is selected
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child(user!.uid + '.jpg');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Update user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text,
        'bio': _bioController.text,
        'imageUrl': imageUrl ?? user!.photoURL,
      }, SetOptions(merge: true));

      // Optionally, update FirebaseAuth displayName and photoURL
      await user!.updateDisplayName(_nameController.text);
      if (imageUrl != null) await user!.updatePhotoURL(imageUrl);

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Updated Successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView( // This prevents overflow issues
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70, // Increased size of the profile image
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : NetworkImage(user?.photoURL ?? '') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, size: 30, color: Colors.grey), // Increased size and changed color to grey
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Display the user's email
              Text(
                user?.email ?? 'No Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25), // Added horizontal padding
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25), // Added horizontal padding
                child: TextField(
                  controller: _bioController,
                  decoration: InputDecoration(labelText: 'Bio'),
                ),
              ),
              SizedBox(height: 20),
              _isSaving
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
