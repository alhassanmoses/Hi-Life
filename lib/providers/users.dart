import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

import '../models/user.dart';

class Users with ChangeNotifier {
  final _firestore = Firestore.instance;
  List<CUserData> _cUserData = [];
  List<HpUserData> _hpUserData = [];

  List<CUserData> get cUserData {
    return [..._cUserData];
  }

  List<HpUserData> get hpUserData {
    return [..._hpUserData];
  }

  Future<String> _uploadProfileImage(File image, userId) async {
    String fileName = basename(image.path);
//    print('filename is $fileName');
    StorageReference firebaseStorageReference = FirebaseStorage.instance
        .ref()
        .child(
            'profilePictures/$userId${fileName.substring(fileName.indexOf('.'))}');
    StorageUploadTask uploadTask = firebaseStorageReference.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<bool> addUser({
    bool isHp,
    String email,
    String fname,
    String lname,
    String profession,
    int experience,
    String address,
    String shortDescription,
    int age,
    String sex,
    String userId,
    File image,
  }) async {
    try {
      String pictureUrl = await _uploadProfileImage(image, userId);
//      print('image url is: $imageUrl');
      if (isHp) {
        await _firestore.collection('HpUserData').document(userId).setData({
          'email': email,
          'fname': fname,
          'lname': lname,
          'profession': profession,
          'shortDescription': shortDescription,
          'experience': experience,
          'address': address,
          'age': age,
          'sex': sex,
          'userId': userId,
          'pictureUrl': pictureUrl,
        });
        final HpUserData newUser = HpUserData(
          email: email,
          fname: fname,
          lname: lname,
          profession: profession,
          shortDescription: shortDescription,
          experience: experience,
          address: address,
          age: age,
          sex: sex,
          userId: userId,
          pictureUrl: pictureUrl,
        );
        _hpUserData.add(newUser);
      } else {
        await _firestore.collection('CUserData').document(userId).setData({
          'email': email,
          'fname': fname,
          'lname': lname,
          'address': address,
          'age': age,
          'sex': sex,
          'userId': userId,
          'pictureUrl': pictureUrl,
        });

        final CUserData newUser = CUserData(
          email: email,
          fname: fname,
          lname: lname,
          address: address,
          age: age,
          sex: sex,
          userId: userId,
          pictureUrl: pictureUrl,
        );
        _cUserData.add(newUser);
      }
    } catch (e) {
      print(e);
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> fetchUsers(bool isHp) async {
    if (isHp) {
      List<CUserData> recievedUserData = [];
      final users = await _firestore.collection('CUserData').getDocuments();
      for (var user in users.documents) {
        recievedUserData.add(
          CUserData(
            email: user.data['email'],
            fname: user.data['fname'],
            lname: user.data['lname'],
            address: user.data['address'],
            age: user.data['age'],
            sex: user.data['sex'],
            userId: user.data['userId'],
            pictureUrl: user.data['pictureUrl'],
          ),
        );
      }
      _cUserData = recievedUserData;
    } else {
      List<HpUserData> recievedUserData = [];
      final users = await _firestore.collection('HpUserData').getDocuments();

      for (var user in users.documents) {
        recievedUserData.add(
          HpUserData(
            email: user.data['email'],
            fname: user.data['fname'],
            lname: user.data['lname'],
            address: user.data['address'],
            age: user.data['age'],
            sex: user.data['sex'],
            profession: user.data['profession'],
            experience: user.data['experience'],
            shortDescription: user.data['shortDescription'],
            userId: user.data['userId'],
            pictureUrl: user.data['pictureUrl'],
          ),
        );
      }
      _hpUserData = recievedUserData;
    }
    notifyListeners();
  }

  Future<void> rateHp(int rating, String hpUid) async {
    final int rat = rating;

    int five = 0;
    int four = 0;
    int three = 0;
    int two = 0;
    int one = 0;
    int zero = 0;
    int total;
    int reviewers = 0;
    await _firestore
        .collection('HpUserData')
        .document(hpUid)
        .get()
        .then((value) {
      if (value.data['rating'] == null ? false : true) {
        five = value.data['rating']['five'];
        four = value.data['rating']['four'];
        three = value.data['rating']['three'];
        two = value.data['rating']['two'];
        one = value.data['rating']['one'];
        zero = value.data['rating']['zero'];
        reviewers = value.data['rating']['reviewers'];
      }
    });
    switch (rat) {
      case 5:
        {
          reviewers += 1;
          five += 1;
          break;
        }
      case 4:
        {
          reviewers += 1;
          four += 1;
          break;
        }
      case 3:
        {
          reviewers += 1;
          three += 1;
          break;
        }
      case 2:
        {
          reviewers += 1;
          two += 1;
          break;
        }
      case 1:
        {
          one += 1;
          reviewers += 1;
          break;
        }
      case 0:
        {
          reviewers += 1;
          zero += 1;
          break;
        }
      default:
        {
          break;
        }
    }
    total = (5 * five) + (4 * four) + (3 * three) + (2 * two) + (1 * one);
    final averageRating = total / reviewers;

    _firestore.collection('HpUserData').document(hpUid).setData({
      'rating': {
        'five': five,
        'four': four,
        'three': three,
        'two': two,
        'one': one,
        'zero': zero,
        'total': total,
        'rated': averageRating.toStringAsFixed(2),
        'reviewers': reviewers,
      }
    }, merge: true);
  }
}
