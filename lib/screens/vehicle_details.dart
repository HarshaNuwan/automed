import 'dart:io';

import 'package:automed/screens/add_maintenance_record_screen.dart';
import 'package:automed/widgets/maintenance_record_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VehicleDetailsScreen extends StatefulWidget {
  static final String routename = 'vehicledetailsscreen';

  @override
  _VehicleDetailsScreenState createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final List<String> _tabs = <String>['Maintenance', 'Service'];
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as Map;
    final imageUrl = args['image'];
    final model = args['model'];
    final manufacturer = args['manufacturer'];
    final mileage = args['mileage'];
    final description = args['description'];
    final vehicleId = args['vehicleId'];

    return Scaffold(
      body: DefaultTabController(
        length: _tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverSafeArea(
                    top: false,
                    bottom: Platform.isIOS ? false : true,
                    sliver: SliverAppBar(
                      expandedHeight: 250,
                      backgroundColor: Colors.black,
                      floating: true,
                      leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop()),
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
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
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  )
                                : null,
                            top: 0,
                          ),
                          Positioned(
                              bottom: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                padding: EdgeInsets.all(16.0),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      manufacturer,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Mileage ${mileage.toString()}',
                                          style: TextStyle(
                                            color: Colors.lightGreen[300],
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      description,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                      bottom: TabBar(
                        tabs: _tabs
                            .map((String name) => Tab(text: name))
                            .toList(),
                      ),
                    )),
              ),
            ];
          },
          body: TabBarView(
            children: _tabs.map((String name) {
              return SafeArea(
                top: false,
                bottom: false,
                child: Builder(
                  builder: (BuildContext context) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        return true;
                      },
                      child: CustomScrollView(
                        key: PageStorageKey<String>(name),
                        slivers: <Widget>[
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                          SliverPadding(
                              padding: const EdgeInsets.all(8.0),
                              sliver: name == 'Maintenance'
                                  ? _getMaintenanceRecords(vehicleId, mileage)
                                  : null),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _getMaintenanceRecords(String vehicleId, int mileage) {
    return FutureBuilder(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (ctx, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator())));
        }
        final user = FirebaseAuth.instance.currentUser;

        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('maintenance_records')
                .where('userId', isEqualTo: user.uid)
                .where('vehicleId', isEqualTo: vehicleId)
                .snapshots(),
            builder: (ctx, maintenanceSnapshot) {
              if (maintenanceSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return SliverToBoxAdapter(
                    child: Container(
                        margin: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator())));
              }
              final maintenanceRecords = maintenanceSnapshot.data.documents;

              List<Card> cards = [];

              cards.add(Card(
                elevation: 3,
                child: InkWell(
                    splashColor: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(ctx).pushNamed(
                          AddMaintenanceRecordScreen.routeName,
                          arguments: {
                            'vehicleId': vehicleId,
                            'currentMileage': mileage
                          });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      color: Colors.grey[700],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          Text(
                            'Add Record',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )),
              ));

              for (int i = 0; i < maintenanceRecords.length; i++) {
                cards.add(Card(
                    elevation: 3,
                    child: MaintenanceRecordCard(
                      maintenanceRecordId: maintenanceRecords[i].id,
                      name: maintenanceRecords[i].get('name'),
                      imageURL: maintenanceRecords[i].get('imageURL'),
                      mileage: mileage,
                      replacedMileage:
                          maintenanceRecords[i].get('replacedMileage'),
                      lifeTime: maintenanceRecords[i].get('lifetime'),
                      OEMCode: maintenanceRecords[i].get('OEMCode'),
                      price: maintenanceRecords[i].get('price') == null
                          ? 0.0
                          : maintenanceRecords[i].get('price'),
                    )));
              }

              return SliverList(delegate: SliverChildListDelegate(cards));
            });
      },
    );
  }
}
