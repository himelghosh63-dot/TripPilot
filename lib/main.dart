
import 'package:flutter/material.dart';

void main() {
  runApp(const TripPilotApp());
}

class TripPilotApp extends StatelessWidget {
  const TripPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripPilot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String selectedDistrict = 'All Districts';
  String selectedCategory = 'All Categories';

  final List<Map<String, String>> places = [
    {
      'name': 'Cox’s Bazar Sea Beach',
      'district': 'Cox’s Bazar',
      'category': 'Beach',
    },
    {
      'name': 'Patenga Sea Beach',
      'district': 'Chattogram',
      'category': 'Beach',
    },
    {
      'name': 'Kaptai Lake',
      'district': 'Rangamati',
      'category': 'Lake',
    },
    {
      'name': 'Sajek Valley',
      'district': 'Rangamati',
      'category': 'Hill',
    },
    {
      'name': 'Boga Lake',
      'district': 'Bandarban',
      'category': 'Lake',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.toLowerCase();

    final filteredPlaces = places.where((place) {
      final matchesName =
          place['name']!.toLowerCase().contains(query);

      final matchesDistrict =
          selectedDistrict == 'All Districts' ||
          place['district'] == selectedDistrict;

      final matchesCategory =
          selectedCategory == 'All Categories' ||
          place['category'] == selectedCategory;

      return matchesName && matchesDistrict && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TripPilot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Chittagong Division',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover places and plan your next trip.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const Text(
            'Find Your Destination',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search tourist spots...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedDistrict,
            decoration: const InputDecoration(
              labelText: 'Select District',
              border: OutlineInputBorder(),
            ),
            items: [
              'All Districts',
              'Chattogram',
              'Cox’s Bazar',
              'Rangamati',
              'Bandarban',
            ].map((district) {
              return DropdownMenuItem(
                value: district,
                child: Text(district),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value!;
              });
            },
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(),
            ),
            items: [
              'All Categories',
              'Beach',
              'Lake',
              'Hill',
            ].map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Tourist Spots (${filteredPlaces.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          if (filteredPlaces.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No tourist spots found.'),
              ),
            ),

          ...filteredPlaces.map((place) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.teal,
                  ),
                ),
                title: Text(
                  place['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${place['district']} • ${place['category']}',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
    );
  }
}
