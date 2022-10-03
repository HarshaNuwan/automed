import 'package:automed/screens/add_new_vehicle_screen.dart';
import 'package:automed/widgets/vehicle_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            backgroundColor: Colors.black,
            floating: true,
            title: Center(child: Text('Automed')),
            leading: Icon(Icons.menu),
            flexibleSpace: FlexibleSpaceBar(),
            actions: [
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  })
            ],
          ),
          _getItems()
        ],
      ),
    );
  }

  Widget _getItems() {
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
                .collection('vehicles')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
            builder: (ctx, vehicleSnapshot) {
              if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                    child: Container(
                        margin: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator())));
              }
              final vehicles = vehicleSnapshot.data.documents;

              List<Card> cards = [];

              for (int i = 0; i < vehicles.length; i++) {
                cards.add(Card(
                    elevation: 5,
                    child: VehicleCard(
                      model: vehicles[i].get('model'),
                      manufacturer: vehicles[i].get('manufacturer'),
                      currentMileage: vehicles[i].get('currentMileage'),
                      vehicleImage: vehicles[i].get('imageURL'),
                      description: vehicles[i].get('description'),
                      vehicleId: vehicles[i].id,
                    )));
              }

              cards.add(Card(
                elevation: 5,
                child: InkWell(
                    splashColor: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(ctx).pushNamed(AddNewVehicle.routeName);
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
                            'Add New Vehicle',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )),
              ));

              return SliverList(delegate: SliverChildListDelegate(cards));
            });
      },
    );
  }
}
