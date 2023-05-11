import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'map.dart';


class CreateStash extends StatefulWidget {
  final LatLng point;

  const CreateStash(this.point, {Key? key}) : super(key: key);

  @override
  State<CreateStash> createState() => _CreateStashState();
}

class _CreateStashState extends State<CreateStash> {
  TextEditingController nameController = TextEditingController();
  TextEditingController hintController = TextEditingController();
  TextEditingController stashpwController = TextEditingController();
  TextEditingController confirmpwController = TextEditingController();

  var auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;

  List displayName = ['...'];

  @override
  void initState() {
    super.initState();
    loadDisplayNameFromDb();
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
        print('Document does nto exist on the database');
      }
      setState(() {

      });
    }).catchError((error) {
      print("request failed for displayname " + error);
    });
  }

  Future<bool> docExists(String docID) async {
    final snapShot = await db.collection('caches').doc(docID).get();
    if (snapShot == null || !snapShot.exists) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Position: ${widget.point.latitude.toStringAsFixed(6)}, ${widget.point.longitude.toStringAsFixed(6)}',
          style: TextStyle(
              fontSize: 18,
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
              SizedBox(height: 20),
              CircleAvatar(
                backgroundImage: AssetImage('assets/logoCropped.png'),
                radius: 80,
              ),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked change stash icon');
                },
                child: const Text(
                  'Change Stash Icon',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter Stash Name',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: TextField(
                  controller: hintController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Location Hint',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: TextField(
                  controller: stashpwController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Stash Password',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: TextField(
                  controller: confirmpwController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm Stash Password',
                  ),
                ),
              ),
              Text(
                'Current User: ' + displayName[0],
                style: TextStyle(
                  fontSize: 15
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () async {
                  debugPrint('Clicked create!');
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

                  var name = nameController.text.toString();
                  var hint = hintController.text.toString();
                  var pw = stashpwController.text.toString();
                  var confirm = confirmpwController.text.toString();
                  var point = '${widget.point.latitude}, ${widget.point.longitude}';

                  if (name.isEmpty || hint.isEmpty || pw.isEmpty || confirm.isEmpty) {
                    showAlertDialog(context, "Please ensure all fields are filled out", false);
                  } else if (pw != confirm) {
                    showAlertDialog(context, "The two passwords do not match up!", false);
                  } else {
                    var alreadyExist = await docExists(point);
                    if (alreadyExist == true) {
                      showAlertDialog(context, 'That coordinate is already taken! Please choose another area.', false);
                    } else {
                      db.collection('users').doc(auth.currentUser?.uid).update({"stashes" : FieldValue.increment(-1)});
                      db.collection('caches').doc(point).set({
                        'name': name,
                        'hint': hint,
                        'password': pw,
                        'lat': '${widget.point.latitude}',
                        'log' : [],
                        'long': '${widget.point.longitude}',
                        'user': displayName[0],
                        'uid': auth.currentUser?.uid,
                      });
                      showAlertDialog(context, 'Cache successfully created!', true);

                    }
                  }
                },
                child: const Text(
                  'Create Stash!',
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
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => appMap())
          );
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
