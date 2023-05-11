import 'package:flutter/material.dart';
import 'login.dart';
import 'map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class NewAcc extends StatefulWidget {
  const NewAcc({Key? key}) : super(key: key);

  @override
  State<NewAcc> createState() => _NewAccState();
}

class _NewAccState extends State<NewAcc> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(
          'New Account',
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
              Image(
                image: const AssetImage('assets/dark.png'),
                width: MediaQuery.of(context).size.width * 0.70,
                height: MediaQuery.of(context).size.height * 0.30,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email'
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username'
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password'
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmpassController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password'
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  var enteredUsername = usernameController.text.toString();
                  var enteredEmail = emailController.text.toString();
                  var enteredPassword = passwordController.text.toString();
                  var confirmpass = confirmpassController.text.toString();
                  print("Email: " + enteredEmail);
                  print("Username: " + enteredUsername);
                  print("Password: " + enteredPassword);
                  print("ConfirmPass: " + confirmpass);

                  var db = FirebaseFirestore.instance;
                  var auth = FirebaseAuth.instance;

                  if ((enteredUsername.length >= 6) && (enteredUsername.length <= 9)) {
                    if (confirmpass == enteredPassword) {
                      auth
                          .createUserWithEmailAndPassword(
                          email: enteredEmail,
                          password: enteredPassword)
                          .then((value) {
                        print("Created New Account");

                        var userUid = auth.currentUser?.uid;
                        print(userUid);

                        db.collection('users').doc(userUid).set({
                          'email': enteredEmail,
                          'username': enteredUsername,
                          'stashes' : 2,
                          'notifs' : []
                        });

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const appMap())
                        );
                      }).onError((error, stackTrace) {
                        showAlertDialog(context, "Error: ${error.toString()}");
                      });
                    } else {
                      showAlertDialog(context, "Passwords do not match up! Please ensure that they match up.");
                    }
                  } else {
                    showAlertDialog(context, "Username needs to be between 6-9 characters!");
                  }

                  debugPrint('Clicked create account');
                },
                child: const Text(
                  'Confirm Account',
                  style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                ),
              ),
              OutlinedButton(
                style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xffD3D5D6))),
                onPressed: () {
                  debugPrint('Clicked already have account');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login())
                  );
                },
                child: const Text(
                  'Already have an account?',
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

  SnackBar _accountSuccess(BuildContext context) {
    return new SnackBar(
      content: const Text(
        'Account successfully created!',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.blueGrey,
      shape: StadiumBorder(),
      margin: EdgeInsets.all(50),
      behavior: SnackBarBehavior.floating,
    );
  }

}
