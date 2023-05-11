import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  var auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;

  List userNotifs = [];
  List splitStrings = [];

  @override
  void initState() {
    super.initState();
    db.collection("users").doc(auth.currentUser?.uid).snapshots().listen((event) {
      debugPrint("event happening");
      loadNotifsFromDb();
    });
  }

  void loadNotifsFromDb() {
    userNotifs = [];
    splitStrings = [];
    var uid = auth.currentUser?.uid;
    db.collection('users').doc(uid).get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userNotifs = documentSnapshot.get('notifs').reversed.toList();
        for (var i in userNotifs)
          splitStrings.add(i.split("|"));
      } else {
        print('Document does not exist on the database');
      }
      if(this.mounted) {
        setState(() {});
      }
    }).catchError((error) {
      print("request failed for notifs " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'User Notifications',
          style: TextStyle(
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
                SizedBox(height: 10,),
                for(var i in splitStrings) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 10,
                        child: Icon(
                          Icons.notification_important,
                          size: 60,
                        )
                      ),
                      Expanded(
                        flex: 33,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("User: " + i[0], style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            Text("Cache: " + i[1], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            SizedBox(height: 5,),
                            Text(i[2], style: TextStyle(fontSize: 18),),
                            SizedBox(height: 5,),
                            Text(i[3])
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: IconButton(
                          icon: Icon(Icons.delete_forever),
                          iconSize: 50,
                          color: Colors.red,
                          onPressed: () {
                            debugPrint('pressed trash');
                            db.collection('users').doc(auth.currentUser?.uid)
                                .update({'notifs' : FieldValue.arrayRemove([i[0]+"|"+i[1]+"|"+i[2]+"|"+i[3]])});
                          },
                        )
                      ),
                    ],
                  ),
                  Divider(color: Colors.black, thickness: 3,)
                ],
                (splitStrings.isEmpty) ? Text("No notifications yet!", style: TextStyle(fontSize: 30, color: Colors.red),) : SizedBox()
              ]
          ),
        ),
      ),
    );
  }
}
