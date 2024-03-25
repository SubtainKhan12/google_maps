import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class WindowInfo extends StatefulWidget {
  const WindowInfo({Key? key}) : super(key: key);

  @override
  State<WindowInfo> createState() => _WindowInfoState();
}



class _WindowInfoState extends State<WindowInfo> {
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  late LatLng _userLocation = LatLng(33.6941, 72.9734); // Default location
  late GoogleMapController _mapController;
  bool _isMapReady = false;
  bool _locationPermissionDenied = false;
  File? _imageFile;
  

  List<Marker> _marker = <Marker>[];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      
      _requestLocationPermission();
    } else if (permission == LocationPermission.deniedForever) {
      
      setState(() {
        _locationPermissionDenied = true;
      });
    } else {
      
      _getUserLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permission still denied, user may be asked again on next launch
    } else if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied, handle accordingly
      setState(() {
        _locationPermissionDenied = true;
      });
    } else {
      // Permission granted, proceed with getting user location
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _marker.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _userLocation,
          onTap: () {
            showInfoWindow();
          },
        ),
      );
    });

    if (_isMapReady) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_userLocation));
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _customInfoWindowController.googleMapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void showInfoWindow() {
    _customInfoWindowController.addInfoWindow!(
      Container(
        height: 200,
        width: 300,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _imageFile!,
                  width: 300,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                "Latitude: ${_userLocation.latitude.toString()}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Center(
              child: Text(
                "Longitude: ${_userLocation.longitude.toString()}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            GestureDetector(
              onTap: _takePicture,
              child: Padding(
                padding: const EdgeInsets.only(top: 5, left: 250),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 164, 147, 192),
                  ),
                  child: const Icon(
                    Icons.camera,
                    size: 35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      _userLocation,
    );
  }

  void _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      showInfoWindow();
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation,
                zoom: 14,
              ),
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: true,
              trafficEnabled: false,
              rotateGesturesEnabled: true,
              buildingsEnabled: true,
              markers: Set.of(_marker),
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              onMapCreated: onMapCreated,
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 250,
              width: 300,
              offset: 35,
            ),
          ],
        ),
      ),
    );
  }
}
