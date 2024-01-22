import 'dart:convert';
import 'package:acuses/edit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:acuses/edit.dart';

class DetalleItemPage extends StatelessWidget {
  final String item;

  DetalleItemPage({required this.item});

  Future<Map<String, dynamic>> fetchDetailsFromWebService(String itemName) async {
    final response = await http.get(Uri.parse('https://si-exactaa.septlaxcala.gob.mx/numet/Detalles.php?item=$itemName'));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        var decodedResult = json.decode(utf8.decode(response.bodyBytes));
        print(decodedResult);
        if (decodedResult is Map<String, dynamic>) {
          return decodedResult;
        } else if (decodedResult is List<dynamic>) {
          if (decodedResult.isNotEmpty) {
            if (decodedResult.first is Map<String, dynamic>) {
              return Map<String, dynamic>.from(decodedResult.first);
            }
          }
        }

        print('Respuesta del servidor inesperada.');
        return {};
      } else {
        print('Respuesta del servidor vacía.');
        return {};
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      print('Detalles del error: ${response.body}');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF572772),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetailsFromWebService(item),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error en FutureBuilder: ${snapshot.error}');
            return Center(child: Text("Error al cargar detalles"));
          } else {
            Map<String, dynamic> details = snapshot.data ?? {};

            if (details.isNotEmpty) {
              return ListView(
                children: details.entries.map((entry) => ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.toString()),
                )).toList(),
              );
            } else {
              return Center(child: Text("Detalles no disponibles"));
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => editDetalles(),
            ),
          );
        },
        child: Icon(Icons.edit_note,
          color: Color(0xFFffffff),
        ),
        backgroundColor: Color(0xFF572772),
      ),
    );
  }
}
