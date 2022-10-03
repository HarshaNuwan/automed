import 'package:automed/screens/add_maintenance_record_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MaintenanceRecordDetails extends StatelessWidget {
  static final String routeName = 'maintenaceRecordDetails';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as Map;
    var maintenanceRecordId = args['maintenanceRecordId'];
    var mileage = args['mileage'];

    return _getRecordDetails(maintenanceRecordId, context, mileage);
  }

  Widget _getRecordDetails(
      String mRecordId, BuildContext context, int mileage) {
    return FutureBuilder(
        future: Future.value(FirebaseAuth.instance.currentUser),
        builder: (ctx, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Container(
                margin: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()));
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('maintenance_records')
                .doc(mRecordId)
                .snapshots(),
            builder: (ctx, maintenanceSnapshot) {
              if (!maintenanceSnapshot.hasData) {
                return Container(
                    margin: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()));
              }
              var userDocument = maintenanceSnapshot.data;

              return Scaffold(
                appBar: AppBar(
                  title: Text(userDocument['name']),
                  actions: [
                    IconButton(icon: Icon(Icons.delete), onPressed: () {})
                  ],
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: userDocument['imageURL'],
                      imageBuilder: (context, imageProvider) => Container(
                        height: 250,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          AddMaintenanceRecordScreen.routeName,
                                          arguments: {
                                            'isReplace': true,
                                            'currentMileage': mileage,
                                            'vehicleId':
                                                userDocument['vehicleId'],
                                            'maintenanceRecordId': mRecordId,
                                            'name': userDocument['name'],
                                            'OEMCode': userDocument['OEMCode'],
                                            'lifetime':
                                                userDocument['lifetime'],
                                            'imageURL':
                                                userDocument['imageURL'],
                                            'price': userDocument['price'],
                                            'vendor': userDocument['vendor'],
                                          },
                                        );
                                      },
                                      child: Text('Replace'))),
                            ],
                          ),
                          Row(children: [
                            Expanded(
                              child: Card(
                                elevation: 6,
                                child: Container(
                                  color: Colors.amber,
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'OEM Code : ${userDocument['OEMCode']}',
                                        style: TextStyle(),
                                      ),
                                      Text(
                                        'Replaced Mileage : ${userDocument['replacedMileage']}',
                                        style: TextStyle(),
                                      ),
                                      Text(
                                        'Price : ${userDocument['price']}',
                                        style: TextStyle(),
                                      ),
                                      Text(
                                        'Vendor : ${userDocument['vendor']}',
                                        style: TextStyle(),
                                      ),
                                      Text(
                                        'Lifetime : ${userDocument['lifetime']}',
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _getPercentageIndicator(
                                  mileage,
                                  userDocument['replacedMileage'],
                                  userDocument['lifetime']),
                            )
                          ]),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'History',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: _getHistoryRecords(mRecordId),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _getHistoryRecords(String mRecordId) {
    return FutureBuilder(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (ctx, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return Container(
              margin: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()));
        }

        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('maintenance_records_archived')
                .where('maintenanceRecordId', isEqualTo: mRecordId)
                .snapshots(),
            builder: (ctx, maintenanceSnapshot) {
              if (!maintenanceSnapshot.hasData) {
                return Container(
                    margin: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()));
              }

              final maintenanceRecords = maintenanceSnapshot.data.documents;

              return ListView.builder(
                itemCount: maintenanceRecords.length,
                itemBuilder: (ctx, index) {
                  return Card(
                    elevation: 3,
                    borderOnForeground: false,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${maintenanceRecords[index]['name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Replaced Mileage : ${maintenanceRecords[index]['replacedMileage']}',
                            style: TextStyle(),
                          ),
                          Text(
                            'Lifetime : ${maintenanceRecords[index]['lifetime']}',
                            style: TextStyle(),
                          ),
                          Text(
                            'Price : ${maintenanceRecords[index]['price']}',
                            style: TextStyle(),
                          ),
                          Text(
                            'Vendor : ${maintenanceRecords[index]['vendor']}',
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
      },
    );
  }

  Widget _getPercentageIndicator(
      int currentMileage, int replacedMileage, int lifetime) {
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
