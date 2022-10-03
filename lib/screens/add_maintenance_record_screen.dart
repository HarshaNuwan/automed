import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:automed/widgets/image_picker.dart';

class AddMaintenanceRecordScreen extends StatefulWidget {
  static final String routeName = 'addmaintenancerecordscreen';

  @override
  _AddMaintenanceRecordScreenState createState() =>
      _AddMaintenanceRecordScreenState();
}

class _AddMaintenanceRecordScreenState
    extends State<AddMaintenanceRecordScreen> {
  final _formkey = GlobalKey<FormState>();
  bool _isSaving = false;
  File _userImageFile;
  var _name = '';
  var _OEMCode = '';
  var _price = 0.0;
  var _vendor = '';
  var _lifetime = 0;
  var _replacedMileage = 0;
  var _vehicleId = '';
  var _currentMileage = 0;

  //Old data when replacing
  var _Oldname;
  var _Oldprice;
  var _Oldvendor;
  var _Oldlifetime;

  var _isReplace = false;
  var _maintenanceRecordId;
  var _oldImageURL;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _addNewMaintenaceRecord() async {
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

      final user = FirebaseAuth.instance.currentUser;

      final ref = FirebaseStorage.instance
          .ref()
          .child('parts_images')
          .child(user.uid + _name + '-' + _OEMCode + '.jpg');

      await ref.putFile(_userImageFile).whenComplete(() => null);
      final URL = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('maintenance_records').add({
        'name': (_name == null || _name.isEmpty) ? '' : _name,
        'OEMCode': (_OEMCode == null || _OEMCode.isEmpty) ? '' : _OEMCode,
        'price': _price,
        'vendor': _vendor,
        'lifetime': _lifetime == 0 ? 0 : _lifetime,
        'replacedMileage': _replacedMileage,
        'userId': user.uid,
        'imageURL': URL,
        'vehicleId': _vehicleId,
      });
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop();
    }
  }

  void _updateMaintenanceRecord() async {
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

      final user = FirebaseAuth.instance.currentUser;

      final ref = FirebaseStorage.instance
          .ref()
          .child('parts_images')
          .child(user.uid + _name + '-' + _OEMCode + '.jpg');

      await ref.putFile(_userImageFile).whenComplete(() => null);
      final URL = await ref.getDownloadURL();

      //var URL =
      // 'https://firebasestorage.googleapis.com/v0/b/duoxis-automed.appspot.com/o/parts_images%2F8cACn1KZ5ZSQwA7D3Y6rwiMGNHq2Name%20changed-23456.jpg?alt=media&token=9b3b9aaf-5672-4ba0-9b3d-896aa1bc1c69';
      await FirebaseFirestore.instance
          .collection('maintenance_records')
          .doc(_maintenanceRecordId)
          .update({
        'name': _name,
        'OEMCode': _OEMCode,
        'price': _price,
        'vendor': _vendor,
        'lifetime': _lifetime,
        'replacedMileage': _replacedMileage,
        'imageURL': URL,
      });

      await FirebaseFirestore.instance
          .collection('maintenance_records_archived')
          .add({
        'maintenanceRecordId': _maintenanceRecordId,
        'name': _Oldname,
        'OEMCode': _OEMCode,
        'price': _Oldprice,
        'vendor': _Oldvendor,
        'lifetime': _Oldlifetime,
        'replacedMileage': _replacedMileage,
        'userId': user.uid,
        'imageURL': _oldImageURL,
        'vehicleId': _vehicleId,
      });

      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as Map;

    _isReplace = args['isReplace'] != null ? args['isReplace'] : false;
    if (_isReplace) {
      _oldImageURL = args['imageURL'];
      _maintenanceRecordId = args['maintenanceRecordId'] != null
          ? args['maintenanceRecordId']
          : null;

      //set old values
      _Oldname = args['name'];
      _Oldprice = args['price'];
      _Oldvendor = args['vendor'];
      _Oldlifetime = args['lifetime'];
    }
    _vehicleId = args['vehicleId'];
    _currentMileage = args['currentMileage'];

    return Scaffold(
      appBar: AppBar(
        title: Text('New Maintenance Record'),
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
                    key: ValueKey('name'),
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return "Please enter the name";
                      }
                      return null;
                    },
                    initialValue: _isReplace
                        ? (args['name'] != null ? args['name'] : null)
                        : null,
                    onSaved: (value) {
                      _name = value;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('OEMCode'),
                    decoration: InputDecoration(labelText: 'OEM Code'),
                    initialValue:
                        args['OEMCode'] != null ? args['OEMCode'] : null,
                    onSaved: (value) {
                      _OEMCode = value;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('Replacedmilage'),
                    decoration: InputDecoration(labelText: 'Replaced Mileage'),
                    keyboardType: TextInputType.number,
                    initialValue: _currentMileage.toString(),
                    onSaved: (value) {
                      _replacedMileage = int.parse(value);
                    },
                  ),
                  TextFormField(
                    key: ValueKey('Price'),
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return "Please enter the price";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _price = double.parse(value);
                    },
                  ),
                  TextFormField(
                    key: ValueKey('vendor'),
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return "Please enter the vendor";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Vendor'),
                    onSaved: (value) {
                      _vendor = value;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('lifetime'),
                    validator: (value) {
                      if (value.isEmpty || value == null) {
                        return "Please enter the lifetime";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Life Time'),
                    initialValue: args['lifeTime'] != null
                        ? args['lifeTime'].toString()
                        : null,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _lifetime = int.parse(value);
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (_isSaving) CircularProgressIndicator(),
                  if (!_isSaving)
                    ElevatedButton(
                      onPressed: () {
                        if (_isReplace) {
                          _updateMaintenanceRecord();
                        } else {
                          _addNewMaintenaceRecord();
                        }
                      },
                      child: Text(_isReplace ? 'Replace' : 'Add Record'),
                    )
                ],
              ),
            )),
      ),
    );
  }
}
