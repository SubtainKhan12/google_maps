import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps/model/responsemodel.dart';
import 'package:http/http.dart' as http;

class FilePickerWidget extends StatefulWidget {
  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  File? _pickedFile;
  double? latitude;
  double? longitude;

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  void _getLocation() {
    
    setState(() {
      latitude = 37.7749; 
      longitude = -22.4194; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Picker'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Pick File'),
            ),
            SizedBox(height: 20),
            _pickedFile != null
                ? Text('File selected: ${_pickedFile!.path}')
                : Text('No file selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getLocation();
                _uploadFile(latitude, longitude);
              },
              child: Text('Upload File with Location'),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadFile(double? latitude, double? longitude) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://crystalsolutions.com.pk/test/Location.php'),
    );

    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    var picture = await http.MultipartFile.fromPath('pic', _pickedFile!.path);
    request.files.add(picture);
    final response = await http.Response.fromStream(await request.send());
    var result = jsonDecode(response.body.toString());

    ResponseModel responseModel = ResponseModel.fromJson(result);
    if (result["error"] == 200) {
      print(result["message"]);
      setState(() {
        _pickedFile = null;
        latitude = null;
        longitude = null;
      });
    } else {
      print(result["error"]);
    }
  }
}
