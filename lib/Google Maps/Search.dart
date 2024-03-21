import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SearchPlaces extends StatefulWidget {
  const SearchPlaces({super.key});

  @override
  State<SearchPlaces> createState() => _SearchPlacesState();
}

class _SearchPlacesState extends State<SearchPlaces> {
  TextEditingController _controller = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '12345';
  List<dynamic> _placeslist = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      onChange();
    });
  }

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getsuggestion(_controller.text);
  }

  void getsuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyCvIBpb1jSKbolAv1oaLE90ctMiL8pTqIg";
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        _placeslist = jsonDecode(response.body.toString())["predictions"];
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Search Places"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  fillColor: Colors.grey.shade300,
                  filled: true),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: _placeslist.length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(_placeslist[index]['description']),
            //       );
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
