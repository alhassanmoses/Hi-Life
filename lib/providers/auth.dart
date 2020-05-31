import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

//abstract class BaseAuth {
//  Future<String> signIn(String email, String password);
//
//  Future<String> signUp(String email, String password);
//
//  Future<FirebaseUser> getCurrentUser();
//
//  Future<void> sendEmailVerification();
//
//  Future<void> signOut();
//
//  Future<bool> isEmailVerified();
//}

//class Auth implements BaseAuth {

class Auth with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  HpUserData _currentHpData;
  CUserData _currentClData;
  bool _isUserHp;
  String _token = '';
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isHp {
    return _isUserHp;
  }

  bool get isAuth {
    return token != null;
  }

  HpUserData get currentHpData {
    return _currentHpData;
  }

  CUserData get currentClData {
    return _currentClData;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, bool isSignIn) async {
    AuthResult result;
    try {
      if (isSignIn) {
        result = await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        result = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);
      }

      FirebaseUser user = result.user;
      IdTokenResult idResult = await user.getIdToken();
      _token = idResult.token;
      _userId = user.uid;
      _expiryDate = idResult.expirationTime;

      await _isHp();
      await _getCurrentUserData();
      notifyListeners();
      _autoLogout();
      final shPrefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      shPrefs.setString('userData', userData);
    } catch (e) {
      var errorMessage = 'Authentication falied.';
      if (e.toString().contains('ERROR_EMAIL_ALREADY_IN_USE')) {
        errorMessage = 'This email is already in use.';
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with this email.';
      } else if (e.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        errorMessage = 'Too many attepts, please retry later.';
      } else if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email.';
      } else if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        errorMessage = 'Invalid password.';
      } else if (e.toString().contains('ERROR_WEAK_PASSWORD')) {
        errorMessage = 'Password too weak.';
      }
      print('An error occured at Auth _authenticate: $e');
      throw errorMessage;
    }
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, true);
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, false);
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    _firebaseAuth.signOut();

    notifyListeners();
    final shPrefs = await SharedPreferences.getInstance();
    shPrefs.clear();
  }

//  Future<void> sendEmailVerification() async {
//    FirebaseUser user = await _firebaseAuth.currentUser();
//    user.sendEmailVerification();
//  }

//  Future<bool> isEmailVerified() async {
//    FirebaseUser user = await _firebaseAuth.currentUser();
//    return user.isEmailVerified;
//  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeTillTokenExpiry =
        _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeTillTokenExpiry), signOut);
  }

  Future<bool> autoLogin() async {
    final shPrefs = await SharedPreferences.getInstance();
    if (!shPrefs.containsKey('userData')) {
      return false;
    }
    final savedUserData =
        json.decode(shPrefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(savedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = savedUserData['token'];
    _userId = savedUserData['userId'];
    _expiryDate = expiryDate;
    await _isHp();
    await _getCurrentUserData();
    _autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> _isHp() async {
    var doc = await _firestore.collection('HpUserData').document(userId).get();

    if (doc.data == null) {
      _isUserHp = false;
    } else if (doc.data.isNotEmpty) {
      _isUserHp = true;
    }
  }

  Future<void> _getCurrentUserData() async {
    if (isHp) {
      final user =
          await _firestore.collection('HpUserData').document(userId).get();
      _currentHpData = HpUserData(
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
      );
    } else {
      final user =
          await _firestore.collection('CUserData').document(userId).get();
      _currentClData = CUserData(
        email: user.data['email'],
        fname: user.data['fname'],
        lname: user.data['lname'],
        address: user.data['address'],
        age: user.data['age'],
        sex: user.data['sex'],
        userId: user.data['userId'],
        pictureUrl: user.data['pictureUrl'],
      );
    }
  }
}
