import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:samdrone/device_page.dart';

import 'account_page.dart';
import 'register_device_page.dart';

class HomePage extends StatefulWidget{

  @override
  State createState() => _State();

}

class _State extends State{

  void navigateToAccountPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => AccountPage())
    );
  }

  void navigateToRegisterDevicePage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => RegisterDevicePage())
    );
  }

  void navigateToDevicePage(String id, String name){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => DevicePage(id: id, name: name))
    );
  }


  Widget noDevicesView(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'No Devices Registered To This Account.',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
          onPressed: navigateToRegisterDevicePage,
          child: const Text('Register Device')
        )
      ]
    );
  }


  Widget deviceListView(Map<dynamic, dynamic> data){
    List<dynamic> keys = data["devices"].keys.toList();
    print(data);
    return Column(
      children: [

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index){

                String id = keys[index];
                String name = data["devices"][keys[index]];

                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('ID: ${keys[index]}'),
                    trailing: const Icon(Icons.chevron_right),
                    leading: const Icon(Icons.flight),
                    onTap: (){ navigateToDevicePage(id, name); },
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: (){ navigateToRegisterDevicePage(); },
                  child: const Text("Register Device")
              ),

              ElevatedButton(
                onPressed: (){
                  setState((){});
                },
                child: const Text("Refresh")
              ),
            ],
          ),
        ),

      ],
    );
  }

  FutureBuilder deviceFutureBuilder(){
    String path = "usersDevices/${FirebaseAuth.instance.currentUser!.uid}";
    return FutureBuilder(
        future: FirebaseDatabase.instance.ref(path).get(),
        // future: getUsersDeviceData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {

            return const Center(
              child: Text(
                'An Error has Occurred',
                style: TextStyle(fontSize: 18),
              ),
            );

          }
          else if (snapshot.hasData) {
            if(snapshot.data.value == null){
              return noDevicesView();
            }
            else{
              return deviceListView(snapshot.data.value);
            }

          }
          return const Center( child: CircularProgressIndicator());
        }
    );
  }




  @override
  Widget build(context){

    return Scaffold(
      appBar: AppBar(
        title: const Text("SAM'S  SAFEAIR"),
        actions: [
          IconButton(
            onPressed: navigateToAccountPage,
            icon: Icon(Icons.account_circle)
          )
        ]
      ),
      body: deviceFutureBuilder(),
    );
  }
}