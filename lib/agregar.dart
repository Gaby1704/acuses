import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:acuses/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class MyFlutterApp {
  MyFlutterApp._();

  static const _kFontFam = 'MyFlutterApp';
  static const String? _kFontPkg = null;

  static const IconData asterisk =
      IconData(0xf069, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}

class AddItemPage extends StatelessWidget {
  final String userName;
  final int? userId;
  AddItemPage({required this.userId, required this.userName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Acuse', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF572772),
      ),
      body: SingleChildScrollView(
        child: Container(
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
  Uint8List? _capturedImageData;

  Future<void> _saveDataToServer({
    required String theme,
    required String description,
    required String assignedPerson,
    required String startDate,
    required String endDate,
    required String tracking,
    required String comments,
    required String status,
    Uint8List? imageData,
  }) async {
    String statusText = status ?? 'Pendiente'; // Use the selected status

    try {
      String base64Image = '';
      if (imageData != null) {
        base64Image = base64Encode(imageData);
      }
      var response = await http.post(
        Uri.parse('https://pruebas.septlaxcala.gob.mx/app/envio.php'),
        body: {
          'tema': theme,
          'descripcion': description,
          'name': assignedPerson,
          'fechaI': startDate,
          'fechaF': endDate,
          'status': status, // Use the selected status
          'seguimiento': tracking,
          'comentario': comments,
          'fecha': DateTime.now().toString(),
          'idUser': UserIdSingleton.userId,
          'archivo': base64Image,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

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

  Future<void> convertirAPdf(Uint8List imageData) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageData);

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: pw.Image(image));
    }));

    try {
      final directory = await getExternalStorageDirectory();
      final file = File("${directory!.path}/DocumetosAcuses/imagen.pdf");
      await file.create(recursive: true);
      await file.writeAsBytes(await pdf.save());

      Fluttertoast.showToast(
        msg: 'PDF generado con éxito\nUbicación: ${file.path}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      print('PDF Guardado en ${file.path}');
    } catch (e) {
      print("Error al guardar PDF: $e");

      Fluttertoast.showToast(
        msg: 'Error al generar el PDF',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _captureDocuments() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Seleccionar origen del documento'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'camera');
              },
              child: const Text('Tomar Foto'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'gallery');
              },
              child: const Text('Elegir imagen de la Galería'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'pdf');
              },
              child: const Text('Seleccionar PDF en almacenamiento interno'),
            ),
          ],
        );
      },
    );

    if (result == 'camera') {
      _capturePhoto();
    } else if (result == 'gallery') {
      _pickImageFromGallery();
    } else if (result == 'pdf') {
      _pickPdfFromStorage();
    }
  }

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _capturedImageData = bytes;
      });
      convertirAPdf(bytes);
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        _capturedImageData = bytes;
      });
      convertirAPdf(bytes);
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<void> _pickPdfFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      Uint8List bytes = await file.readAsBytes();
      setState(() {
        _capturedImageData = bytes;
      });
      convertirAPdf(bytes);
    } else {
      print('No se seleccionó ningún archivo PDF.');
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
                      SizedBox(
                          width: 10.0), // Espacio entre el icono y el texto
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
          onPressed: _captureDocuments,
          style: ElevatedButton.styleFrom(
            primary: Color(0xfff08018),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            'Adjuntar Documentos',
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
              String endDate =
                  _endDate?.toLocal().toString().split(' ')[0] ?? '';
              String status = _selectedStatus ?? 'Pendiente';
              String tracking = _trackingController.text;
              String comments = _commentsController.text;

              _saveDataToServer(
                theme: theme,
                description: description,
                assignedPerson: assignedPerson,
                startDate: startDate,
                endDate: endDate,
                status: status,
                tracking: tracking,
                comments: comments,
                imageData: _capturedImageData,
              );
              print(UserIdSingleton.userId);
              print(UserIdSingleton.userName);

              _themeController.clear();
              _descriptionController.clear();
              _assignedPersonController.clear();
              _startDate = DateTime.now();
              _endDate = null;
              _selectedStatus = 'Pendiente';
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