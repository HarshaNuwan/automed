import 'package:automed/screens/add_maintenance_record_screen.dart';
import 'package:automed/screens/add_new_vehicle_screen.dart';
import 'package:automed/screens/auth_screen.dart';
import 'package:automed/screens/home_screen.dart';
import 'package:automed/screens/maintenance_record_details.dart';
import 'package:automed/screens/vehicle_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Duoxis Automed',
        theme: ThemeData(
          primaryColor: Colors.black,
          backgroundColor: Colors.white,
          accentColor: Colors.blue[800],
          accentColorBrightness: Brightness.dark,
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.white,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshoot) {
            if (userSnapshoot.hasData) {
              return HomeScreen();
            }
            return AuthScreen();
          },
        ),
        routes: {
          AddNewVehicle.routeName: (ctx) => AddNewVehicle(),
          VehicleDetailsScreen.routename: (ctx) => VehicleDetailsScreen(),
          AddMaintenanceRecordScreen.routeName: (ctx) =>
              AddMaintenanceRecordScreen(),
          MaintenanceRecordDetails.routeName: (ctx) =>
              MaintenanceRecordDetails(),
        });
  }
}
