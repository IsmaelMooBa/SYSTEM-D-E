import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['mensaje'];
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter & Python')),
        body: Center(
          child: FutureBuilder<String>(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Text(snapshot.data ?? 'Sin datos');
              }
            },
          ),
        ),
      ),
    );
  }
}
