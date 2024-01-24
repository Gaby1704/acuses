import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/widgets.dart';

class MyFlutterApp {
  MyFlutterApp._();

  static const _kFontFam = 'MyFlutterApp';
  static const String? _kFontPkg = null;

  static const IconData asterisk = IconData(0xf069, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
class AddItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Acuse', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF572772),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddItemForm(),
        ),
      ),
    );
  }
}

class AddItemForm extends StatefulWidget {
  @override
  _AddItemFormState createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assignedPersonController =
  TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _selectedStatus = 'Pendiente';
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '* Campos obligatorios',
          style: TextStyle(
          color: Colors.red,
          ),
        ),
        TextField(
          controller: _themeController,
          decoration: InputDecoration(
            labelText: 'Tema del Acuse',
            suffixIcon: Icon(
              MyFlutterApp.asterisk,
              color: Colors.red,
              size: 10.0,
            ),
          ),
        ),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Descripción del acuse',
            suffixIcon: Icon(
              MyFlutterApp.asterisk,
              color: Colors.red,
              size: 10.0,
            ),
          ),
        ),
        TextField(
          controller: _assignedPersonController,
          decoration: InputDecoration(
            labelText: 'Persona Asignada',
            suffixIcon: Icon(
              MyFlutterApp.asterisk,
              color: Colors.red,
              size: 10.0,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectStartDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _startDate.toLocal().toString().split(' ')[0],
                    ),
                    decoration: InputDecoration(
                      labelText: 'Fecha de creación',
                      suffixIcon: Icon(
                        MyFlutterApp.asterisk,
                        color: Colors.red,
                        size: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectEndDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _endDate?.toLocal().toString().split(' ')[0] ?? '',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Fecha de liberación',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        DropdownButton<String>(
          value: _selectedStatus,
          onChanged: (String? newValue) {
            setState(() {
              _selectedStatus = newValue!;
            });
          },
          items: ['Pendiente', 'En proceso', 'Terminado', 'Pausado']
              .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    MyFlutterApp.asterisk,
                    color: Colors.red,
                    size: 10.0,
                  ),
                  SizedBox(width: 10.0), // Espacio entre el icono y el texto
                  Text(value),
                ],
              ),
            ),
          )
              .toList(),
        ),
        TextField(
          controller: _trackingController,
          decoration: InputDecoration(
            labelText: 'Seguimiento',
          ),
        ),
        TextField(
          controller: _commentsController,
          decoration: InputDecoration(
            labelText: 'Comentarios',
          ),
        ),
        SizedBox(height: 5.0),
        ElevatedButton(
          onPressed: () {
            // Coloca aquí la lógica para capturar documentos
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xfff08018),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            'Capturar Documentos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            if (_themeController.text.isNotEmpty &&
                _assignedPersonController.text.isNotEmpty &&
                _startDate != null) {
              String theme = _themeController.text;
              String description = _descriptionController.text;
              String assignedPerson = _assignedPersonController.text;
              String startDate = _startDate.toLocal().toString().split(' ')[0];
              String endDate = _endDate?.toLocal().toString().split(' ')[0] ?? '';
              String status = _selectedStatus;
              String tracking = _trackingController.text;
              String comments = _commentsController.text;

              print('Tema: $theme');
              print('Descripción: $description');
              print('Persona Asignada: $assignedPerson');
              print('Fecha de Inicio: $startDate');
              print('Fecha de Fin: $endDate');
              print('Estado: $status');
              print('Seguimiento: $tracking');
              print('Comentarios: $comments');

              _themeController.clear();
              _descriptionController.clear();
              _assignedPersonController.clear();
              _startDate = DateTime.now();
              _endDate=null;
              _selectedStatus='Pendiente';
              _trackingController.clear();
              _commentsController.clear();
            } else {
              Fluttertoast.showToast(
                msg: "Por favor, completa todos los campos obligatorios",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Color(0xFFAA182C),
                textColor: Colors.white,
              );
              return;
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF572772),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            'Guardar acuse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}
