import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DevicePage extends StatefulWidget{

  final String id;
  final String name;

  const DevicePage({super.key, required this.id, required this.name});


  @override
  State createState() => _State();

}

class _State extends State<DevicePage> {

  int calculateAQI(c, cLow, cHigh, iLow, iHigh){
    return ((iHigh - iLow) / (cHigh - cLow) * (c-cLow) + iLow).round();
  }


  Widget airQuailityDisplay(Map<dynamic, dynamic> data){
    // print('oi22');
    // print(data);
    List<dynamic> keys = data.keys.toList();
    keys.sort();
    String lastkey = keys.last;
    String published = data[lastkey]['published_at'];

    int pm25 = int.parse(data[lastkey]['pm25']);

    int airQuality = 0;
    Color color = Colors.green;
    String airQualityString = "Good";

    if(pm25 < 12) {
      airQuality = calculateAQI(pm25, 0, 12, 0, 50);
      airQualityString = "Good";
      color = Colors.green;
    }
    else if(pm25 < 35) {
      airQuality = calculateAQI(pm25, 12.1, 35.4, 51, 100);
      airQualityString = "Moderate";
      color = Colors.yellow;
    }
    else if(pm25 < 55) {
      airQuality = calculateAQI(pm25, 35.5, 55.4, 101, 150);
      airQualityString = "Unhealthy for sensitive groups";
      color = Colors.orange;
    }
    else if(pm25 < 150) {
      airQuality = calculateAQI(pm25, 55.5, 150.4, 151, 200);
      airQualityString = "Unhealthy";
      color = Colors.pinkAccent;
    }
    else if(pm25 < 250) {
      airQuality = calculateAQI(pm25, 150.5, 250.4, 200, 300);
      airQualityString = "Very Unhealthy";
      color = Colors.purpleAccent;
    }
    else {
      airQuality = calculateAQI(pm25, 250.5, 350.4, 301, 400);
      airQualityString = "Hazardous";
      color = Colors.purple;
    }

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("AQI: $airQuality"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  airQualityString,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
            Text("As of  $published"),

          ],
        ),
      ),
    );
  }

  Widget historyListView(Map<dynamic, dynamic> data){
    List<dynamic> keys = data.keys.toList();
    keys.sort();

    return Column(
      children: [
        airQuailityDisplay(data),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index){
                String key = keys[index];
                String publishedTime = data[key]['published_at'];
                String pm10 =  data[key]['pm10'];
                String pm25 =  data[key]['pm25'];
                String pm100 =  data[key]['pm100'];

                String outputString = "$publishedTime\n\tPM10:$pm10\n\tPM25:$pm25\n\tPM100:$pm100";

                return Card(
                  child: ListTile(
                    title: Text(outputString),
                    // subtitle: Text(outputString),
                  ),
                );
              }
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: (){setState(() { });},
              child: const Text("Refresh")
          ),
        )
      ],
    );
  }


  FutureBuilder getDeviceHistory(){
    String path = 'devices/${widget.id}';

    return FutureBuilder(
      future: FirebaseDatabase.instance.ref(path).limitToLast(10).get(),
      builder: (context, snapshot){
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'An Error has Occurred',
              style: TextStyle(fontSize: 18),
            ),
          );

        }
        else if (snapshot.hasData) {
          print(snapshot.data.value);
          if(snapshot.data.value == null){
            return Column(
              children: [
                Text('has No data'),
                ElevatedButton(
                    onPressed: (){setState(() { });},
                    child: const Text("Refresh")
                )
              ],
            );          }
          else{

            return historyListView(snapshot.data.value);
          }

        }
        return const Center( child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: getDeviceHistory(),
    );
  }
}