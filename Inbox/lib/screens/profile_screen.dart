import 'package:Inbox/screens/edit_profile.dart';
//import 'package:Inbox/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:Inbox/screens/search_screen.dart';
import 'package:Inbox/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Inbox/models/user.dart';
// import 'package:skeleton_text/skeleton_text.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;
  ProfileScreen({this.profileId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  void setCurrentScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("path", "");
    prefs.setString("current_user_on_screen", "");
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(microseconds: 200), vsync: this);

    animation = ColorTween(begin: Colors.grey[200], end: Colors.white)
        .animate(controller);
    controller.forward();
    setCurrentScreen();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  final _auth = FirebaseAuth.instance;
  final userRefs = FirebaseFirestore.instance.collection('users');
  Animation animation;
  AnimationController controller;

//Functions

  _showDialog(parentContext) async {
    // flutter defined function
    return showDialog(
      context: parentContext,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "SignOut",
            style: TextStyle(color: Colors.black, fontFamily: 'Mulish'),
          ),
          content: Text(
            "Do you want to Sign out ?",
            style: TextStyle(color: Colors.grey[700], fontFamily: 'Mulish'),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontFamily: 'Mulish'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text(
                "Sign Out",
                style: TextStyle(color: Colors.red, fontFamily: 'Mulish'),
              ),
              onPressed: () async {
                _auth.signOut();
                final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.remove('email');
                Navigator.popUntil(
                    context, ModalRoute.withName('login_screen'));
                Firebase.initializeApp().whenComplete(() {
                  // print('initialization Complete');
                  setState(() {});
                });
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRefs.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        Account user = Account.fromDocument(snapshot.data);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.grey[100],
              backgroundImage: user.avtar == ''
                  ? AssetImage('assets/images/profile-user.png')
                  : CachedNetworkImageProvider(user.avtar),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              user.email == '' ? 'Email: Add your email....' : user.email,
              style: TextStyle(
                  color: Colors.black54, fontFamily: 'Mulish', fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Text(
                  user.bio == ''
                      ? 'Bio : Write something about you....'
                      : user.bio,
                  style: TextStyle(
                      color: Colors.grey, fontFamily: 'Mulish', fontSize: 16.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()));
          },
          icon: Icon(Icons.edit, color: Colors.white),
        ),
        title: Text('Profile', style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                splashRadius: 16.0,
                onPressed: () => _showDialog(context),
                icon: Icon(Icons.logout)),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: buildProfileHeader(),
        ),
      ),
    );
  }
}
