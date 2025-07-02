
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AlertService {
  static Future<List<dynamic>> fetchAlerts(LatLng start, LatLng end) async {
    final url = Uri.parse('http://localhost:8004/alerts');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "route": [
          {"latitude": start.latitude, "longitude": start.longitude},
          {"latitude": end.latitude, "longitude": end.longitude}
        ],
        "radius_m": 100
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}
