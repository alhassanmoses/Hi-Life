import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> initialLocation;
  final bool isSelecting;
  final bool fromAppointment;

  MapScreen({
    this.initialLocation = const {
      'latitude': 9.4313238,
      'longitude': -0.8649909,
      'address': 'T-Poly Rd, Tamale, Ghana'
    },
    this.isSelecting = false,
    this.fromAppointment,
  });
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _selectedLocation;

  void _locationSelected(LatLng position) {
    setState(() => _selectedLocation = position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
        actions: <Widget>[
          if (widget.isSelecting)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _selectedLocation == null
                  ? null
                  : () => Navigator.of(context).pop(_selectedLocation),
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialLocation['latitude'],
              widget.initialLocation['longitude']),
          zoom: 16,
        ),
        onTap: widget.isSelecting ? _locationSelected : null,
        markers: (_selectedLocation == null && widget.isSelecting)
            ? null
            : {
                Marker(
                  markerId: MarkerId('m1'),
                  position: _selectedLocation ??
                      LatLng(widget.initialLocation['latitude'],
                          widget.initialLocation['longitude']),
                ),
              },
      ),
    );
  }
}
