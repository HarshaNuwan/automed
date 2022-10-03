import 'package:automed/screens/vehicle_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VehicleCard extends StatefulWidget {
  final String vehicleId;
  final String model;
  final String manufacturer;
  final int currentMileage;
  final String vehicleImage;
  final String description;

  const VehicleCard({
    this.vehicleId,
    this.model,
    this.manufacturer,
    this.currentMileage,
    this.vehicleImage,
    this.description,
  });

  @override
  _VehicleCardState createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  final mileageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(VehicleDetailsScreen.routename, arguments: {
          'image': widget.vehicleImage,
          'model': widget.model,
          'manufacturer': widget.manufacturer,
          'mileage': widget.currentMileage,
          'description': widget.description,
          'vehicleId': widget.vehicleId,
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: widget.vehicleImage,
              errorWidget: (context, url, error) => Icon(Icons.image),
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 50,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  this.widget.model,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(this.widget.manufacturer),
                Row(
                  children: [
                    Text('Mileage ${this.widget.currentMileage.toString()}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _updateMileageBottomSheet(
                              context, widget.vehicleId, widget.currentMileage);
                        },
                        child: Text('Update'))
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateMileageBottomSheet(
      BuildContext context, String vehicleId, int mileage) {
    showModalBottomSheet(
        context: context,
        builder: (bCtx) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Update current mileage'),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'current mileage',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.grey[850])),
                    controller: mileageController,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _updateMileage(vehicleId, mileage);
                        Navigator.of(context).pop();
                      },
                      child: Text('Update'))
                ],
              ),
            ),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void _updateMileage(String vehicleId, int mileage) async {
    if (int.parse(mileageController.text) < mileage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New mileage cannot be less than current mileage.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      mileageController.clear();
      return;
    }
    await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .update({'currentMileage': int.parse(mileageController.text)});
    setState(() {
      mileageController.clear();
    });
  }
}
