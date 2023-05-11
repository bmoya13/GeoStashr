import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'example_popup.dart';
import 'profile.dart';
import 'addstash.dart';
import 'about.dart';
import 'notifs.dart';

class appMap extends StatefulWidget {
  const appMap({Key? key}) : super(key: key);

  @override
  State<appMap> createState() => _appMapState();
}

class _appMapState extends State<appMap> {
  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;
  final PopupController _popupLayerController = PopupController();
  var NewStash = false;

  var auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;

  List displayName = ['...'];
  List stashesOwned = ['...'];
  List caches = [];
  List cacheUID = [];

  @override
  void initState() {
    super.initState();
    loadDisplayNameFromDb();
    loadCachesFromDb();
    _followOnLocationUpdate = FollowOnLocationUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();
  }

  @override
  void dispose() {
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  void loadDisplayNameFromDb() {
    var uid = auth.currentUser?.uid;
    db.collection('users').doc(uid).get()
      .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('document data (username): ${documentSnapshot.get('username')}');
          print('document data (email): ${documentSnapshot.get('email')}');
          displayName[0] = documentSnapshot.get('username');
          stashesOwned[0] = documentSnapshot.get('stashes');
          print(displayName[0]);
        } else {
          print('Document does not exist on the database');
        }
        setState(() {});
    }).catchError((error) {
      print("request failed for displayname " + error);
    });
  }

  void loadCachesFromDb() {
    caches = [];
    cacheUID = [];
    db.collection("caches").get().then(
        (querySnapshot) {
          print("Successfully completed");
          for (var docSnapshot in querySnapshot.docs) {
            caches.add(LatLng(double.parse(docSnapshot.get('lat')), double.parse(docSnapshot.get('long'))));
            cacheUID.add(docSnapshot.get('uid'));
          }
          print("list: " + caches[0].toString());
          print("uid list: " + cacheUID[0].toString());
          setState(() {});
        },
        onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = caches.map((latlng) {
      return Marker(
        width: 80,
        height: 80,
        point: latlng,
        builder: (_) => Icon(
          Icons.circle,
          color: cacheUID[caches.indexOf(latlng)] == auth.currentUser?.uid ?
            Colors.green.withOpacity(0.3) :
            Colors.blue.withOpacity(0.3),
          size: 80,
        ),
        anchorPos: AnchorPos.align(AnchorAlign.center),
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello ' + displayName[0] + '!',
          style: TextStyle(
            color: Colors.lightBlue,
            fontFamily: 'FredokaOne'
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh map',
            onPressed: () {
              loadCachesFromDb();
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Map refreshed!')));
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                image: DecorationImage(
                  image: AssetImage('assets/logoCropped.png'),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Text(
                'GeoStashr',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  backgroundColor: Colors.grey,

                ),
              ),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.account_circle, size: 40),
              title: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onTap: () {
                debugPrint('Clicked profile');
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Profile())
                );
              },
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.add_box, size: 40),
              title: Text(
                'Add Stash',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onTap: () {
                debugPrint('Clicked add stash');
                if (stashesOwned[0] == 0) {
                  showAlertDialog(context, "You already have two stashes up! Delete one or buy another slot to add a new one.");
                } else {
                  if (NewStash == true) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    NewStash = true;
                    ScaffoldMessenger.of(context).showSnackBar(_buildSnackbar(context));
                  }
                }
              },
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.notification_important, size: 40),
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onTap: () {
                debugPrint('Clicked notifications');
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Notifications())
                );
              },
            ),
            ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
              leading: Icon(Icons.question_mark, size: 40),
              title: Text(
                'About',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onTap: () {
                debugPrint('Clicked about');
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const About())
                );
              },
            )
          ],
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(34.058577,-117.823819),
          zoom: 18,
          maxZoom: 18,
          minZoom: 17,
          onTap: _handleTap,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture && _followOnLocationUpdate != FollowOnLocationUpdate.never) {
              setState(
                    () => _followOnLocationUpdate = FollowOnLocationUpdate.never,
              );
            }
          },
        ),
        nonRotatedChildren: [
          Positioned(
            right: 20,
            bottom: 30,
            child: FloatingActionButton(
              onPressed: () {
                // Follow the location marker on the map when location updated until user interact with the map.
                setState(
                      () => _followOnLocationUpdate = FollowOnLocationUpdate.always,
                );
                // Follow the location marker on the map and zoom the map to level 18.
                _followCurrentLocationStreamController.add(18);
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
          AttributionWidget.defaultWidget(
            source: 'Mapbox',
            onSourceTapped: () async {
              // Requires 'url_launcher'
              if (!await launchUrl(Uri.parse("https://docs.mapbox.com/help/getting-started/attribution/"))) {
                if (kDebugMode) print('Could not launch URL');
              }
            },
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: dotenv.env['TEMPLATE'],
            additionalOptions:  {
              "access_token": dotenv.env['ACCESS_TOKEN'] ?? 'DEFAULT',
            },
            userAgentPackageName: 'com.example.app',
          ),
          CurrentLocationLayer(
            followCurrentLocationStream:
            _followCurrentLocationStreamController.stream,
            followOnLocationUpdate: _followOnLocationUpdate,
          ),
          //MarkerLayer(markers: markers),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              popupController: _popupLayerController,
              markers: test,
              markerRotateAlignment:
              PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.center),
              popupBuilder: (BuildContext context, Marker marker) =>
                  ExamplePopup(marker),
            ),
          ),
        ],
      )
    );
  }

  SnackBar _buildSnackbar(BuildContext context) {
    return new SnackBar(
      content: const Text(
        'Tap the map to place a stash!',
        textAlign: TextAlign.center,
      ),
      duration: Duration(days: 1),
      backgroundColor: Colors.blueGrey,
      shape: StadiumBorder(),
      margin: EdgeInsets.all(50),
      behavior: SnackBarBehavior.floating,
    );
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    if (NewStash == true) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        NewStash = false;
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateStash(latlng))
        );
      });
    }
  }

  showAlertDialog(BuildContext context, String text) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(text),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
