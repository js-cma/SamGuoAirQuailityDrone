import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget{

  @override
  State createState() => _State();

}

class _State extends State{

  @override
  Widget build(context){

    Future.delayed(
      const Duration(seconds: 3),
      (){
        bool userLoggedIn = FirebaseAuth.instance.currentUser != null;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => userLoggedIn ? HomePage() : LoginPage()),
          (route) => false
        );
      }
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sam's SafeAir",
              style: Theme.of(context).textTheme.displayLarge
            ),


            const Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Image(
                image: AssetImage("assets/logo.png"),
                width: 250,
                height: 250,
              ),
            ),


          ],
        ),
      ),
    );
  }
}