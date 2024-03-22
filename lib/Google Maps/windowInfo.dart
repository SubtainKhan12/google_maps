import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_info_window/custom_info_window.dart';

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

  List<Marker> _marker = <Marker>[];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Permission denied, show dialog to request permission
      _requestLocationPermission();
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
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 300,
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://officesnapshots.com/wp-content/uploads/2018/09/software-house-offices-gliwice-12-1200x800.jpg",
                  ),
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.high,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                color: Colors.red,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Crystal Solutions',
                      maxLines: 1,
                      // overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '.3 mi.',
                    style: TextStyle(color: Colors.black),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                'Challenge us with your requirements',
                maxLines: 2,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      _userLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _locationPermissionDenied
            ? Center(
                child: Text(
                  'Location permission denied.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : Stack(
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
                    // myLocationEnabled: true,
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
                    height: 200,
                    width: 300,
                    offset: 35,
                  ),
                ],
              ),
      ),
    );
  }
}
