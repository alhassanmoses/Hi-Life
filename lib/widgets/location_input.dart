import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../utilities/location_utility.dart';
import '../screens/map_screen.dart';
import '../constants.dart';

class LocationInput extends StatefulWidget {
  final Function resumeChat;
  final Function onSendMapView;

  LocationInput({
    this.resumeChat,
    this.onSendMapView,
  });
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Map<String, double> locationData = {
    'latitude': 0.0,
    'longitude': 0.0,
  };
  String address = '';

  Future<void> getAddress(double lat, double long) async {
    address = await LocationUtility.getLocationAddress(lat, long);
  }

  Future<void> _getCurrentLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    await getAddress(_locationData.latitude, _locationData.longitude);
    locationData['latitude'] = _locationData.latitude;
    locationData['longitude'] = _locationData.longitude;
    _showPreview(_locationData.latitude, _locationData.longitude);
  }

  Future<void> _selectFromMap() async {
//    final LatLng selectedLocation = await Navigator.of(context).push(
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }

    getAddress(selectedLocation.latitude, selectedLocation.longitude);
    locationData['latitude'] = selectedLocation.latitude;
    locationData['longitude'] = selectedLocation.longitude;
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);

//    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
  }

  void _showPreview(double lat, double lng) {
    final staticMapImageUrl = LocationUtility.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );
    setState(() => _previewImageUrl = staticMapImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 170.0,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: _previewImageUrl == null
                ? Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage('assets/images/question_mark.png'),
                          fit: BoxFit.scaleDown,
                        )),
                      ),
                      Positioned(
                        right: 10,
                        top: 2,
                        child: Text('hmm, nothing to show...'),
                      )
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      _previewImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.reply,
                  color: primaryColor,
                  size: 30,
                ),
                onPressed: widget.resumeChat,
              ),
              Card(
                elevation: 3,
                color: Color(0xffe0e0e0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                  color: primaryColor,
                ),
              ),
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                textColor: primaryColor,
                icon: Icon(Icons.map),
                label: Text('Map'),
                onPressed: _selectFromMap,
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  widget.onSendMapView({
                    'latitude': locationData['latitude'],
                    'longitude': locationData['longitude'],
                    'address': address,
                  });
                  widget.resumeChat();
                  print(
                      'the map details are: ${locationData['latitude']} ${locationData['longitude']} $address');
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
