import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Place {
  final String description;
  final LatLng location;
  final Uint8List? picture;

  Place({
    required this.description,
    required this.location,
    this.picture,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'location': {'latitude': location.latitude, 'longitude': location.longitude},
      'picture': picture != null ? base64Encode(picture!) : null,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      description: json['description'],
      location: LatLng(
        json['location']['latitude'],
        json['location']['longitude'],
      ),
      picture: json['picture'] != null ? base64Decode(json['picture']) : null,
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  late Position _currentPosition;
  late LatLng _currentLocation;
  String apiKey = 'AIzaSyDx2O9MJTCow4e7ROyoTWLMGZg5JML7XXQ'; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    _currentLocation = LatLng(0, 0); // Initialize with a default location
    _getCurrentLocation();
    _loadPlaces();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _addPlace() async {
    final description = TextEditingController();
    LatLng? selectedLocation;
    Uint8List? picture;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Place'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: description,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationSelectionScreen(),
                    ),
                  );
                  selectedLocation = result;
                  Navigator.of(context).pop();
                },
                child: Text('Select Location'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Implement image selection logic here
                  Navigator.of(context).pop();
                },
                child: Text('Select Picture'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPlace = Place(
                  description: description.text,
                  location: selectedLocation ?? _currentLocation,
                  picture: picture,
                );
                _savePlace(newPlace);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _savePlace(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final places = await _getSavedPlaces();
    places.add(place);
    final placesJson = places.map((place) => place.toJson()).toList();
    await prefs.setString('places', jsonEncode(placesJson));
    _loadPlaces();
  }

  Future<List<Place>> _getSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = prefs.getString('places');
    if (placesJson != null) {
      final placesList = jsonDecode(placesJson) as List<dynamic>;
      return placesList.map((json) => Place.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  void _loadPlaces() async {
    final places = await _getSavedPlaces();
    setState(() {
      _markers.clear();
      for (var place in places) {
        _markers.add(
          Marker(
            markerId: MarkerId(place.location.toString()),
            position: place.location,
            infoWindow: InfoWindow(title: place.description),
            onTap: () {
              _mapController.animateCamera(
                CameraUpdate.newLatLng(place.location),
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              markers: _markers,
            ),
          ),
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Place>>(
              future: _getSavedPlaces(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final places = snapshot.data!;
                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return GestureDetector(
                        onLongPress: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Update/Delete Place'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(place.description),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Update place logic
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Update'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Delete place logic
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: MemoryImage(place.picture ?? Uint8List(0)),
                            ),
                            title: Text(place.description),
                            onTap: () {
                              _mapController.animateCamera(
                                CameraUpdate.newLatLng(place.location),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlace,
        child: Icon(Icons.add),
      ),
    );
  }
}

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation = LatLng(0, 0); // Initialize with default value

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: Set<Marker>.from([
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation,
          ),
        ]),
      ),
    );
  }
}
