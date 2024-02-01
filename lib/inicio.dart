import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acuses/detalles.dart';
import 'package:acuses/agregar.dart';
import 'main.dart';

class SedeModel {
  final String sede;
  final String estado;

  SedeModel({required this.sede, required this.estado});
}

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
  List<SedeModel> items = [];
  List<SedeModel> filteredItems = [];
  List<String> estados = [];
  TextEditingController filterController = TextEditingController();
  String? selectedEstado;  // Add this line to declare selectedEstado

  @override
  void initState() {
    super.initState();
    fetchDataFromWebService();
  }

  void fetchDataFromWebService() async {
    final response = await http.get(Uri.parse('https://pruebas.septlaxcala.gob.mx/app/Fpruebas.php'));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        print(responseData);
        if (responseData['sedes'] != null) {
          setState(() {
            List<String> sedes = List<String>.from(responseData['sedes']);
            List<String> estados = List<String>.from(responseData['estado']);

            if (sedes.length == estados.length) {
              items = List.generate(sedes.length, (index) => SedeModel(sede: sedes[index], estado: estados[index]));
              filteredItems = List.from(items);
              this.estados = estados.toSet().toList(); // Remove duplicates and set to states
            } else {
              print('Error: Mismatch in the number of sedes and estados.');
            }
            filteredItems = List.from(items);
          });
        } else {
          print('Data field is null in the response.');
        }
      } else {
        print('Server response is empty.');
      }
    } else {
      print('Error in the request: ${response.statusCode}');
      print('Error details: ${response.body}');
    }
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
  void _applyFilterByEstado(String? selectedEstado) {
    setState(() {
      this.selectedEstado = selectedEstado;
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      filteredItems = items
          .where((item) =>
      (selectedEstado == null || item.estado.toLowerCase() == selectedEstado?.toLowerCase()) &&
          (item.sede.toLowerCase().contains(filterController.text.toLowerCase()) ||
              item.estado.toLowerCase().contains(filterController.text.toLowerCase())))
          .toList();
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
        title: Text("¡Hola ${widget.userName}!", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF572772),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fondoInicio.png"),
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
                    onFilter: _applyFilter,
                    estados: estados,
                    onFilterByEstado: _applyFilterByEstado,
                    selectedEstado: selectedEstado, // Make sure this line is there
                  ),
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
                          builder: (context) => DetalleItemPage(item: filteredItems[index]),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF572772),
                      ),
                      title: Text(_capitalizeFirstLetter(filteredItems[index].sede)),
                      subtitle: Text(_capitalizeFirstLetter(filteredItems[index].estado)),
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
              builder: (context) => AddItemPage(userId: UserIdSingleton.userId, userName: UserIdSingleton.userName),
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
  final List<String> estados;
  final Function onFilterByEstado;
  final String? selectedEstado;

  SearchView({
    required this.filterController,
    required this.onFilter,
    required this.estados,
    required this.onFilterByEstado,
    required this.selectedEstado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text("Filtrar estado:"),
            SizedBox(width: 10),
            Expanded(
              child: DropdownButton<String>(
                value: selectedEstado,
                onChanged: (String? newSelectedEstado) {
                  onFilterByEstado(newSelectedEstado);
                },
                items: estados.map<DropdownMenuItem<String>>((String estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(estado),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                onClearFilters();
              },
              child: Text("Borrar Filtro"),
            ),
          ],
        )

      ],
    );
  }

  void onClearFilters() {
    filterController.clear();
    onFilterByEstado(null);
    onFilter();
  }
}

void _logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('is_logged_in', false);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => LoginScreen(onLogin: (userId, userName) {}),
    ),
  );
}
