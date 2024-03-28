import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailSending extends StatefulWidget {
  const EmailSending({super.key});

  @override
  State<EmailSending> createState() => _EmailSendingState();
}

class _EmailSendingState extends State<EmailSending> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _sendingtoController = TextEditingController();

  String? _filePath;
  Future<void> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  void _removeSelectedFile() {
    setState(() {
      _filePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send Email",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            onPressed: _openFilePicker,
            icon: Icon(
              Icons.attachment,
              color: Colors.white,
              size: 35,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: _sendEmail,
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _sendingtoController,
                decoration: InputDecoration(
                  hintText: "To...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: "Subject...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: null,
                controller: _bodyController,
                decoration: InputDecoration(
                  hintText: "Compose email...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              if (_filePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _filePath!,
                              // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _removeSelectedFile,
                          icon: Icon(Icons.cancel),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmail() async {
    if (_filePath == null) {
      print("No file selected for attachment.");
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://crystalsolutions.com.pk/test/EmailSend.php'),
    );
    request.fields['email'] = _sendingtoController.text;
    request.fields['subject'] = _subjectController.text;
    request.fields['body'] = _bodyController.text;

    var file = await http.MultipartFile.fromPath('file', _filePath!);
    request.files.add(file);

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var result = jsonDecode(response.body);

      if (result["error"] == 200) {
        print(result["message"]);
      } else {
        print(result["error"]);
      }
    } catch (e) {
      print("Error sending email: $e");
    }
  }
}
