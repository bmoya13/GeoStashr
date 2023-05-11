import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'map.dart';

class LogBook extends StatefulWidget {
  final LatLng point;

  const LogBook(this.point, {Key? key}) : super(key: key);

  @override
  State<LogBook> createState() => _LogBookState();
}

class _LogBookState extends State<LogBook> {
  TextEditingController takenController = TextEditingController();
  TextEditingController leftController = TextEditingController();

  var db = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;

  List displayName = ['...'];
  List cacheLog = [];
  List cacheName = ['...'];

  @override
  void initState() {
    super.initState();
    loadCacheFromDb();
    loadDisplayNameFromDb();
  }

  void loadCacheFromDb() {
    db.collection('caches').doc('${widget.point.latitude}, ${widget.point.longitude}').get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('document data (cache user): ${documentSnapshot.get('user')}');
        print('document data (cache name): ${documentSnapshot.get('name')}');
        cacheName[0] = documentSnapshot.get('name');
        cacheLog = documentSnapshot.get('log').reversed.toList();
        if (cacheLog.length >= 10) {
          cacheLog = cacheLog.sublist(0, 10);
        }
      } else {
        print("document does not exist on db");
      }
      setState(() {});
    }).catchError((error) {
      print("request failed for cache " + error);
    });
  }

  void loadDisplayNameFromDb() {
    var uid = auth.currentUser?.uid;
    db.collection('users').doc(uid).get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('document data (username): ${documentSnapshot.get('username')}');
        print('document data (email): ${documentSnapshot.get('email')}');
        displayName[0] = documentSnapshot.get('username');
        print(displayName[0]);
      } else {
        print('Document does not exist on the database');
      }
      setState(() {});
    }).catchError((error) {
      print("request failed for displayname " + error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logbook',
          style: const TextStyle(
              color: Colors.lightBlue,
              fontFamily: 'FredokaOne'
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              CircleAvatar(
                backgroundImage: AssetImage('assets/logoCropped.png'),
                radius: 70,
              ),
              Text(
                cacheName[0] + ' Logbook',
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 30,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                'Username  |  Date  |  Took  |  Left',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.30,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border.all(
                      color: Colors.blueGrey,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for(var i in cacheLog) Text(i.toString(), style: TextStyle(fontSize: 18),),
                    cacheLog.isEmpty ? Text('No entries yet! Add one below!', style: TextStyle(fontSize: 18),) : SizedBox()
                  ],
                ),
              ),
              Text('Keep the descriptions short!', style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  maxLength: 8,
                  controller: takenController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Item Taken From Stash',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: TextField(
                  maxLength: 8,
                  controller: leftController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Item Left In Stash',
                  ),
                ),
              ),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked submit');
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

                  var takeitem = takenController.text.toString();
                  var leftitem = leftController.text.toString();

                  DateTime now = DateTime.now();
                  var formattedDate = DateFormat.Md().format(now);

                  if (takeitem.isEmpty || leftitem.isEmpty) {
                    showAlertDialog(context, 'Please ensure all fields are filled out', false);
                  } else {
                    var entryString = displayName[0] + " | " + formattedDate +  " | " + takeitem + " | " + leftitem;
                    db.collection('caches').doc('${widget.point.latitude}, ${widget.point.longitude}')
                        .update({'log' : FieldValue.arrayUnion([entryString])});
                    showAlertDialog(context, 'Entry successfully added to logbook!', true);
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String text, bool finished) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        if (finished) {
          Navigator.of(context).pop();
        }
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


// children: <Widget>[
//                     Column(
//                       children: <Widget>[
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Username',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(width: 15),
//                     Column(
//                       children: <Widget>[
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Date',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(width: 15),
//                     Column(
//                       children: <Widget>[
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Took Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(width: 15),
//                     Column(
//                       children: <Widget>[
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                         Text(
//                           'Left Item',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
