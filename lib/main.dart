import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workmanager_example/background_task_screen.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == "LOCATION") {
      String locationText = '';
      debugPrint("TASK STARTED ITS NAME: $taskName");
      final sharedPreference = await SharedPreferences.getInstance();
      try {
        Position currentPosition = await Geolocator.getCurrentPosition();
        await sharedPreference.setString("locationText",
            "LONGITUDE: ${currentPosition.longitude}: ${DateTime.now().toString()}");
        locationText = sharedPreference.getString("locationText") ?? "";
        debugPrint(locationText);
      } catch (err) {
        Logger().e(err
            .toString()); // Logger flutter package, prints error on the debug console
        throw Exception(err);
      }
      return Future.value(true);
    } else if (taskName == "NEW_TASK") {
      debugPrint("NEW TASK STARTED ITS NAME: $taskName");
      debugPrint("NEW TASK STARTED ITS INPUT DATA: $inputData");
      return Future.value(true);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await SharedPreferences.getInstance();

  // Workmanager().cancelByUniqueName("locationId");
  // Workmanager().registerPeriodicTask(
  //   "locationIdByPeriodic",
  //   "GET Continuous LOCATION PERIODIC",
  //   frequency: const Duration(minutes: 16),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BackgroundTaskUI(),
    );
  }
}
