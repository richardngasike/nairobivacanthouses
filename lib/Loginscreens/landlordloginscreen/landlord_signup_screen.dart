import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nairobivacanthouses/homepage/homepage.dart'; // Adjust path

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final List<String> roles = ['Landlord', 'Tenant'];
  String? selectedRole;

  final List<String> locations = [
    'BuruBuru',
    'Donholm',
    'Eastleigh',
    'Embakasi',
    'Gikambura',
    'Highridge',
    'Jamhuri',
    'Juja',
    'Kahawa West',
    'Kamukunji',
    'Kamulu',
    'Karen',
    'Kayole',
    'Kariobangi',
    'Kasarani',
    'Kawagware',
    'Kilimani',
    'Kimbo',
    'Kibera',
    'Lang’ata',
    'Lavington',
    'Mathare',
    'Mlolongo',
    'Mombasa Road',
    'Ngara',
    'Njiru',
    'Nairobi Central',
    'Parklands',
    'Pangani',
    'Pipeline',
    'Ruai',
    'Ruiru',
    'Roysambu',
    'South B',
    'South C',
    'Starehe',
    'Thika Road',
    'Thika Town',
    'Westlands',
    'Wangige',
  ];
  String? selectedLocation;
  File? _imageFile;

  // Text controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createAccount() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        selectedRole == null) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    if (selectedRole == 'Landlord' && selectedLocation == null) {
      Get.snackbar('Error', 'Please select a location for Landlord account');
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        String? profileImageUrl;
        if (_imageFile != null) {
          String fileName =
              'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
          UploadTask task =
              _storage.ref('profile_images/$fileName').putFile(_imageFile!);
          TaskSnapshot snapshot = await task;
          profileImageUrl = await snapshot.ref.getDownloadURL();
        }

        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
        user = _auth.currentUser;

        await _firestore.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': selectedRole,
          'location': selectedRole == 'Landlord' ? selectedLocation : null,
          'profileImageUrl': profileImageUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Get.back();
        Get.snackbar('Success', '$selectedRole Account Created');
        Get.offAllNamed('/home',
            arguments: selectedRole); // Pass role as argument
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to create account: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/images/nvhlogo.png')
                            as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt,
                            color: Colors.white, size: 30)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Landlord or Tenant',
                  border: OutlineInputBorder(),
                ),
                value: selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue;
                  });
                },
                items: roles.map<DropdownMenuItem<String>>((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (selectedRole == 'Landlord')
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'House Location',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedLocation,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue;
                    });
                  },
                  items: locations
                      .map<DropdownMenuItem<String>>((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 25),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TO Implement Google Sign-In
                    },
                    icon: const Icon(Icons.g_mobiledata,
                        size: 30, color: Colors.red),
                    label: const Text('Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TO Implement Facebook Sign-In
                    },
                    icon: const Icon(Icons.facebook,
                        size: 30, color: Colors.blue),
                    label: const Text('Facebook'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TO Implement Apple Sign-In
                    },
                    icon:
                        const Icon(Icons.apple, size: 30, color: Colors.black),
                    label: const Text('Apple'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/login'); // Link to LandlordLoginScreen
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Get.off(() => const HomeScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Continue without Account?'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
