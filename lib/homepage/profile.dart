import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/profile.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3), // Blur effect
            ),
          ),
          Center(
            child: user == null
                ? _buildGuestView()
                : _userData == null
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange))
                    : _buildUserProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 150, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'You are not signed in.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => Get.toNamed('/login'),
            child: const Text(
              'Sign In',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _userData!['profileImageUrl'] != null &&
                    _userData!['profileImageUrl'].isNotEmpty
                ? NetworkImage(_userData!['profileImageUrl'])
                : const AssetImage('assets/images/nvhlogo.png')
                    as ImageProvider,
          ),
          const SizedBox(height: 24),
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildUserPosts(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileText('Name', _userData!['name'] ?? 'Not provided'),
            _profileText('Email', _userData!['email'] ?? 'Not provided'),
            _profileText('Role', _userData!['role'] ?? 'Not specified'),
            if (_userData!['role'] == 'Landlord')
              _profileText('Location', _userData!['location'] ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _profileText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: ${value.isNotEmpty ? value : "Not available"}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserPosts() {
    User? user = _auth.currentUser;
    if (user == null) return Container();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var posts = snapshot.data!.docs;
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var postData = posts[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: postData['imageUrls'] != null &&
                        postData['imageUrls'].isNotEmpty
                    ? Image.network(postData['imageUrls'][0], width: 50)
                    : const Icon(Icons.image_not_supported),
                title: Text(
                  '₦${postData['caption'] ?? "Price"} - ${postData['category'] ?? "Category not set"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePost(posts[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
}
