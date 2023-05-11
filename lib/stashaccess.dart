import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';



import 'logbook.dart';
import 'map.dart';

class StashAccess extends StatefulWidget {
  final Marker marker;

  const StashAccess(this.marker, {Key? key}) : super(key: key);

  @override
  State<StashAccess> createState() => _StashAccessState();
}

class _StashAccessState extends State<StashAccess> {
  TextEditingController pwController = TextEditingController();

  var db = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;

  List cacheName = ['...'];
  List cacheUser = ['...'];
  List cacheHint = ['...'];
  List cachePass = ['...'];
  List cacheUID = ['...'];
  List displayName = ['...'];

  @override
  void initState() {
    super.initState();
    loadCacheFromDb();
    loadDisplayNameFromDb();
  }

  void loadCacheFromDb() {
    db.collection('caches').doc('${widget.marker.point.latitude}, ${widget.marker.point.longitude}').get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('document data (cache user): ${documentSnapshot.get('user')}');
        print('document data (cache name): ${documentSnapshot.get('name')}');
        cacheName[0] = documentSnapshot.get('name');
        cacheUser[0] = documentSnapshot.get('user');
        cacheHint[0] = documentSnapshot.get('hint');
        cachePass[0] = documentSnapshot.get('password');
        cacheUID[0] = documentSnapshot.get('uid');
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Position: ${widget.marker.point.latitude.toStringAsFixed(6)}, ${widget.marker.point.longitude.toStringAsFixed(6)}',
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
              SizedBox(height: 20),
              CircleAvatar(
                backgroundImage: AssetImage('assets/logoCropped.png'),
                radius: 80,
              ),
              SizedBox(height: 20),
              Text(
                cacheName[0],
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 40,
                ),
              ),
              Text(
                  'Creator: ' + cacheUser[0]
              ),
              Text(
                  'Coords: ${widget.marker.point.latitude}, ${widget.marker.point.longitude}'
              ),
              cacheUID[0] == auth.currentUser?.uid ?
                OutlinedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                  onPressed: () {
                    debugPrint('Clicked delete!');
                    showDeleteDialog(context);
                  },
                  child: const Text(
                    'Delete Stash',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ) :
                OutlinedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                  onPressed: () {
                    debugPrint('Clicked send notif!');
                    showNotifDialog(context);
                  },
                  child: const Text(
                    'Send Notification',
                    style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                  ),
                ),
              Container(
                width: 300,
                height: 200,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(
                    color: Colors.blueGrey,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                child: Text(
                  'Hint: ' + cacheHint[0],
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: TextField(
                  controller: pwController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Password',
                  ),
                ),
              ),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked access');
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                  var enteredPW = pwController.text.toString();
                  if (enteredPW == cachePass[0]) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogBook(widget.marker.point))
                    );
                  } else {
                    showAlertDialog(context, 'Entered password is incorrect! Please check physical stash for the right password!');
                  }
                },
                child: const Text(
                  'Access!',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  showDeleteDialog (BuildContext context) {
    // set up the button
    Widget cancelButton = TextButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget confirmButton = TextButton(
      child: Text("CONFIRM"),
      onPressed: () {
        db.collection('users').doc(auth.currentUser?.uid).update({"stashes" : FieldValue.increment(1)});
        db.collection('caches')
            .doc('${widget.marker.point.latitude}, ${widget.marker.point.longitude}')
            .delete().then((value) {
              print('Successfully deleted doc!');
        });
        Navigator.of(context).pop();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => appMap())
        );
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text('As owner of this stash, you may delete it and free up a stash slot on your account. Are you sure you want to delete this stash from the map?'),
      actions: [
        cancelButton,
        confirmButton,
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

  showNotifDialog(BuildContext context) {

    TextEditingController msgController = TextEditingController();

    // set up the button
    Widget sendButton = TextButton(
      child: Text("SEND"),
      onPressed: () {

        if (msgController.text.isEmpty) {
          showAlertDialog(context, "Cannot send an empty message!");
        } else {
          DateTime now = DateTime.now();
          var formattedDate = DateFormat.Md().add_jm().format(now);
          var sentString = displayName[0] + "|" + cacheName[0] + "|" + msgController.text.toString() + "|" + formattedDate;

          debugPrint("Sent String: " + sentString);
          db.collection('users').doc(cacheUID[0]).update({"notifs" : FieldValue.arrayUnion([sentString])});
          
          Navigator.of(context).pop();
          showAlertDialog(context, "Notification successfully sent!");
        }
      },
    );

    Widget cancelButton = TextButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Send Notification to Owner"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("Please include relevant info about the issue to your message. (Ex: Stash damaged, lost, etc.)"),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 5,
                controller: msgController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Message...',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        cancelButton,
        sendButton,
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
