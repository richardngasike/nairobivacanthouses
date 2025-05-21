import 'package:flutter/material.dart';
import 'package:nairobivacanthouses/homepage/profile.dart';
import 'package:nairobivacanthouses/homepage/messages.dart';
import 'package:nairobivacanthouses/homepage/uploadpage.dart';
import 'package:nairobivacanthouses/homepage/rentals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PostPage(), // Fetches from Firestore
      const UploadPage(),
      MessagesPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() {
    setState(() {
      _selectedIndex = 3; // Index of ProfilePage in _pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NVH-Kenya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/nvhlogo.png',
              width: 28, // Adjust size as needed
              height: 28,
              fit: BoxFit.contain, // Ensures the logo fits well
            ),
            onPressed: _navigateToProfile, // Navigate to ProfilePage
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8), // Adds spacing to the right
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Vacants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
