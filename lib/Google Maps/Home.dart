import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.445639, 74.291027),
    zoom: 14.4746,
  );
  List<Marker> _marker = [];
  List<Marker> _list = [
    Marker(
        markerId: MarkerId("1"),
        position: LatLng(31.445639, 74.291027),
        infoWindow: InfoWindow(
          title: "My Current Location",
        )),
    Marker(
        markerId: MarkerId("2"),
        position: LatLng(31.4475, 74.3081),
        infoWindow: InfoWindow(
          title: "Town Ship",
        )),
    Marker(
        markerId: MarkerId("3"),
        position: LatLng(31.4495, 74.3082),
        infoWindow: InfoWindow(
          title: "Town Ship 2",
        )),
    Marker(
        markerId: MarkerId("4"),
        position: LatLng(35.6764, 139.6500),
        infoWindow: InfoWindow(
          title: "Tokyo",
        )),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _marker.addAll(_list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            markers: Set<Marker>.of(_marker),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          GoogleMapController controller = await _controller.future;
          controller
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(35.6764, 139.6500),
            zoom: 14.4746,
          )));
        },
        child: Icon(Icons.location_on),
      ),
    );
  }
}
