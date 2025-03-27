import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _fileName = "Ningún archivo seleccionado";
  List<List<String>> _csvData = [];
  List<String> _filteredNumbers = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _fileName = file.path.split('/').last;
      });

      _sendFileToServer(file);
    }
  }

  Future<void> _sendFileToServer(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/upload_csv'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var decoded = jsonDecode(responseBody);
      setState(() {
        _csvData = (decoded['csv_data'] as List)
            .map((row) => (row as List).map((e) => e.toString()).toList())
            .toList();
        _filteredNumbers =
            List<String>.from(decoded['filtered_numbers'].map((e) => e.toString()));
      });
    } else {
      print("Error al enviar el archivo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('CSV Uploader')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Seleccionar CSV'),
              ),
              Text("Archivo: $_fileName"),
              const SizedBox(height: 10),
              const Text("Contenido del CSV:"),
              Expanded(
                child: ListView.builder(
                  itemCount: _csvData.length,
                  itemBuilder: (context, index) {
                    return Text(_csvData[index].join(", "));
                  },
                ),
              ),
              const Divider(),
              const Text("Números menores o iguales a 7:"),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredNumbers.length,
                  itemBuilder: (context, index) {
                    return Text(_filteredNumbers[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
