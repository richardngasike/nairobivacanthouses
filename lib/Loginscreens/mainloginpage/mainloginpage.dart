import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nairobivacanthouses/homepage/homepage.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this for launching URL

class MainLoginPage extends StatefulWidget {
  const MainLoginPage({super.key});

  @override
  State<MainLoginPage> createState() => _MainLoginPageState();
}

class _MainLoginPageState extends State<MainLoginPage> {
  // Function to launch policy URL
  Future<void> _launchPolicyUrl() async {
    const url = 'https://nvhpolicies.netlify.app';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to show policy dialog
  void _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Policy Agreement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('please read and agree to our policies before proceeding'),
              SizedBox(height: 10),
              TextButton(
                onPressed: _launchPolicyUrl,
                child: Text(
                  'view Policies',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop(); // Close dialog
                Get.to(() => HomeScreen()); // Navigate to HomeScreen
              },
              child: Text('I Agree'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/nrb3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content Overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/nvhlogo.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 50),
                // Landlord Button
                ElevatedButton(
                  onPressed:
                      _showPolicyDialog, // Show dialog instead of direct navigation
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Explore Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Text(
                    'Developed by Richard Ngasike',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 9.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
