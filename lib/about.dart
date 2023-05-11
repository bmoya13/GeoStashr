import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'About',
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
              Text(
                'How to Play Geostashr',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'FredokaOne',
                  fontSize: 30,
                  decoration: TextDecoration.underline
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Overview',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'First of all, Geostashr is a geocaching app, meaning users hide and seek containers/stashes at specific locations marked by coordinates all over the area.'
                      ' Once participants find a stash, they are expected to find the password within it, enter it in the app, and enter what one item they took and what one item they left for others!'
                      ' This operates on the honor rule, the game works best when each user to take something, leave something, and treat the stash respectfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                'Main Map',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "The main playing field of the app. This is where the approximate locations of the stashes are marked. Clicking on them will reveal more details and accessing them will even reveal hints!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Green markers ",
                    style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(text: "- created by you and can be deleted by you", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
                    ]
                  )
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Blue markers ",
                      style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(text: "- owned by others and can be accessed publicly", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
                      ]
                  )
              ),
              SizedBox(height: 10),
              Text(
                'Creating a Stash',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 25,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'New users get two free stash slots. When users with an open slot wish to create a stash, it is important to have the necessary materials set up and ready to go.'
                      ' They may use any container that is sturdy, and moderately sized. They should be clearly marked as a geostash'
                      ' as to explain what they are to non-players. The password to the stash must be written in the container in some way in order for players to access its logbook once they find it.'
                      ' There is no restriction on what could be stashed, as long as you are willing to part with it as others can keep it. If you delete a stash, please ensure you go collect the remnants of the stash.'
                      ' After all, you could reuse some of the trinkets left in the old stash for your new one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'REMEMBER THE HONOR RULE!!!\nTAKE SOMETHING, LEAVE SOMETHING!!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
