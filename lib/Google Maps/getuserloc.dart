import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetUserLoc extends StatefulWidget {
  const GetUserLoc({super.key});

  @override
  State<GetUserLoc> createState() => _GetUserLocState();
}

class _GetUserLocState extends State<GetUserLoc> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.6764, 139.6500),
    zoom: 14.4746,
  );
  List<Marker> _marker = <Marker>[
    Marker(
        markerId: MarkerId("4"),
        position: LatLng(35.6764, 139.6500),
        infoWindow: InfoWindow(
          title: "Tokyo",
        )),
  ];

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error: " + error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  LoadData() {
    getUserLocation().then((value) async {
      print("Current Location: ");
      print(value.latitude.toString() + " " + value.longitude.toString());
      _marker.add(Marker(
          markerId: MarkerId("2"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(title: "My Current Location")));
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14.4746,
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoadData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            trafficEnabled: false,
            rotateGesturesEnabled: true,
            buildingsEnabled: true,
            markers: Set<Marker>.of(_marker),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            }),
      ),
    );
  }
}
