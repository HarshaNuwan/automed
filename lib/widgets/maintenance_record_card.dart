import 'package:automed/screens/maintenance_record_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MaintenanceRecordCard extends StatelessWidget {
  final String maintenanceRecordId;
  final String name;
  final String imageURL;
  final int lifeTime;
  final String OEMCode;
  final int replacedMileage;
  final int mileage;
  final int vehicleId;
  final double price;

  const MaintenanceRecordCard(
      {this.maintenanceRecordId,
      this.name,
      this.imageURL,
      this.lifeTime,
      this.OEMCode,
      this.replacedMileage,
      this.mileage,
      this.vehicleId,
      this.price});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(MaintenanceRecordDetails.routeName, arguments: {
          'name': name,
          'maintenanceRecordId': maintenanceRecordId,
          'imageURL': imageURL,
          'lifetime': lifeTime,
          'OEMCode': OEMCode,
          'replacedMileage': replacedMileage,
          'mileage': mileage,
          'vehicleId': vehicleId,
          'price': price,
          'lifeTime': lifeTime,
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: imageURL,
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
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          this.name,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'OEM Code : ${this.OEMCode}',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Replaced at : ${this.replacedMileage.toString()}',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Price : ${this.price.toString()}',
                          style: TextStyle(fontSize: 11),
                        ),
                        Text(
                          '${mileage - replacedMileage} done',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                    _getPercentageIndicator(mileage, replacedMileage, lifeTime)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPercentageIndicator(
      int currentMileage, int replacedMileage, int lifetime) {
    if (currentMileage == null || replacedMileage == null || lifeTime == null) {
      return Text('');
    }
    double age = (currentMileage - replacedMileage) / lifetime;
    double percent = 0.0;
    if (age >= 1.0) {
      percent = 1.0;
    } else {
      percent = age;
    }
    Color indicatorColor = Colors.green;
    if (percent >= 0.25 && percent <= 0.50) {
      indicatorColor = Colors.yellow[600];
    } else if (percent >= 0.50 && percent <= 0.75) {
      indicatorColor = Colors.orange[600];
    } else if (percent >= 0.75 && percent <= 1.0) {
      indicatorColor = Colors.red[600];
    }

    return CircularPercentIndicator(
      animation: true,
      radius: 78.0,
      lineWidth: 10.0,
      percent: percent,
      center: Text(
        '${(percent * 100).toStringAsFixed(0)}%',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey[300],
      progressColor: indicatorColor,
    );
  }
}
