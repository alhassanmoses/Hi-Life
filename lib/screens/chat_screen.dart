import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/create_appointment_screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../utilities/location_utility.dart';
import '../screens/map_screen.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../widgets/full_photo.dart';
import '../constants.dart';
import '../providers/auth.dart';
import '../widgets/location_input.dart';
import '../providers/users.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final bool isHp;
  final String currentAvatar;
  final String currentId;
  final String currentName;
  final String peerName;

  const ChatScreen({
    Key key,
    this.peerId,
    this.peerAvatar,
    this.isHp,
    this.currentId,
    @required this.currentAvatar,
    @required this.currentName,
    @required this.peerName,
  }) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int count = 0;
  String consultationId;
  bool isLoading;
  bool showMapPreview = false;
  bool hasRated;
  bool _keyboardState = false;

  String imageUrl;
  var listMessage;
  TextEditingController messageTextController = TextEditingController();
  String messageText;
  File imageFile;
  Map appointmentData;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(onFocusChange);
    KeyboardVisibility.onChange.listen((bool visible) {
      keyboardChanged(visible);
    });
    consultationId = '';
    isLoading = false;
    imageUrl = '';

    getMeta();
    super.initState();
  }

  void keyboardChanged(bool visible) {
    setState(() {
      _keyboardState = visible;
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker and mini map when keyboard appears
      setState(() {
//        isShowSticker = false;
        showMapPreview = false;
      });
    }
  }

  getMeta() async {
    //get chat route to access in db for current chat

    if (widget.currentId == null) {
      Navigator.pushReplacementNamed(context, '/');
      Provider.of<Auth>(context, listen: false).signOut();
    }
    if (!widget.isHp) {
      consultationId = '${widget.currentId}_${widget.peerId}';
    } else {
      consultationId = '${widget.peerId}_${widget.currentId}';
    }
    //update the list of people both individuals have had a chat with
  }

  //commit rating to db
  Future<void> rate(int starNum) async {
    try {
      await Provider.of<Users>(context, listen: false).rateHp(
        rating: starNum,
        rater: widget.currentId,
        rated: widget.peerId,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Sorry, rating failed, try again');
      print('Error at chat screen rating: $e');
    }
  }

  //callback when back icon is pressed
  void resumeChat() {
    setState(() {
      showMapPreview = !showMapPreview;
    });
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
//      isShowSticker = !isShowSticker;
    });
  }

//  void getMiniMap() {
//    focusNode.unfocus();
//    setState(() {
////      isShowMiniMap =!isShowMiniMap;
//    });
//  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Widget showMedia({
    Function onPressed,
    String imageUrl,
    int index,
    @required bool isMap,
    @required bool isAppointment,
    margin,
    Map otherData,
  }) {
    var tempStart;
    var tempEnd;
    if (isAppointment) {
      tempStart = otherData['startTime'].toDate();
      tempEnd = otherData['endTime'].toDate();
    }

    return Container(
      child: Column(
        children: <Widget>[
          FlatButton(
            child: Material(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                      width: 200.0,
                      height: 200.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: greyColor2,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Material(
                      child: Image.asset(
                        'assets/images/img_not_available.jpeg',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: imageUrl,
                    width: (isMap || isAppointment) ? 300 : 200.0,
                    height: (isMap || isAppointment) ? 180 : 200.0,
                    fit: BoxFit.cover,
                  ),
                  if (isAppointment || isMap)
                    Positioned(
                      bottom: 0,
                      child: Container(
//                      color: Colors.transparent,
                        width: 300,
                        height: 20,
                        color: Colors.black26,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, bottom: 2),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              isMap
                                  ? otherData['address']
                                  : 'Meet at \'A\': ${otherData['address']}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
//                  if (isAppointment || isMap)
//                    Positioned(
//                      bottom: 0,
//                      child: Container(
//                        height: 20,
//                        width: 300,
//                        color: Colors.black26,
//                        child: (isMap)
//                            ? Center(
//                                child: Text(
//                                  otherData['address'],
//                                  overflow: TextOverflow.ellipsis,
//                                  style: TextStyle(fontWeight: FontWeight.bold),
//                                ),
//                              )
//                            : null,
//                      ),
//                    ),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            onPressed: onPressed,
            padding: EdgeInsets.all(0),
          ),
          if (isAppointment)
            Card(
              elevation: 8,
              child: Container(
                width: 300,
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Appointment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    image: DecorationImage(
                                        image: NetworkImage(widget.peerAvatar),
                                        fit: BoxFit.scaleDown)),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 100,
                              height: 60,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: RichText(
                                      overflow: TextOverflow.fade,
                                      text: TextSpan(
                                          text: otherData['title'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' with:',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 12,
                                                color: Colors.black38,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 20,
                                    child: Text(
                                      widget.isHp
                                          ? widget.currentName
                                          : widget.peerName,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.black38),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  'Note:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  width: 100,
                                  height: 50,
                                  child: Text(
                                    otherData['note'],
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'On: ${DateFormat.yMMMd().add_jm().format(tempStart)}',
                                style: TextStyle(fontSize: 9),
                              )
                            ],
                          ),
                        ),
                        if (otherData['isAllDay'] == false)
                          SizedBox(
                            height: 5,
                          ),
                        if (otherData['isAllDay'] == false)
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'To: ${DateFormat.yMMMd().add_jm().format(tempEnd)}',
                                  style: TextStyle(fontSize: 8),
                                )
                              ],
                            ),
                          ),
                        if (!widget.isHp)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              if (otherData['isAccepted'] == true)
                                RaisedButton(
                                  color: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('Accepted'),
                                  onPressed: null,
                                ),
                              if (otherData['isAccepted'] == false)
                                AcceptButton(
                                  consultationId: consultationId,
                                  data: otherData,
                                ),
                              if (otherData['isDeclined'] == true)
                                RaisedButton(
                                  color: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('Declined'),
                                  onPressed: null,
                                ),
                              if (otherData['isDeclined'] == false)
                                DeclineButton(
                                    consultationId: consultationId,
                                    data: otherData),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      margin: margin,
    );
  }

  void onSendAppointment(Map appData) {
    onSendMessage('Appointment', 3, {
      'appId': appData['appId'],
      'title': appData['title'],
      'isAllDay': appData['isAllDay'],
      'startTime': appData['startTime'],
      'endTime': appData['endTime'],
      'note': appData['note'],
      'isAccepted': false,
      'isDeclined': false,
      'address': appData['address'],
      'latitude': appData['latitude'],
      'longitude': appData['longitude'],
      'timezone': appData['timezone'],
    });
  }

  void onSendMapView(Map locData) {
    if (locData.isEmpty) {
      Fluttertoast.showToast(msg: 'Select a location');
    } else {
      onSendMessage(
        'map',
        2,
        {
          'latitude': locData['latitude'],
          'longitude': locData['longitude'],
          'address': locData['address'],
        },
      );
    }
  }

  void onSendMessage(String content, int type, [Map otherData]) {
    // type: 0 = text, 1 = image, 2 = map Coordinates

    if (content.trim() != '') {
      if (count == 0) {
        count++;
        Firestore.instance
            .collection(widget.isHp ? 'HpUserData' : 'CUserData')
            ?.document(widget.currentId)
            ?.updateData({
          'consulted': FieldValue.arrayUnion([consultationId])
        });
        Firestore.instance
            .collection(widget.isHp ? 'CUserData' : 'HpUserData')
            ?.document(widget.peerId)
            ?.updateData({
          'consulted': FieldValue.arrayUnion([consultationId])
        });
      }

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      messageTextController.clear();
      var documentReference = Firestore.instance
          .collection('ConsultationData')
          .document(consultationId)
          .collection(consultationId)
          .document(timestamp);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          type == 2
              ? {
                  'idFrom': widget.currentId,
                  'idTo': widget.peerId,
                  'timestamp': timestamp,
                  'content': content,
                  'type': type,
                  'latitude': otherData['latitude'],
                  'longitude': otherData['longitude'],
                  'address': otherData['address'],
                }
              : type == 3
                  ? {
                      'idFrom': widget.currentId,
                      'idTo': widget.peerId,
                      'timestamp': timestamp,
                      'content': content,
                      'type': type,
                      'latitude': otherData['latitude'],
                      'longitude': otherData['longitude'],
                      'address': otherData['address'],
                      'appId': otherData['appId'],
                      'title': otherData['title'],
                      'isAllDay': otherData['isAllDay'],
                      'isAccepted': otherData['isAccepted'],
                      'isDeclined': otherData['isDeclined'],
                      'startTime': otherData['startTime'],
                      'endTime': otherData['endTime'],
                      'note': otherData['note'],
                      'timezone': otherData['timezone'],
                    }
                  : {
                      'idFrom': widget.currentId,
                      'idTo': widget.peerId,
                      'timestamp': timestamp,
                      'content': content,
                      'type': type,
                    },
        );
      });
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildRateButton(int num) {
    return RaisedButton.icon(
      color: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      icon: Icon(
        (num == 0)
            ? Icons.star_border
            : (num <= 3) ? Icons.star_half : Icons.star,
        color: Colors.yellow,
      ),
      label: Text(num.toString()),
      onPressed: () async {
        await rate(num);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  void callRatingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                color: Colors.orange,
                child: Text(
                  'Later',
                  style: TextStyle(fontFamily: 'Piedra'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Text(
            '''Please leave a rating for this healthcare professional for others to see...
            
Note: you can only rate this person once''',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              direction: Axis.horizontal,
              spacing: 10,
              children: <Widget>[
                buildRateButton(5),
                buildRateButton(4),
                buildRateButton(3),
                buildRateButton(2),
                buildRateButton(1),
                buildRateButton(0),
              ],
            ),
          ],
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == widget.currentId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 1
                  // Image
                  ? showMedia(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(url: document['content'])));
                      },
                      imageUrl: document['content'],
                      index: index,
                      isMap: false,
                      isAppointment: false,
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0))
                  // map
                  : document['type'] == 2
                      ? Container(
                          child: showMedia(
                            otherData: document.data,
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                          initialLocation: {
                                            'latitude': document['latitude'],
                                            'longitude': document['longitude'],
                                          },
                                          isSelecting: false,
                                        ))),
                            imageUrl:
                                LocationUtility.generateLocationPreviewImage(
                              latitude: document['latitude'],
                              longitude: document['longitude'],
                            ),
                            index: index,
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                            isMap: true,
                            isAppointment: false,
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),
                        )
                      : Container(
                          child: showMedia(
                            otherData: document.data,
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapScreen(
                                          initialLocation: {
                                            'latitude': document['latitude'],
                                            'longitude': document['longitude'],
                                          },
                                          isSelecting: false,
                                        ))),
                            imageUrl:
                                LocationUtility.generateLocationPreviewImage(
                              latitude: document['latitude'],
                              longitude: document['longitude'],
                            ),
                            index: index,
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                            isMap: false,
                            isAppointment: true,
                          ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),
                        ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: widget.peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? showMedia(
                            isMap: false,
                            isAppointment: false,
                            margin: EdgeInsets.only(left: 10.0),
                            index: index,
                            imageUrl: document['content'],
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FullPhoto(url: document['content'])));
                            },
                          )
                        : document['type'] == 2
                            ? Container(
                                child: showMedia(
                                  otherData: document.data,
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                                initialLocation: {
                                                  'latitude':
                                                      document['latitude'],
                                                  'longitude':
                                                      document['longitude'],
                                                },
                                                isSelecting: false,
                                              ))),
                                  imageUrl: LocationUtility
                                      .generateLocationPreviewImage(
                                    latitude: document['latitude'],
                                    longitude: document['longitude'],
                                  ),
                                  index: index,
                                  margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 20.0
                                          : 10.0,
                                      right: 10.0),
                                  isMap: true,
                                  isAppointment: false,
                                ),
                                margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 20.0 : 10.0,
                                    right: 10.0),
                              )
                            : Container(
                                child: showMedia(
                                  otherData: document.data,
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                                initialLocation: {
                                                  'latitude':
                                                      document['latitude'],
                                                  'longitude':
                                                      document['longitude'],
                                                },
                                                isSelecting: false,
                                              ))),
                                  imageUrl: LocationUtility
                                      .generateLocationPreviewImage(
                                    latitude: document['latitude'],
                                    longitude: document['longitude'],
                                  ),
                                  index: index,
                                  margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 20.0
                                          : 10.0,
                                      right: 10.0),
                                  isMap: false,
                                  isAppointment: true,
                                ),
                                margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 20.0 : 10.0,
                                    right: 10.0),
                              ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == widget.currentId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != widget.currentId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showMapPreview) {
          setState(() {
            showMapPreview = false;
          });
          return Future.value(false);
        } else if (!widget.isHp) {
          await Firestore.instance
              .collection('HpUserData')
              .document(widget.peerId)
              .collection('RatingData')
              .document('Rating')
              .get()
              .then((value) async {
            if (!value.exists) {
              callRatingDialog();
            } else {
              bool hasRated = false;
              await Firestore.instance
                  .collection('HpUserData')
                  .document(widget.peerId)
                  .collection('RatingData')
                  .document('Raters')
                  .get()
                  .then((value) {
                hasRated = value.data[widget.currentId] == null ? false : true;
                if (!hasRated) {
                  callRatingDialog();
                }
                Navigator.of(context).pop();
              });
            }
          });

          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.peerName,
            style: TextStyle(fontFamily: 'ChelseaMarket'),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: isLoading
              ? Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    StreamBuilder(
                      stream: Firestore.instance
                              .collection('ConsultationData')
                              ?.document(consultationId)
                              ?.collection(consultationId)
                              ?.orderBy('timestamp', descending: true)
                              ?.limit(20)
                              ?.snapshots() ??
                          ConnectionState.waiting,
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Expanded(
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.black38,
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return Container(
                            child: Center(
                              child: Text(
                                'Type something',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 20),
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          listMessage = snapshot.data.documents;
                          return Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) => buildItem(
                                  index, snapshot.data.documents[index]),
                              reverse: true,
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Container(
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                    if (showMapPreview)
                      LocationInput(
                        resumeChat: resumeChat,
                        onSendMapView: onSendMapView,
                      ),
                    if (!showMapPreview)
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: <Widget>[
                            if (widget.isHp && !_keyboardState)
                              IconButton(
                                icon: Icon(Icons.timer),
                                color: primaryColor,
                                onPressed: () async {
                                  appointmentData = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) =>
                                              AppointmentScreen()));
//                                  print('the appointment is $appointmentData');
                                  if (appointmentData['latitude'] == null ||
                                      appointmentData['longitude'] == null) {
                                    return;
                                  } else {
                                    onSendAppointment(appointmentData);
                                  }
                                },
                              ),
                            if (!_keyboardState)
                              IconButton(
                                icon: Icon(Icons.image),
                                color: primaryColor,
                                onPressed: getImage,
                              ),
                            if (!_keyboardState)
                              IconButton(
                                icon: Icon(Icons.location_on),
                                color: primaryColor,
                                onPressed: () {
                                  //hides keyboard before showing map preview
                                  focusNode.unfocus();
                                  setState(() {
                                    showMapPreview = true;
                                  });
                                },
                              ),
                            Expanded(
                              child: TextField(
                                controller: messageTextController,
                                cursorColor: primaryColor,
                                style: TextStyle(
                                    color: primaryColor, fontSize: 15),
                                decoration: kTextFieldDecoration,
                                focusNode: focusNode,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              color: primaryColor,
                              onPressed: () {
                                onSendMessage(messageTextController.text, 0);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AcceptButton extends StatelessWidget {
  const AcceptButton({
    Key key,
    @required this.consultationId,
    this.data,
  }) : super(key: key);

  final String consultationId;
  final Map data;

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () async {
        try {
          await Firestore.instance
              .collection('AppointmentData')
              .document(data['appId'])
              .setData(data)
              .then(
            (value) async {
              await Firestore.instance
                  .collection('ConsultationData')
                  .document(consultationId)
                  .collection(consultationId)
                  .document(data['timestamp'])
                  .updateData({
                'isAccepted': true,
              }).then((value) {
                print('success');
              });
              Fluttertoast.showToast(msg: 'Appointment created');
            },
          );
        } catch (e) {
          Fluttertoast.showToast(
              msg: 'Appointment creation unsuccessful, please try again!',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG);
        }
      },
      icon: Icon(
        Icons.check_circle,
        color: Colors.orange,
      ),
      label: Text('Accept'),
    );
  }
}

class DeclineButton extends StatelessWidget {
  const DeclineButton({Key key, @required this.consultationId, this.data})
      : super(key: key);

  final String consultationId;
  final Map data;

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () async {
        try {
          await Firestore.instance
              .collection('AppointmentData')
              .document(data['appId'])
              .setData(data)
              .then(
            (value) async {
              await Firestore.instance
                  .collection('ConsultationData')
                  .document(consultationId)
                  .collection(consultationId)
                  .document(data['timestamp'])
                  .updateData({
                'isDeclined': true,
              });
              Fluttertoast.showToast(msg: 'Appointment declined');
            },
          );
        } catch (e) {
          Fluttertoast.showToast(
              msg: 'Appointment declination unsuccessful, please try again!',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_LONG);
        }
      },
      icon: Icon(
        Icons.cancel,
        color: Colors.orange,
      ),
      label: Text('Decline'),
    );
  }
}
