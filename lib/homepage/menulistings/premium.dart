import 'package:flutter/material.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  final List<Map<String, dynamic>> rentals = const [
    {
      'category': 'Two Bedroom',
      'items': [
        [
          {
            'image': 'assets/images/single1.jpeg',
            'location': 'Kilimani, Nairobi',
            'amenities': 'Wi-Fi, Parking, Security',
          },
          {
            'image': 'assets/images/single8.jpeg',
            'location': 'South C, Nairobi',
            'amenities': 'Water, Electricity, Tiled',
          },
        ],
      ]
    },
    {
      'category': 'Three Bedroom',
      'items': [
        [
          {
            'image': 'assets/images/bedsitter5.jpeg',
            'location': 'Westlands, Nairobi',
            'amenities': 'Wi-Fi, Swimming Pool, Gym',
          },
          {
            'image': 'assets/images/bedsitter4.jpeg',
            'location': 'Kilimani, Nairobi',
            'amenities': 'Water, Security, Balcony',
          },
        ],
      ]
    },
    {
      'category': 'Four Bedroom',
      'items': [
        [
          {
            'image': 'assets/images/self5.jpeg',
            'location': 'Lavington, Nairobi',
            'amenities': 'Wi-Fi, Parking, Pool',
          },
          {
            'image': 'assets/images/self6.jpeg',
            'location': 'Karen, Nairobi',
            'amenities': 'Electricity, Gym, Balcony',
          },
        ],
      ]
    },
    {
      'category': 'Airbnb',
      'items': [
        [
          {
            'image': 'assets/images/double1.jpeg',
            'location': 'Nairobi CBD',
            'amenities': 'Wi-Fi, TV, Security',
          },
          {
            'image': 'assets/images/double2.jpeg',
            'location': 'Ngong Road, Nairobi',
            'amenities': 'Water, Wi-Fi, Gym',
          },
        ],
      ]
    },
    {
      'category': 'Studios',
      'items': [
        [
          {
            'image': 'assets/images/double8.jpeg',
            'location': 'Kilimani, Nairobi',
            'amenities': 'Wi-Fi, Parking, Security',
          },
          {
            'image': 'assets/images/double9.jpeg',
            'location': 'Westlands, Nairobi',
            'amenities': 'Electricity, Water, Gym',
          },
        ],
      ]
    },
    {
      'category': 'Office Space',
      'items': [
        [
          {
            'image': 'assets/images/double5.jpeg',
            'location': 'Upperhill, Nairobi',
            'amenities': 'High-Speed Internet, Security, Parking',
          },
          {
            'image': 'assets/images/double4.jpeg',
            'location': 'Kilpah, Nairobi',
            'amenities': 'Wi-Fi, Elevator, Security',
          },
        ],
      ]
    },
    {
      'category': 'Company Space',
      'items': [
        [
          {
            'image': 'assets/images/double7.jpeg',
            'location': 'Industrial Area, Nairobi',
            'amenities': 'Parking, Wi-Fi, Power Backup',
          },
          {
            'image': 'assets/images/double9.jpeg',
            'location': 'Karen, Nairobi',
            'amenities': 'Air Conditioning, Wi-Fi, Security',
          },
        ],
      ]
    },
  ];

  get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Listings-whatsapp 0750068054',
            style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: rentals.length,
        itemBuilder: (context, index) {
          final category = rentals[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Title and "See More"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category['category'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to more listings of this category
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (context) => MoreListingsPage(category: category),
                          // ));
                        },
                        child: const Text('See More'),
                      ),
                    ],
                  ),
                ),
                // Horizontal List of Properties
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category['items'].length,
                    itemBuilder: (context, itemIndex) {
                      final item = category['items'][itemIndex];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.asset(
                                item['image'],
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['location'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['amenities'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
