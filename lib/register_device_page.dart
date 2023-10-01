import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class RegisterDevicePage extends StatefulWidget{

  @override
  State createState() => _State();

}

class _State extends State<RegisterDevicePage>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController deviceIDController = TextEditingController();
  final TextEditingController confirmDeviceIDController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  String? validateDeviceID(String? value){

    if(value == null || value.isEmpty){
      return "Please enter your DeviceID";
    }
    else if ( value.length < 6 ){
      return "Please enter a valid DeviceID";
    }
    return null;
  }

  String? validateConfirmDeviceID(String? value){

    if(value == null || value.isEmpty){
      return "Please enter your DeviceID";
    }
    else if ( value !=  deviceIDController.text){
      return "Please check your DeviceID";
    }
    return null;
  }

  String? validateName(String? value){

    if(value == null || value.isEmpty){
      return "Please enter name for your Device";
    }
    else if ( value.length < 3 ){
      return "Please enter a valid for your Device";
    }
    return null;
  }


  void navigateToHomeScreen(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => HomePage()),
            (route) => false
    );
  }



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


  Future<void> updateUsersDevices(String deviceID, String nickname) async {
    String usersDevicesPath = "usersDevices/${FirebaseAuth.instance.currentUser!.uid}";
    DataSnapshot data = await FirebaseDatabase.instance.ref(usersDevicesPath).get();

    if(data.value == null){
      // Create the path in firebase
      Map<String, dynamic> uploadData = {
        "devices":
        {
          deviceID : nickname
        }
      };
      await FirebaseDatabase.instance.ref(usersDevicesPath).update(uploadData);
    }
    else{
      // update the path in firebase
      Map<String, dynamic> uploadData = Map<String, dynamic>.from(data.value as Map);
      uploadData["devices"][deviceID] = nickname;
      await FirebaseDatabase.instance.ref(usersDevicesPath).update(uploadData);
    }
  }


  void onPressedRegisterDevice() async {
    if(_formKey.currentState!.validate()) {
      String deviceListPath = "devices/${deviceIDController.text}";
      DataSnapshot data = await FirebaseDatabase.instance.ref(deviceListPath)
          .limitToLast(10)
          .get();
      print(data.value);

      if (data.value == null) {
        showSnackBar("The Device ID does not exist?");
      }
      print('ID exists');

      Map<String, dynamic> dataMap = Map<String, dynamic>.from(
          data.value as Map);

      print(dataMap.length);

      showSnackBar("updating.");
      await updateUsersDevices(
          deviceIDController.text, nicknameController.text);
      navigateToHomeScreen();

      return;
    }
  }


  //     if(dataMap.containsKey("uid")){
  //       print('containsKey');
  //       String uid = dataMap['uid'] as String;
  //       if(uid.length > 1){
  //         showSnackBar("This DeviceID is already registered.");
  //       }
  //       else{
  //         print('does not containsKey');
  //         showSnackBar("Registering...");
  //         dataMap['uid'] = FirebaseAuth.instance.currentUser!.uid;
  //         await FirebaseDatabase.instance.ref(deviceListPath).update(dataMap);
  //         await updateUsersDevices(deviceIDController.text, nicknameController.text);
  //         showSnackBar("This DeviceID is Free .");
  //         navigateToHomeScreen();
  //
  //       }
  //     }
  //
  //   }
  // }


  Widget deviceForm(){
    return Form(
      key: _formKey,
      child: Column(
        children: [

          // Device ID Field
          TextFormField(
            controller: deviceIDController,
            validator: validateDeviceID,
            decoration: const InputDecoration(
                labelText: "Device ID",
                hintText: "AA-BB-CC"
            ),
          ),


          // Confirm Form Field
          TextFormField(
            controller: confirmDeviceIDController,
            validator: validateConfirmDeviceID,
            decoration: const InputDecoration(
                labelText: "Confirm Device ID",
                hintText: "AA-BB-CC"
            ),
          ),


          // Nickname Form Field
          TextFormField(
            controller: nicknameController,
            validator: validateName,
            decoration: const InputDecoration(
                labelText: "Device Name",
                hintText: "BLue Drone 1"
            ),
          ),


          // Sign Up button
          ElevatedButton(
              onPressed: onPressedRegisterDevice,
              child: const Text("Register Device")
          ),


        ],
      ),
    );
  }

  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(),
      body: Center(child:deviceForm()),
    );
  }

}