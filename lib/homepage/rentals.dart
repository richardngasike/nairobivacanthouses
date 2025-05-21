import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/scheduler.dart'; // For post-frame callback
import 'package:get/get.dart';
import 'package:nairobivacanthouses/homepage/menulistings/premium.dart';
import 'package:url_launcher/url_launcher.dart'; // Import GetX
import 'package:nairobivacanthouses/homepage/menulistings/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final List<File?> images;
  final List<String> imageUrls; // Supabase URLs
  final String caption;
  final String location;
  final String phone;
  final String category;
  final Map<String, bool> amenities;
  final String? userId;
  Post({
    this.images = const [],
    this.imageUrls = const [],
    required this.caption,
    required this.location,
    required this.phone,
    required this.category,
    required this.amenities,
    this.userId,
  });

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      caption: data['caption'] ?? '',
      location: data['location'] ?? '',
      phone: data['phone'] ?? '',
      category: data['category'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      amenities: Map<String, bool>.from(data['amenities'] ?? {}),
      userId: data['userId'],
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => PostPageState();
}

class PostPageState extends State<PostPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Post> allPosts = [];
  List<Post> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _filterPosts();
      });
    });
  }

  void _filterPosts() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPosts = List.from(allPosts);
      } else {
        filteredPosts = allPosts.where((post) {
          final captionMatch = post.caption.toLowerCase().contains(query);
          final locationMatch = post.location.toLowerCase().contains(query);
          final phoneMatch = post.phone.toLowerCase().contains(query);
          final categoryMatch = post.category.toLowerCase().contains(query);
          final amenitiesMatch = post.amenities.entries.any(
            (entry) => entry.key.toLowerCase().contains(query) && entry.value,
          );
          return captionMatch ||
              locationMatch ||
              phoneMatch ||
              categoryMatch ||
              amenitiesMatch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vacant Listings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () async {
              final Uri callUri = Uri.parse("tel:+254750068054");
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri);
              } else {
                throw 'Could not launch $callUri';
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'Premium Unlock':
                  Get.to(() => PremiumPage());
                  break;
                case 'Settings':
                  Get.to(() => const SettingsPage());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Premium Unlock',
                child: Text('Premium Unlock', style: TextStyle(fontSize: 14)),
              ),
              const PopupMenuItem<String>(
                value: 'Settings',
                child: Text('Settings', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'Bedsitter'),
            Tab(text: 'Single Room'),
            Tab(text: 'One Bedroom'),
            Tab(text: 'Self Contain'),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by location, rent, amenities...',
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade700),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterPosts();
                          },
                        )
                      : null,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No vacancies found',
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }
                  allPosts = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Post.fromFirestore(data);
                  }).toList();

                  if (filteredPosts.isEmpty && _searchController.text.isEmpty) {
                    filteredPosts = List.from(allPosts);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostList('Bedsitter', filteredPosts),
                      _buildPostList('Single Room', filteredPosts),
                      _buildPostList('One Bedroom', filteredPosts),
                      _buildPostList('Self Contain', filteredPosts),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList(String category, List<Post> posts) {
    List<Post> postsInCategory =
        posts.where((post) => post.category == category).toList();

    if (postsInCategory.isEmpty) {
      return const Center(
        child: Text('No vacancies found', style: TextStyle(fontSize: 14)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use MediaQuery to get screen width
        double screenWidth = MediaQuery.of(context).size.width;
        int columnCount;

        // Define column count based on screen size
        if (screenWidth < 600) {
          columnCount = 1; // Mobile
        } else if (screenWidth < 900) {
          columnCount = 2; // Tablet
        } else {
          columnCount = 3; // Laptop/Desktop
        }
        final User? currentUser = FirebaseAuth.instance.currentUser;

        void deletePost(Post post) async {
          try {
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(post.userId)
                .delete();
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Post deleted successfully!')),
            );
          } catch (e) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete post: $e')),
            );
          }
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 0.8,
          ),
          itemCount: postsInCategory.length,
          itemBuilder: (context, index) {
            Post post = postsInCategory[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: post.imageUrls.isNotEmpty
                          ? Image.network(
                              post.imageUrls[0], // Show first image
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange.shade700,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Text(
                                      'Check your internet!',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Text(
                                  'No image',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.caption,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${post.location} | ${post.phone}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete button (appears only if the logged-in user owns the post)
                        if (currentUser != null &&
                            currentUser.uid == post.userId)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18,
                            ),
                            onPressed: () => deletePost(post),
                          ),

                        // "See More" button aligned to the right
                        TextButton(
                          onPressed: () => _showPostDetails(context, post),
                          child: Text(
                            'See More',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPostDetails(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: controller,
                children: [
                  SizedBox(
                    height: 250,
                    child: post.imageUrls.isEmpty
                        ? Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Text(
                                'No images available',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 300,
                                    child: Image.network(
                                      post.imageUrls[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: Text(
                                              'Image failed to load',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.caption,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.location_on, 'Location', post.location),
                  _buildDetailRow(Icons.phone, 'Phone', post.phone),
                  _buildDetailRow(Icons.category, 'Category', post.category),
                  const SizedBox(height: 20),
                  const Text(
                    'Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.amenities.entries.map((entry) {
                      return Chip(
                        avatar: Icon(
                          entry.value ? Icons.check_circle : Icons.cancel,
                          color: entry.value ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        label: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 32,
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vacant Listings App',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const PostPage(),
    );
  }
}
