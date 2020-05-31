import 'package:flutter/foundation.dart';

class CUserData {
  final String userId;
  final String email;
  final String fname;
  final String lname;
  final String address;
  final int age;
  final String sex;
  final String pictureUrl;

  CUserData({
    @required this.userId,
    @required this.email,
    @required this.fname,
    @required this.lname,
    @required this.age,
    @required this.sex,
    @required this.pictureUrl,
    this.address,
  });
}

class HpUserData {
  final String userId;
  final String email;
  final String fname;
  final String lname;
  final String profession;
  final int experience;
  final String address;
  final String shortDescription;
  final int age;
  final String sex;
  final int nPatientsTreated;
  final int reviewers;
  final bool available;
  final String pictureUrl;
  final Map<String, dynamic> rating;

  HpUserData(
      {@required this.userId,
      @required this.email,
      @required this.fname,
      @required this.lname,
      @required this.age,
      @required this.profession,
      @required this.sex,
      @required this.experience,
      @required this.pictureUrl,
      this.shortDescription,
      this.address,
      this.nPatientsTreated,
      this.rating,
      this.reviewers,
      this.available});
}
