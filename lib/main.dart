
import 'auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

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
      home: const AuthScreen(),
    );
  }
}
class HomeScreen
 extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final String apiUrl =
      'http://10.0.2.2:3000/api/places';

  List<Map<String, dynamic>> places = [];

  bool isLoading = false;
  String? errorMessage;

  int currentPage = 1;
  int totalPages = 1;
  int totalPlaces = 0;

  String selectedDistrict = 'All Districts';
  String selectedCategory = 'All Categories';

  DateTime? departureDate;
  DateTime? returnDate;

  Map<String, int> userRatings = {};

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces({int page = 1}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': '2',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['success'] != true) {
          throw Exception('API request was unsuccessful.');
        }

        final List<dynamic> data = result['data'];

        if (!mounted) return;

        setState(() {
          places = data
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          currentPage = result['page'];
          totalPages = result['totalPages'];
          totalPlaces = result['totalPlaces'];
        });
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Could not load places. Check your API server.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> selectDepartureDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: departureDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
    helpText: 'Select Departure Date',
  );

  if (pickedDate != null) {
    setState(() {
      departureDate = pickedDate;

      if (returnDate != null &&
          returnDate!.isBefore(pickedDate)) {
        returnDate = null;
      }
    });
  }
}

Future<void> selectReturnDate() async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: returnDate ??
        departureDate ??
        DateTime.now(),
    firstDate: departureDate ?? DateTime.now(),
    lastDate: DateTime(2100),
    helpText: 'Select Return Date',
  );

  if (pickedDate != null) {
    setState(() {
      returnDate = pickedDate;
    });
  }
}

Widget buildRating(String placeName) {
  final rating = userRatings[placeName] ?? 0;

  return Row(
    children: [
      const Text('Rate: '),
      ...List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              userRatings[placeName] = index + 1;
            });
          },
          icon: Icon(
            Icons.star,
            color: index < rating
                ? Colors.amber
                : Colors.grey,
          ),
        );
      }),
      Text('$rating/5'),
    ],
  );
}

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query =
        searchController.text.toLowerCase().trim();

    final filteredPlaces = places.where((place) {
      final matchesName = place['name']
          .toString()
          .toLowerCase()
          .contains(query);

      final matchesDistrict =
          selectedDistrict == 'All Districts' ||
          place['district'] == selectedDistrict;

      final matchesCategory =
          selectedCategory == 'All Categories' ||
          place['category'] == selectedCategory;

      return matchesName &&
          matchesDistrict &&
          matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TripPilot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
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
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
  'Plan Your Trip',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: selectDepartureDate,
          icon: const Icon(Icons.flight_takeoff),
          label: Text(
            departureDate == null
                ? 'Select Departure Date'
                : 'Departure: ${departureDate!.day}/${departureDate!.month}/${departureDate!.year}',
          ),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: selectReturnDate,
          icon: const Icon(Icons.flight_land),
          label: Text(
            returnDate == null
                ? 'Select Return Date'
                : 'Return: ${returnDate!.day}/${returnDate!.month}/${returnDate!.year}',
          ),
        ),
      ],
    ),
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

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Column(
              children: [
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    fetchPlaces(page: currentPage);
                  },
                  child: const Text('Retry'),
                ),
              ],
            )
          else if (filteredPlaces.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No tourist spots found.'),
              ),
            )
          else
            ...filteredPlaces.map((place) {
              return Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.teal,
                    ),
                  ),
                  title: Text(
                    place['name'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      '${place['district']} • ${place['category']}',
    ),

    const SizedBox(height: 6),

    buildRating(place['name'].toString()),
  ],
),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              );
            }),

          const SizedBox(height: 16),

          Text(
            'Page $currentPage of $totalPages • '
            '$totalPlaces places in total',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: !isLoading && currentPage > 1
                    ? () => fetchPlaces(
                        page: currentPage - 1,
                      )
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              ElevatedButton.icon(
                onPressed:
                    !isLoading && currentPage < totalPages
                        ? () => fetchPlaces(
                            page: currentPage + 1,
                          )
                        : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
