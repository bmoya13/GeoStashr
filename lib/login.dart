import 'package:flutter/material.dart';
import 'newacc.dart';
import 'map.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(
          'GeoStashr',
          style: TextStyle(
              color: Colors.lightBlue,
              fontFamily: 'FredokaOne'
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              const Text (
                'Welcome to',
                style: TextStyle(fontSize: 30, fontFamily: 'FredokaOne'),
              ),
              Image(
                image: const AssetImage('assets/dark.png'),
                width: MediaQuery.of(context).size.width * 0.70,
                height: MediaQuery.of(context).size.height * 0.30,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your email'
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your password'
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  var email = emailController.text.toString();
                  var password = passwordController.text.toString();

                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password
                  ).then((value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const appMap())
                    );
                  }).onError((error, stackTrace) {
                    showAlertDialog(context, "Error ${error.toString()}");
                  });
                  debugPrint('Clicked log in');
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked create account');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const NewAcc())
                  );
                },
                child: const Text(
                  'New Account',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
              const SizedBox(height: 100),
              const Text(
                'Project by Brandon Moya for CS 4750',
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

}