
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'map_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailsScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsScreen> createState() =>
      _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  YoutubePlayerController? _videoController;

  String getVideoId(String url) {
    try {
      final uri = Uri.parse(url);

      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : '';
      }

      if (uri.host.contains('youtube.com')) {
        if (uri.queryParameters.containsKey('v')) {
          return uri.queryParameters['v'] ?? '';
        }

        if (uri.pathSegments.contains('embed')) {
          final index = uri.pathSegments.indexOf('embed');
          return uri.pathSegments.length > index + 1
              ? uri.pathSegments[index + 1]
              : '';
        }
      }
    } catch (_) {
      return '';
    }

    return '';
  }

  @override
  void initState() {
    super.initState();

    final videoUrl =
        widget.place['videoUrl']?.toString() ?? '';

    final videoId = getVideoId(videoUrl);

    if (videoId.isNotEmpty) {
      _videoController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
      );
    }
  }

  @override
  void dispose() {
    _videoController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    final String name =
        place['name']?.toString() ?? 'Unknown Place';

    final String district =
        place['district']?.toString() ?? 'Unknown District';

    final String category =
        place['category']?.toString() ?? 'Unknown Category';

    final String id =
        place['id']?.toString() ?? 'N/A';

    final String description =
        place['description']?.toString() ??
        'Description not available.';

    final String entryFee =
        place['entryFee']?.toString() ?? 'To be verified';

    final String openingHours =
        place['openingHours']?.toString() ?? 'To be verified';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Place Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 70,
                    color: Colors.teal.shade700,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '$district, Bangladesh',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'About This Place',
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
                  children: [
                    buildDetailRow(Icons.numbers, 'Place ID', id),
                    const Divider(),
                    buildDetailRow(Icons.location_city, 'District', district),
                    const Divider(),
                    buildDetailRow(Icons.category, 'Category', category),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Visiting Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildDetailRow(
                      Icons.confirmation_number,
                      'Entry Fee',
                      entryFee,
                    ),
                    const Divider(),
                    buildDetailRow(
                      Icons.access_time,
                      'Opening Hours',
                      openingHours,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // YouTube Video Section
            const Text(
              'Explore This Place',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _videoController != null
                    ? YoutubePlayer(
                        controller: _videoController!,
                        aspectRatio: 16 / 9,
                      )
                    : const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.video_library,
                              size: 45,
                              color: Colors.teal,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Video will be available soon.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
                        // Map Section
            const Text(
              'Location on Map',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        placeName: name,
                        district: district,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('View Location on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
