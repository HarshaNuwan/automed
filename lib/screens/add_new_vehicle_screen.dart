import 'dart:io';

import 'package:automed/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddNewVehicle extends StatefulWidget {
  static final String routeName = 'addnewvehicle';

  @override
  _AddNewVehicleState createState() => _AddNewVehicleState();
}

class _AddNewVehicleState extends State<AddNewVehicle> {
  bool _isSaving = false;
  final _formkey = GlobalKey<FormState>();
  var _model = '';
  var _manufacturer = '';
  var _yom = 0;
  var _plateNumber = '';
  var _color = '';
  var _currentMileage = 0;
  var _description = '';
  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _addNewVehicle() async {
    final isValid = _formkey.currentState.validate();

    if (isValid) {
      _formkey.currentState.save();
      FocusScope.of(context).unfocus();

      if (_userImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please pick an image'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      final user = await FirebaseAuth.instance.currentUser;

      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(user.uid + _model + '-' + _manufacturer + '.jpg');

      await ref.putFile(_userImageFile).whenComplete(() => null);
      final URL = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('vehicles').add({
        'model': _model,
        'manufacturer': _manufacturer,
        'yom': _yom,
        'plateNumber': _plateNumber,
        'color': _color,
        'currentMileage': _currentMileage,
        'description': _description,
        'userId': user.uid,
        'imageURL': URL,
      });
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Vehicle'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                UserImagePicker(_pickedImage),
                TextFormField(
                  key: ValueKey('model'),
                  decoration: InputDecoration(labelText: 'Model'),
                  onSaved: (value) {
                    _model = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('manufacturer'),
                  decoration: InputDecoration(labelText: 'Manufacturer'),
                  onSaved: (value) {
                    _manufacturer = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('yom'),
                  decoration: InputDecoration(labelText: 'YOM'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _yom = int.parse(value);
                  },
                ),
                TextFormField(
                  key: ValueKey('platenumber'),
                  decoration: InputDecoration(labelText: 'Plate Number'),
                  onSaved: (value) {
                    _plateNumber = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('color'),
                  decoration: InputDecoration(labelText: 'Color'),
                  onSaved: (value) {
                    _color = value;
                  },
                ),
                TextFormField(
                  key: ValueKey('currentmileage'),
                  decoration: InputDecoration(labelText: 'Current Mileage'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _currentMileage = int.parse(value);
                  },
                ),
                TextFormField(
                  key: ValueKey('description'),
                  maxLines: 4,
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) {
                    _description = value;
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isSaving) CircularProgressIndicator(),
                if (!_isSaving)
                  ElevatedButton(
                    onPressed: () {
                      _addNewVehicle();
                    },
                    child: Text('Add Vehicle'),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
