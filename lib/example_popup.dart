import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'stashaccess.dart';

class ExamplePopup extends StatefulWidget {
  final Marker marker;

  const ExamplePopup(this.marker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePopupState();
}

class _ExamplePopupState extends State<ExamplePopup> {

  var db = FirebaseFirestore.instance;

  List cacheName = ['...'];
  List cacheUser = ['...'];

  @override
  void initState() {
    super.initState();
    loadCacheFromDb();
  }

  void loadCacheFromDb() {
    db.collection('caches').doc('${widget.marker.point.latitude}, ${widget.marker.point.longitude}').get()
        .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            print('document data (cache user): ${documentSnapshot.get('user')}');
            print('document data (cache name): ${documentSnapshot.get('name')}');
            cacheName[0] = documentSnapshot.get('name');
            cacheUser[0] = documentSnapshot.get('user');
          } else {
            print("document does not exist on db");
          }
          setState(() {});
    }).catchError((error) {
      print("request failed for cache " + error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() {
        }),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _cardDescription(context),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              cacheName[0],
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Text(
              'Position: ${widget.marker.point.latitude.toStringAsFixed(6)}, ${widget.marker.point.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'User: ' + cacheUser[0],
              style: const TextStyle(fontSize: 12.0),
            ),
            OutlinedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
              onPressed: () {
                debugPrint('Clicked access stash!');
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StashAccess(widget.marker))
                );
              },
              child: const Text(
                'Access Stash',
                style: TextStyle(fontSize: 15, color: Colors.lightBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}