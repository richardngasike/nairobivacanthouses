import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias to avoid conflicts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nairobivacanthouses/homepage/rentals.dart'; // Assuming PostPage is here

class Post {
  final List<File?> images;
  final String caption;
  final String location;
  final String phone;
  final String category;
  final Map<String, bool> amenities;
  final List<String>? imageUrls;
  final String? docId;

  Post({
    required this.images,
    required this.caption,
    required this.location,
    required this.phone,
    required this.category,
    required this.amenities,
    this.imageUrls,
    this.docId,
  });

  Map<String, dynamic> toFirestore(List<String> updatedImageUrls) {
    return {
      'caption': caption,
      'location': location,
      'phone': phone,
      'category': category,
      'amenities': amenities,
      'imageUrls': updatedImageUrls,
      'userId': firebase_auth.FirebaseAuth.instance.currentUser?.uid,
      'createdAt': docId == null
          ? FieldValue.serverTimestamp()
          : FieldValue.serverTimestamp(),
    };
  }
}

class UploadPage extends StatefulWidget {
  final Post? postToEdit;
  const UploadPage({super.key, this.postToEdit});

  @override
  State<UploadPage> createState() => UploadPageState();
}

class UploadPageState extends State<UploadPage> {
  List<File?> images = List.filled(5, null);
  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedCategory;
  List<String> existingImageUrls = [];

  Map<String, IconData> amenityIcons = {
    'WiFi': Icons.wifi,
    'Parking': Icons.local_parking,
    'Water': Icons.water,
    'Electricity': Icons.flash_on,
    'Security': Icons.security,
    'Gym': Icons.fitness_center,
    'Swimming Pool': Icons.pool,
    'Playground': Icons.sports_soccer,
    'Backup Generator': Icons.power,
    'CCTV': Icons.videocam,
    'Elevator': Icons.elevator,
    'Laundry': Icons.local_laundry_service,
    'Garden': Icons.grass,
  };

  Map<String, bool> amenities = {
    'WiFi': false,
    'Parking': false,
    'Water': false,
    'Electricity': false,
    'Security': false,
    'Gym': false,
    'Swimming Pool': false,
    'Playground': false,
    'Backup Generator': false,
    'CCTV': false,
    'Elevator': false,
    'Laundry': false,
    'Garden': false,
  };

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      captionController.text = widget.postToEdit!.caption;
      locationController.text = widget.postToEdit!.location;
      phoneController.text = widget.postToEdit!.phone;
      selectedCategory = widget.postToEdit!.category;
      amenities = Map.from(widget.postToEdit!.amenities);
      existingImageUrls = List.from(widget.postToEdit!.imageUrls ?? []);
      images = List.filled(5, null);
    }
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      if (await imageFile.exists()) {
        setState(() {
          images[index] = imageFile;
        });
      } else {
        Get.snackbar('Error', 'Selected image file does not exist');
      }
    }
  }

  Future<void> submitPost() async {
    if (captionController.text.isEmpty ||
        locationController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedCategory == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    firebase_auth.User? user =
        _auth.currentUser; // Explicitly use the aliased type
    if (user == null) {
      Get.snackbar('Error', 'You must be signed in to post');
      Get.toNamed('/login');
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      List<String> imageUrls = List.from(existingImageUrls);
      for (int i = 0; i < images.length; i++) {
        if (images[i] != null) {
          String fileName =
              'post_${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

          await _supabase.storage
              .from('post-images')
              .upload(fileName, images[i]!);

          String url =
              _supabase.storage.from('post-images').getPublicUrl(fileName);

          if (i < imageUrls.length) {
            if (imageUrls[i].isNotEmpty) {
              String oldFileName = imageUrls[i].split('/').last;
              await _supabase.storage.from('post-images').remove([oldFileName]);
            }
            imageUrls[i] = url;
          } else {
            imageUrls.add(url);
          }
        }
      }

      Post post = Post(
        images: List.from(images),
        caption: captionController.text,
        location: locationController.text,
        phone: phoneController.text,
        category: selectedCategory!,
        amenities: Map.from(amenities),
        imageUrls: imageUrls,
        docId: widget.postToEdit?.docId,
      );

      if (widget.postToEdit == null) {
        await _firestore.collection('posts').add(post.toFirestore(imageUrls));
      } else {
        await _firestore
            .collection('posts')
            .doc(widget.postToEdit!.docId)
            .update(post.toFirestore(imageUrls));
      }

      Get.back();
      Get.snackbar(
          'Success',
          widget.postToEdit == null
              ? 'Post submitted successfully!'
              : 'Post updated successfully!');
      Get.to(() => const PostPage());

      setState(() {
        images = List.filled(5, null);
        captionController.clear();
        locationController.clear();
        phoneController.clear();
        selectedCategory = null;
        amenities.updateAll((key, value) => false);
        existingImageUrls.clear();
      });
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to submit post: $e');
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.postToEdit == null
                ? 'Upload Rental Listing'
                : 'Edit Rental Listing',
            style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload up to 5 Images', style: TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => pickImage(index),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: images[index] != null
                        ? Image.file(images[index]!, fit: BoxFit.cover)
                        : (index < existingImageUrls.length &&
                                existingImageUrls[index].isNotEmpty)
                            ? Image.network(existingImageUrls[index],
                                fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                labelText: 'Rent in Ksh',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const Text('Category', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              isExpanded: true,
              items: ['Bedsitter', 'Single Room', 'One Bedroom', 'Self Contain']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            const SizedBox(height: 12),
            const Text('Amenities', style: TextStyle(fontSize: 18)),
            ...amenities.keys.map((amenity) => Row(
                  children: [
                    Icon(amenityIcons[amenity], color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(amenity)),
                    Checkbox(
                      value: amenities[amenity],
                      onChanged: (val) =>
                          setState(() => amenities[amenity] = val!),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitPost,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                  widget.postToEdit == null ? 'Post Vacant' : 'Update Post'),
            ),
            Center(
              child: Text(
                'NOTE: If you are using website,please download our app from playstore to post',
                style: TextStyle(fontSize: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
