import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
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
              CircleAvatar(
                backgroundImage: AssetImage('assets/logoCropped.png'),
                radius: 80,
              ),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked change pfp');
                },
                child: const Text(
                  'Change Profile Icon',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Statistics (Coming Soon)',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'FredokaOne',
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 20),
              _Statistics(context),
              SizedBox(height: 10),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked log out');
                  FirebaseAuth.instance.signOut().then((value) {
                    print("Successfully Signed Out");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const Login()), (route) => false
                    );
                  });
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Statistics(BuildContext context) {
    return Container(
      width: 350,
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(
            color: Colors.blueGrey,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Row(
        children: <Widget>[
          Column(
            children: const <Widget>[
              Text(
                'Geostashes Found:',
                style: TextStyle(
                    fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Geostashes Owned:',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Logbook Entries:',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Distance Walked:',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(width: 80),
          Column(
            children: <Widget>[
              Text(
                '#####',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '#####',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '#####',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '#####',
                style: TextStyle(
                  fontSize: 18,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
