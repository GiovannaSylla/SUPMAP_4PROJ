
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'signalement_page.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(SupMapApp());
}

class SupMapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUPMAP',
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _avoidTolls = false;
  AutocompletePrediction? _lastSelectedPrediction;

  late GooglePlace _googlePlace;
  List<AutocompletePrediction> _predictions = [];
  final TextEditingController _searchController = TextEditingController();
  final String _apiKey = "AIzaSyC46bvErDVSv_G-GBT9HluboE5uJ_zqtcQ";

  @override
  void initState() {
    super.initState();
    _initLocation();
    _googlePlace = GooglePlace(_apiKey);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      await fetchSignalements();
    }
  }

  Future<BitmapDescriptor> getResizedIcon(String path, int width) async {
    final ByteData byteData = await rootBundle.load(path);
    final Uint8List imageData = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(imageData, targetWidth: width);
    final frame = await codec.getNextFrame();
    final resizedImage = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resizedImage!.buffer.asUint8List());
  }

  Future<void> fetchSignalements() async {
    final url = Uri.parse('http://10.0.2.2:8002/incidents/incidents/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        Set<Marker> newMarkers = {};

        for (var signalement in data) {
          final LatLng position = LatLng(
            signalement['latitude'],
            signalement['longitude'],
          );
          final type = signalement['title'] ?? "incident";

          String assetName;
          switch (type.toLowerCase()) {
            case "accident":
              assetName = 'assets/accident.png';
              break;
            case "embouteillage":
              assetName = 'assets/embouteillage.png';
              break;
            case "obstacle":
              assetName = 'assets/obstacle.png';
              break;
            case "police":
              assetName = 'assets/police.png';
              break;
            case "barrière":
              assetName = 'assets/trafficbarrier.png';
              break;
            default:
              assetName = 'assets/accident.png';
          }

          final icon = await getResizedIcon(assetName, 100);

          newMarkers.add(Marker(
            markerId: MarkerId("signalement_${signalement['title']}_${signalement['latitude']}_${signalement['longitude']}"),
            position: position,
            icon: icon,
            infoWindow: InfoWindow(
              title: type.toUpperCase(),
              snippet: signalement['description'] ?? "Pas de description",
            ),
          ));
        }

        setState(() {
          _markers.addAll(newMarkers);
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des signalements : $e");
    }
  }

  void _onSearchChanged() async {
    if (_searchController.text.isNotEmpty) {
      var result = await _googlePlace.autocomplete.get(_searchController.text);
      if (result != null && result.predictions != null) {
        setState(() {
          _predictions = result.predictions!;
        });
      }
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  void _selectPrediction(AutocompletePrediction prediction) async {
    final placeId = prediction.placeId;
    if (placeId != null) {
      final details = await _googlePlace.details.get(placeId);
      final location = details?.result?.geometry?.location;
      if (location != null) {
        final latLng = LatLng(location.lat!, location.lng!);
        _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
        _searchController.text = prediction.description ?? '';
        setState(() {
          _predictions = [];
        });
        _lastSelectedPrediction = prediction;
        await _showRoute(latLng);
      }
    }
  }

  Future<void> _showRoute(LatLng destination) async {
    if (_currentPosition == null) return;
    final origin = '${_currentPosition!.latitude},${_currentPosition!.longitude}';
    final dest = '${destination.latitude},${destination.longitude}';
    final avoid = _avoidTolls ? "&avoid=tolls" : "";
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&alternatives=true$avoid&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];
      if (routes != null && routes.isNotEmpty) {
        setState(() {
          _polylines.clear();
          _markers.removeWhere((m) => m.markerId.value.startsWith("duration_"));
        });
        for (int i = 0; i < routes.length; i++) {
          final route = routes[i];
          final points = route['overview_polyline']['points'];
          final decodedPoints = _decodePolyline(points);
          final duration = route['legs'][0]['duration']['text'];
          final color = (i == 0) ? Colors.blue : Colors.purple;
          setState(() {
            _polylines.add(Polyline(
              polylineId: PolylineId("route_$i"),
              points: decodedPoints,
              color: color,
              width: 6,
              onTap: () async {
                await _showRoute(destination);
              },
            ));
            _markers.add(Marker(
              markerId: MarkerId("duration_$i"),
              position: decodedPoints.last,
              icon: BitmapDescriptor.defaultMarkerWithHue((i == 0)
                  ? BitmapDescriptor.hueAzure
                  : BitmapDescriptor.hueViolet),
              infoWindow: InfoWindow(
                title: "Itinéraire ${i + 1}",
                snippet: "Durée : $duration",
              ),
            ));
          });
        }
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  @override
  Widget build(BuildContext context) {

    if (_currentPosition == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Champ de départ (rempli automatiquement avec la position actuelle)
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: TextEditingController(text: "Ma position actuelle"),
                    enabled: false, // tu peux le mettre à true si tu veux le modifier
                    decoration: InputDecoration(
                      hintText: "Départ",
                      border: InputBorder.none,
                      icon: Icon(Icons.my_location, color: Colors.green),
                    ),
                  ),
                ),

                // Champ de destination (autocomplétion active)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Où va-t-on ? (destination)",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),

                // Bouton éviter les péages
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: _avoidTolls,
                      onChanged: (value) {
                        setState(() {
                          _avoidTolls = value;
                          if (_searchController.text.isNotEmpty && _predictions.isEmpty) {
                            // recalculer l’itinéraire si une destination est déjà sélectionnée
                            _selectPrediction(_lastSelectedPrediction!);
                          }
                        });
                      },
                      activeColor: Colors.amber,
                    ),
                    Text("Éviter les péages", style: TextStyle(fontSize: 16)),
                  ],
                ),

                // Suggestions d'autocomplétion
                if (_predictions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: _predictions.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final p = _predictions[index];
                        return ListTile(
                          title: Text(p.description ?? ''),
                          onTap: () {
                            _lastSelectedPrediction = p; // pour recalcul si switch
                            _selectPrediction(p);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignalementPage(
                latitude: _currentPosition!.latitude,
                longitude: _currentPosition!.longitude,
              ),
            ),
          );

          await fetchSignalements();
        },
        backgroundColor: Colors.amber,
        child: Icon(Icons.report_problem, color: Colors.white),
        tooltip: "Signaler un incident",
      ),
    );
  }
}
