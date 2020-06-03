import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:location/location.dart';

import '../screens/map_screen.dart';
import '../utilities/location_utility.dart';
import '../constants.dart';

class AppointmentScreen extends StatefulWidget {
  static const pageRoute = '/appointment_screen';
  final Function sendAppointment;

  const AppointmentScreen({Key key, this.sendAppointment}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  TextEditingController note = TextEditingController();
  TextEditingController title = TextEditingController();
  bool _isAllDay = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  String currentTimeZone = DateTime.now().timeZoneName;
  String address = '';
  int appId = Random().nextInt(999999);
//  Color _selectedColor = Colors.orange;
//  List<String> _timeZoneCollection;
//  int _selectedTimeZoneIndex = 0;
  String _previewImageUrl;
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  Map<String, double> locationData = {
    'latitude': null,
    'longitude': null,
  };

  Future<void> getAddress(double lat, double long) async {
    address = await LocationUtility.getLocationAddress(lat, long);
  }

  Future<void> _selectFromMap() async {
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
    locationData['latitude'] = selectedLocation.latitude;
    locationData['longitude'] = selectedLocation.longitude;
    getAddress(selectedLocation.latitude, selectedLocation.longitude);
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);
  }

  void _showPreview(double lat, double lng) {
    final staticMapImageUrl = LocationUtility.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );
    setState(() => _previewImageUrl = staticMapImageUrl);
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
    locationData['latitude'] = _locationData.latitude;
    locationData['longitude'] = _locationData.longitude;
    await getAddress(_locationData.latitude, _locationData.longitude);
    _showPreview(_locationData.latitude, _locationData.longitude);
  }

  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: title,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add title',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(
                  Icons.access_time,
                  color: Colors.black54,
                ),
                title: Row(children: <Widget>[
                  const Expanded(
                    child: Text('All-day'),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _isAllDay,
                            onChanged: (bool value) {
                              setState(() {
                                _isAllDay = value;
                              });
                            },
                          ))),
                ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                                DateFormat('EEE, MMM dd yyyy')
                                    .format(_startDate),
                                textAlign: TextAlign.left),
                            onTap: () async {
                              final DateTime date =
                                  await DatePicker.showDatePicker(
                                context,
                                showTitleActions: true,
                                minTime: DateTime(1900),
                                maxTime: DateTime(2100),
                                currentTime: _startDate,
                              );
                              print('Date is ${date.toString()}');

                              if (date != null && date != _startDate) {
                                setState(() {
                                  final Duration difference =
                                      _endDate.difference(_startDate);
                                  _startDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      _startTime.hour,
                                      _startTime.minute,
                                      0);
                                  _endDate = _startDate.add(difference);
                                  _endTime = TimeOfDay(
                                      hour: _endDate.hour,
                                      minute: _endDate.minute);
                                });
                              }
                            }),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay
                              ? const Text('')
                              : GestureDetector(
                                  child: Text(
                                    DateFormat('hh:mm a').format(_startDate),
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () async {
                                    final DateTime temp =
                                        await DatePicker.showTime12hPicker(
                                      context,
                                      showTitleActions: true,
                                      currentTime: DateTime(
                                          _startDate.year,
                                          _startDate.month,
                                          _startDate.day,
                                          _startDate.hour,
                                          _startDate.minute,
                                          0),
                                    );
                                    final TimeOfDay time = TimeOfDay(
                                        hour: temp.hour, minute: temp.minute);

                                    if (time != null && time != _startTime) {
                                      setState(() {
                                        _startTime = time;
                                        final Duration difference =
                                            _endDate.difference(_startDate);
                                        _startDate = DateTime(
                                            _startDate.year,
                                            _startDate.month,
                                            _startDate.day,
                                            _startTime.hour,
                                            _startTime.minute,
                                            0);
                                        _endDate = _startDate.add(difference);
                                        _endTime = TimeOfDay(
                                            hour: _endDate.hour,
                                            minute: _endDate.minute);
                                      });
                                    }
                                  })),
                    ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                              DateFormat('EEE, MMM dd yyyy').format(_endDate),
                              textAlign: TextAlign.left,
                            ),
                            onTap: () async {
                              final DateTime date =
                                  await DatePicker.showDatePicker(
                                context,
                                showTitleActions: true,
                                minTime: DateTime(1900),
                                maxTime: DateTime(2100),
                                currentTime: _endDate,
                              );

                              if (date != null && date != _endDate) {
                                setState(() {
                                  final Duration difference =
                                      _endDate.difference(_startDate);
                                  _endDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      _endTime.hour,
                                      _endTime.minute,
                                      0);
                                  if (_endDate.isBefore(_startDate)) {
                                    _startDate = _endDate.subtract(difference);
                                    _startTime = TimeOfDay(
                                        hour: _startDate.hour,
                                        minute: _startDate.minute);
                                  }
                                });
                              }
                            }),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay
                              ? const Text('')
                              : GestureDetector(
                                  child: Text(
                                    DateFormat('hh:mm a').format(_endDate),
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () async {
                                    final DateTime temp =
                                        await DatePicker.showTime12hPicker(
                                      context,
                                      showTitleActions: true,
                                      currentTime: DateTime(
                                          _endDate.year,
                                          _endDate.month,
                                          _endDate.day,
                                          _endDate.hour,
                                          _endDate.minute,
                                          0),
                                    );
                                    final TimeOfDay time = TimeOfDay(
                                        hour: temp.hour, minute: temp.minute);

                                    if (time != null && time != _endTime) {
                                      setState(() {
                                        _endTime = time;
                                        final Duration difference =
                                            _endDate.difference(_startDate);
                                        _endDate = DateTime(
                                            _endDate.year,
                                            _endDate.month,
                                            _endDate.day,
                                            _endTime.hour,
                                            _endTime.minute,
                                            0);
                                        if (_endDate.isBefore(_startDate)) {
                                          _startDate =
                                              _endDate.subtract(difference);
                                          _startTime = TimeOfDay(
                                              hour: _startDate.hour,
                                              minute: _startDate.minute);
                                        }
                                      });
                                    }
                                  })),
                    ])),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.public,
                color: Colors.black87,
              ),
              title: Text(currentTimeZone.toString()),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    //was just added
                    Navigator.of(context).pop();
                    /*return _TimeZonePicker();*/ return;
                  },
                ).then((dynamic value) => setState(() {}));
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
//            ListTile(
//              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
//              leading: Icon(Icons.lens, color: _selectedColor),
//              title: Text(
//                'yellow',
//              ),
//              onTap: () {
//                showDialog<Widget>(
//                  context: context,
//                  barrierDismissible: true,
//                  builder: (BuildContext context) {
//                    /*return _ColorPicker();*/
//                    //just added this
//                    Navigator.of(context).pop();
//                    return;
//                  },
//                ).then((dynamic value) => setState(() {}));
//              },
//            ),
//            const Divider(
//              height: 1.0,
//              thickness: 1,
//            ),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: Icon(
                Icons.subject,
                color: Colors.black87,
              ),
              title: TextField(
                controller: note,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add description',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    height: 200.0,
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
                                  image: AssetImage(
                                      'assets/images/question_mark.png'),
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
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
                      RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        textColor: primaryColor,
                        icon: Icon(Icons.my_location),
                        label: Text('Get'),
                        onPressed: _getCurrentLocation,
                      ),
                      RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        textColor: primaryColor,
                        icon: Icon(Icons.map),
                        label: Text('Map'),
                        onPressed: _selectFromMap,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment',
        ),
        leading: IconButton(
          icon: Icon(Icons.cancel, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Stack(
          children: <Widget>[
            _getAppointmentEditor(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Text('Create Appointment'),
                    content: Text('Send client this appointment..?'),
                    actions: <Widget>[
                      FlatButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.reply,
                          color: Colors.orange,
                        ),
                        label: Text('Chat'),
                      ),
                      FlatButton.icon(
                        onPressed: () {
                          if (title.text.isEmpty || note.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: 'Please provide a title and note');
                            Navigator.of(context).pop();
                            return;
                          } else if (locationData['latitude'] == null ||
                              locationData['longitude'] == null) {
                            Fluttertoast.showToast(
                              msg:
                                  'Please use the \'Get\' button to choose current location or select a location using the \'Map\' button',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                            );
                            Navigator.of(context).pop();
                            return;
                          } else {
                            Navigator.of(context).pop();
                            Navigator.pop(context, {
                              'latitude': locationData['latitude'],
                              'longitude': locationData['longitude'],
                              'appId': appId,
                              'title': title.text,
                              'isAllDay': _isAllDay,
                              'startTime': _startDate,
                              'endTime': _endDate,
                              'note': note.text,
                              'address': address,
                              'timezone': currentTimeZone,
                            });
                          }
                        },
                        icon: Icon(Icons.check_circle),
                        label: Text('Yes'),
                      ),
                      FlatButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.cancel),
                        label: Text('No'),
                      ),
                    ],
                  ));
        },
      ),
    );
  }
}
