import 'dart:convert';
import 'dart:io';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps/model/getLocation_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../model/responsemodel.dart';

class AllMap_Ui extends StatefulWidget {
  AllMap_Ui({
    Key? key,
  }) : super(key: key);

  @override
  State<AllMap_Ui> createState() => _AllMap_UiState();
}

class _AllMap_UiState extends State<AllMap_Ui> {
  List<GetLocationModel> getLocationListModel = [];
  final List<Marker> _marker = <Marker>[];
  late BitmapDescriptor customIcon;

  TextEditingController collection_controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // var f = NumberFormat("###,###.#", "en_US");
  List<int> generatedListNumbers = [];
  var uniqueRandomNumber;
  var colorx = Colors.indigo;
  File? _imageFile;
  late LatLng _userLocation = LatLng(33.6941, 72.9734);

  // Controller to add, update, and control the custom-info-window
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  CameraPosition? _camPosition =
      CameraPosition(target: LatLng(31.4457347, 74.2909749), zoom: 17);

  @override
  void initState() {
    super.initState();
    fetch_AllLocations();
    setCustomMarker();
    // _getCurrentPosition();

    _checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Stack(
        children: [
          // on below line creating google maps.
          GoogleMap(
            initialCameraPosition: _camPosition!,
            // Set "marker" to mention Pin Markers in map
            markers: Set<Marker>.of(_marker),
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            // CALLING MAP'S DIALOG-BOX
            onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
            onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
            onMapCreated: (GoogleMapController controller) {
              _customInfoWindowController.googleMapController = controller;
            },
          ),
          // CREATING ALERT-DIALOG-BOX
          CustomInfoWindow(
            controller: _customInfoWindowController,
            offset: 35,
            height: 250,
            width: 250,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.white60,
        onPressed: _takePicture,
        tooltip: 'Take Picture',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  // SET location data for pin/marker customers from api
  loadData() {
    _marker.clear();
    for (int i = 0; i < getLocationListModel.length; i++) {
      // Parse the latitude and longitude strings as doubles (if they are valid)
      double latitude =
          double.parse(getLocationListModel[i].tlatval.toString()) ?? 0.0;
      double longitude =
          double.parse(getLocationListModel[i].tlngval.toString()) ?? 0.0;

      // Add the marker only if the latitude and longitude are valid numbers
      if (latitude != 0.0 && longitude != 0.0) {
        _marker.add(
          Marker(
            icon: customIcon,
            markerId: MarkerId(i.toString()),
            position: LatLng(latitude, longitude),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 3.0, left: 3.0, top: 2.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  "Latitude: " +
                                      getLocationListModel[i]
                                          .tlatval
                                          .toString()
                                          .trim(),
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text("Longitude: " +
                                  getLocationListModel[i].tlngval.toString()),
                              SizedBox(
                                height: 10,
                              ),
                              Image.network(
                                "https://crystalsolutions.com.pk/test/images/${getLocationListModel[i].tcstpic.toString()}",
                                height: 250,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    }

    // Update the camera position to focus on the first marker
    if (_marker.isNotEmpty) {
      final firstMarker = _marker.first;
      _camPosition = CameraPosition(
        target: firstMarker.position,
        zoom: 12.0,
      );
    }
    // After adding markers, update the UI by calling setState
    setState(() {});
  }

// RESTful API
  Future<List<GetLocationModel>> fetch_AllLocations() async {
    try {
      var response = await http.post(
          Uri.parse("https://crystalsolutions.com.pk/test/GetLocation.php"));
      var datax = jsonDecode(response.body.toString());
      // print(datax);

      if (response.statusCode == 200) {
        for (var i in datax) {
          getLocationListModel.add(GetLocationModel.fromJson(i));
        }
        setState(() {});
        loadData();
      }
    } catch (e) {
      print(e);
    }
    return getLocationListModel;
  }

  void setCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        devicePixelRatio: 2.5,
      ),
      'assets/images/placeholder1.png',
    );
  }

  // For pin location setup adjustment
  // Future<void> _getCurrentPosition() async {
  //   final hasPermission = await _handleLocationPermission();

  //   if (!hasPermission) return;
  //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //     setState(() {
  //       // _currentPosition = position;
  //       // _lat = _currentPosition!.latitude.toString();
  //       // _long = _currentPosition!.longitude.toString();
  //     });
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  Future post_imageMethod() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://crystalsolutions.com.pk/test/Location.php'));
    request.fields['latitude'] = _userLocation.latitude.toString();
    request.fields['longitude'] = _userLocation.longitude.toString();
    var picture = await http.MultipartFile.fromPath('pic', _imageFile!.path);
    request.files.add(picture);

    final response = await http.Response.fromStream(await request.send());

    var result = jsonDecode(response.body.toString());

    ResponseModel responseModel = ResponseModel.fromJson(result);
    if (result["error"] == 200) {
      print(result["message"]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["message"]),duration: Duration(seconds: 2),));
    } else {
      print(result["error"]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["message"]),duration: Duration(seconds: 2),));
    }
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
            InkWell(
                onTap: () {
                  post_imageMethod();
                },
                child: const Icon(
                  Icons.upload,
                  size: 40,
                ))
          ],
        ),
      ),
      _userLocation,
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _requestLocationPermission();
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {});
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
      setState(() {});
    } else {
      // Permission granted, proceed with getting user location
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      // _marker.add(_buildMarker(_userLocation));
      // print('---------------------------------------- $_marker');
    });
  }

  // Marker _buildMarker(LatLng position) {
  //   return Marker(
  //     markerId: MarkerId(position.toString()),
  //     position: position,
  //     onTap: () {
  //       showInfoWindow();
  //     },
  //   );
  // }

  //  For location permission setup
  // Future<bool> _handleLocationPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text(
  //             'Location services are disabled. Please enable the services')));
  //     return true;
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Location permissions are denied')));
  //       return false;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text(
  //             'Location permissions are permanently denied, we cannot request permissions.')));
  //     return false;
  //   }
  //   return true;
  // }
}
