
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapScreen extends StatefulWidget {
  final String placeName;
  final String district;

  const MapScreen({
    super.key,
    required this.placeName,
    required this.district,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    final searchUrl = Uri.https(
      'www.openstreetmap.org',
      '/search',
      {
        'query':
            '${widget.placeName}, ${widget.district}, Bangladesh',
      },
    );

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(searchUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.placeName} Map'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
