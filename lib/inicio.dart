import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:acuses/detalles.dart';
import 'package:acuses/agregar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class InterInicio extends StatelessWidget {
  final String userName;
  final int? userId;

  InterInicio({required this.userName, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(userName: userName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userName;
  final int? userId;

  MyHomePage({required this.userName, this.userId});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> items = [];
  List<String> filteredItems = [];
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromWebService();
  }

  void fetchDataFromWebService() async {
    final response = await http
        .get(Uri.parse('https://pruebas.septlaxcala.gob.mx/app/Fpruebas.php'));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        setState(() {
          items =
              List<String>.from(json.decode(utf8.decode(response.bodyBytes)));
          filteredItems = List.from(items);
          print(UserIdSingleton.userName);
          print(UserIdSingleton.userId);
        });
      } else {
        print('Respuesta del servidor vacía.');
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      print('Detalles del error: ${response.body}');
    }
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  void _applyFilter() {
    String filter = filterController.text.toLowerCase();
    setState(() {
      filteredItems =
          items.where((item) => item.toLowerCase().contains(filter)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              _logout(context);
            },
          ),
        ],
        title: Text("¡Hola ${widget.userName}!",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF572772),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/fondoInicio.png"), // Replace with your image asset path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SearchView(
                      filterController: filterController,
                      onFilter: _applyFilter),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleItemPage(item: filteredItems[index]),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF572772),
                      ),
                      title: Text(_capitalizeFirstLetter(filteredItems[index])),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF572772),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemPage(userId: UserIdSingleton.userId, userName: UserIdSingleton.userName,),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Color(0xFFffffff),
        ),
        backgroundColor: Color(0xFF572772),
      ),
    );
  }
}

class SearchView extends StatelessWidget {
  final TextEditingController filterController;
  final Function onFilter;

  SearchView({required this.filterController, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: filterController,
            onChanged: (value) => onFilter(),
            decoration: InputDecoration(
              hintText: "Buscar",
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('is_logged_in', false);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => LoginScreen(onLogin: (userId, userName) {})),
  );
}
