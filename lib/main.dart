import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import 'package:get_storage/get_storage.dart';

void main() async{
  await GetStorage.init();
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
final storage = GetStorage();
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
getData();
  }

  double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    double lat1 = startLat * (pi / 180.0);
    double lon1 = startLong * (pi / 180.0);
    double lat2 = endLat * (pi / 180.0);
    double lon2 = endLong * (pi / 180.0);

    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  getData()async{
    Position? userLocation = await LocationService.getCurrentLocation();

    if (userLocation != null) {
      double latitude = userLocation.latitude;
      double longitude = userLocation.longitude;


      timer = Timer.periodic(Duration(minutes: 1), (Timer t) {


        // Save the current location
        saveLocation(latitude, latitude);
        print(latitude);
        print(longitude);
        // Force a rebuild to update the displayed locations
        setState(() {});

      });


      // Use latitude and longitude as needed
    } else {
      // Handle the case where location is not available or permission is not granted
    }

  }
  void saveLocation(double latitude, double longitude) {


    // Create a list to store previous locations
    List<Map<String, double>> locations = storage.read("locations") ?? <Map<String, double>>[];
    double distance = calculateDistance(latitude, longitude, 22.724815735239037,71.64112275968517);
    // Add the current location to the list
    locations.add({"latitude": latitude, "longitude": longitude,"distance": distance});

    // Save the updated list
    storage.write("locations", locations);
    storage.save();
  }




  @override
  Widget build(BuildContext context) {
    bool isKeyAvailable = GetStorage().hasData('locations');
    String locationText = "";
    if (isKeyAvailable) {
      List demo =storage.read("locations");
      List? locations =  demo;

      // Create a string to display the locations


      locations.forEach((location) {
        locationText += "Latitude: ${location["latitude"]}, Longitude: ${location["longitude"]}\n Distance: ${location["distance"]}\n";
      });
setState(() {

});
      print('The key is available in GetStorage.');
    } else {
      print('The key is not available in GetStorage.');
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return  Scaffold(
      appBar: AppBar(
        title: Text('Location Update'),
      ),
      body:  Text(locationText),
    );
  }
}
class LocationService {


  static Future<Position?> getCurrentLocation() async {
    try {
      // Request location permissions if not already granted
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        // Get the current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        return position;
      } else {
        // Handle the case where location permission is not granted
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the location fetching process
      print("Error getting location: $e");
      return null;
    }
  }
}


