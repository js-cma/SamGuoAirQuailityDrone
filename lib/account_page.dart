import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  @override
  State createState() => _State();
}

class _State extends State {

  void showSnackBar(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.yellow,
            onPressed: (){ ScaffoldMessenger.of(context).hideCurrentSnackBar(); } ,
          ),
        )
    );
  }

  void navigateToHomePage(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => HomePage()),
            (route) => false
    );
  }

  void navigateToLoginScreen(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => LoginPage()),
            (route) => false
    );
  }

  void logout() async{
    await FirebaseAuth.instance.signOut();
    navigateToLoginScreen();
  }

  void deleteAccount() async{
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    navigateToLoginScreen();
  }

  void showDeleteAlert(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
              title: const Text("Delete Account"),
              content: const Text("Are you sure you want to delete your account. This action can not be undone."),
              actions: [

                ElevatedButton(
                  onPressed: (){ Navigator.of(context).pop(); },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){ deleteAccount(); },
                  child: const Text('Delete'),
                ),
              ]
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){

    String email = FirebaseAuth.instance.currentUser!.email!;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Account"),
        ),
        body: Center(
            child: Column(
              children: [
                const Icon(
                    Icons.account_circle,
                    size: 125
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 35.0, left: 10, right: 10),
                  child: Row(
                    children: [
                      const Text("Email:"),
                      const Spacer(),
                      Text(email),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: logout,
                          child: const Text("Logout")
                      ),

                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: showDeleteAlert,
                          child: const Text("Delete Account")
                      ),


                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}
