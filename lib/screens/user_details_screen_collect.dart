import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../screens/signup_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  static const pageRoute = '/signup-screen';
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign-Up'),
      ),
      body: Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.7,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/welcomeImage.png'),
                    fit: BoxFit.cover),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber,
                    Colors.deepOrange,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: SignUpForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

enum Sex {
  Male,
  Female,
  Other,
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  File _image;

  bool isHp = false;
  Sex sexVal = Sex.Male;
  String sex = 'Male';

  Map<String, Object> _formData = {
    'isHp': null,
    'email': null,
    'password': null,
    'fname': null,
    'lname': null,
    'address': null,
    'age': null,
    'profession': null,
    'experience': null,
    'shortDescription': null,
    'sex': null,
    'image': null,
  };

  Widget _buildAddressTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Address',
        hintText: '(Optional)',
        labelStyle: kInputTextFormFieldLabelColor,
      ),
      keyboardType: TextInputType.text,
      onSaved: (String value) {
        _formData['address'] = value;
      },
    );
  }

  Widget _buildFirstNameTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'First Name',
        labelStyle: kInputTextFormFieldLabelColor,
      ),
      keyboardType: TextInputType.text,
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty ||
            RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
          return 'Please enter a first name';
        }
      },
      onSaved: (String value) {
        _formData['fname'] = value;
      },
    );
  }

  Widget _buildLastNameTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Last Name',
        hintText: 'Last name and other names...',
        labelStyle: kInputTextFormFieldLabelColor,
      ),
      keyboardType: TextInputType.text,
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty ||
            RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
          return 'Please enter a last name';
        }
      },
      onSaved: (String value) {
        _formData['lname'] = value;
      },
    );
  }

  Widget _buildAgeTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Your Age...',
        labelStyle: kInputTextFormFieldLabelColor,
      ),
      keyboardType: TextInputType.number,
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty ||
            RegExp(r'[.!@#<>?":_`~;[\]\\|=+)(*&^%\s-]').hasMatch(value) ||
            int.parse(value) > 120) {
          return 'Please enter a valid age';
        }
      },
      onSaved: (String value) {
        _formData['age'] = int.parse(value);
      },
    );
  }

  Widget _buildProfessionTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Profession',
        labelStyle: kInputTextFormFieldLabelColor,
        hintText: 'Please specify profession...',
      ),
      keyboardType: TextInputType.text,
      onSaved: (String value) {
        _formData['profession'] = value;
      },
    );
  }

  Widget _buildExperienceTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Years of Experience',
        labelStyle: kInputTextFormFieldLabelColor,
        hintText: 'Years of experience',
      ),
      keyboardType: TextInputType.text,
      //ignore: missing_return
      validator: (String value) {
        if (value.isEmpty ||
            RegExp(r'[.!@#<>?":_`~;[\]\\|=+)(*&^%\s-]').hasMatch(value) ||
            int.parse(value) > 80) {
          return 'Please enter a valid number';
        }
      },
      onSaved: (String value) {
        _formData['experience'] = int.parse(value);
      },
    );
  }

  Widget _buildShortDescriptionTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: kInputTextFormFieldLabelColor,
        hintText: 'Short professional discrition of youself (optional)...',
      ),
      keyboardType: TextInputType.text,
      onSaved: (String value) {
        _formData['shortDescription'] = value;
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    sex = sexVal.toString().split('.').last;
    _formData['sex'] = sex;
    _formData['isHp'] = isHp;
    _formData['image'] = _image;
    _formKey.currentState.save();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreen(_formData),
      ),
    );
  }

  Widget _buildNextButton() {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.fromLTRB(deviceSize.width * 0.7, 0, 0, 2),
      child: RaisedButton(
        child: Text('Next'),
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        onPressed: _submitForm,
      ),
    );
  }

  Widget _buildSexCheckboxRow() {
    return Container(
      child: Column(
        children: <Widget>[
          Text('Sex'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Male'),
              Checkbox(
                value: sexVal == Sex.Male ? true : false,
                onChanged: (val) {
                  setState(() {
                    //select sex
                    sexVal = Sex.Male;
                  });
                },
              ),
              Text('Female'),
              Checkbox(
                value: sexVal == Sex.Female ? true : false,
                onChanged: (val) {
                  setState(() {
                    //select sex
                    sexVal = Sex.Female;
                  });
                },
              ),
              Text('Other'),
              Checkbox(
                value: sexVal == Sex.Other ? true : false,
                onChanged: (val) {
                  setState(() {
                    //select sex
                    sexVal = Sex.Other;
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _showForm() {
    return Card(
      elevation: 8.0,
      margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildAddressTextFormField(),
              _buildFirstNameTextFormField(),
              _buildLastNameTextFormField(),
              if (isHp) _buildProfessionTextFormField(),
              _buildAgeTextFormField(),
              if (isHp) _buildExperienceTextFormField(),
              if (isHp) _buildShortDescriptionTextFormField(),
              _buildSexCheckboxRow(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = selected;
    });
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _image.path,
      maxHeight: 250,
      maxWidth: 250,
    );
    setState(() {
      _image = cropped ?? _image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Container(
                margin: EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.greenAccent.withOpacity(0.4),
                    child: _image == null
                        ? Image.asset(
                            'assets/images/question_mark.png',
                            fit: BoxFit.scaleDown,
                          )
                        : Image.file(
                            _image,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            if (_image == null)
              Text(
                'Take/Select picture',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_image != null)
              IconButton(
                icon: Icon(
                  Icons.crop,
                  size: 40,
                  color: Colors.black54,
                ),
                onPressed: _cropImage,
              ),
            IconButton(
              icon: Icon(
                Icons.camera_alt,
                size: 40,
                color: Colors.black54,
              ),
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.photo_library,
                size: 40,
                color: Colors.black54,
              ),
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Healthcare Professional',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Checkbox(
                value: isHp,
                onChanged: (val) {
                  setState(() {
                    isHp = !isHp;
                  });
                },
              )
            ],
          ),
        ),
        _showForm(),
        SizedBox(
          height: 30.0,
        ),
        _buildNextButton(),
      ],
    );
  }
}
