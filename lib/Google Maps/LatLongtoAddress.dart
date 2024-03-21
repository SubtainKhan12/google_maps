import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LatlongtoAddress extends StatefulWidget {
  const LatlongtoAddress({super.key});

  @override
  State<LatlongtoAddress> createState() => _LatlongtoAddressState();
}

class _LatlongtoAddressState extends State<LatlongtoAddress> {
  String stAddress = "";
  String stAddress1 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              List<Location> locations =
                  await locationFromAddress("Gronausestraat 710, Enschede");

              List<Placemark> placemarks =
                  await placemarkFromCoordinates(52.2165157, 6.9437819);
              // final query = "1600 Amphiteatre Parkway, Mountain View";

              // final coordinates = new Coordinates(31.4475, 74.3081);

              setState(() {
                stAddress = locations.last.longitude.toString() +
                    ", " +
                    locations.last.latitude.toString();
                stAddress1 = placemarks.reversed.last.country.toString() +
                    " " +
                    placemarks.reversed.last.locality.toString();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.blue),
                child: Center(child: Text("Convert")),
              ),
            ),
          ),
          Text(stAddress),
          Text(stAddress1),
        ],
      ),
    );
  }
}
