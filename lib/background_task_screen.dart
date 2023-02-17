import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundTaskUI extends StatefulWidget {
  const BackgroundTaskUI({Key? key}) : super(key: key);

  @override
  State<BackgroundTaskUI> createState() => _BackgroundTaskUIState();
}

class _BackgroundTaskUIState extends State<BackgroundTaskUI> {
  String locationText = "";

  _init() async {
    await Future.delayed(const Duration(seconds: 3));
    var sharedPreference = await SharedPreferences.getInstance();
    locationText = sharedPreference.getString("locationText") ?? "";
    print("LOCATION :$locationText");
    setState(() {});
  }

  @override
  void initState() {
    _init();
    askLocationPermission();
    super.initState();
  }

  askLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    Workmanager().registerPeriodicTask(
      "locationId",
      "LOCATION",
      tag: "SampleTag",
      inputData: {"name": "Abdulloh"},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Background"),
      ),
      body: Center(
          child: Column(
        children: [
          Text(
            locationText,
            style: const TextStyle(
              fontSize: 40,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Workmanager().cancelByTag("SampleTag");
              },
              child: const Text("Cancel Loaction task")),
          ElevatedButton(
              onPressed: () {
                Workmanager().registerOneOffTask("newTask", "NEW_TASK",
                    tag: "newTaskTag", inputData: {"name": "Falonchi"});
              },
              child: const Text("Register new task "))
        ],
      )),
    );
  }
}
