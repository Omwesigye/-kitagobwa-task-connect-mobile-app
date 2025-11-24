import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task_connect_app/screens/api_config.dart';

class LiveLocationPage extends StatefulWidget {
  const LiveLocationPage({super.key});

  @override
  State<LiveLocationPage> createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  final mapController = MapController();
  List<Marker> markers = [];
  late PusherChannelsFlutter pusher;

  @override
  void initState() {
    super.initState();
    initPusher();
    startLocationStream();
  }

  void initPusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    await pusher.init(
      apiKey: "abcd1234",
      cluster: "mt1",
      onEvent: onEvent,
    );
    await pusher.connect();
    // Use a public channel to avoid auth complexity; align with your backend broadcast
    await pusher.subscribe(channelName: 'public-live-locations', onEvent: onEvent);
  }

  void onEvent(PusherEvent event) {
    final data = jsonDecode(event.data!);
    updateMarker(
      data['location']['user_id'],
      data['location']['latitude'],
      data['location']['longitude'],
    );
  }

  void startLocationStream() {
    Geolocator.getPositionStream().listen((pos) {
      sendLocation(pos.latitude, pos.longitude);
      updateMarker(0, pos.latitude, pos.longitude); // Current user
    });
  }

  void sendLocation(double lat, double lng) {
    // POST to /api/location with Bearer token
    () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final userIdStr = prefs.getString('user_id');
        if (token == null || userIdStr == null) return;

        final uri = Uri.parse(ApiConfig.postLocation());
        await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'user_id': int.tryParse(userIdStr),
            'latitude': lat,
            'longitude': lng,
          }),
        );
      } catch (_) {}
    }();
  }

  void updateMarker(int userId, double lat, double lng) {
    markers.removeWhere((m) => m.key == ValueKey(userId));
    markers.add(
      Marker(
        key: ValueKey(userId),
        point: LatLng(lat, lng),
        child: Icon(
          userId == 0 ? Icons.circle : Icons.person_pin,
          color: userId == 0 ? Colors.red : Colors.blue,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialZoom: 16,
        initialCenter: LatLng(0.0, 0.0),
      ),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
