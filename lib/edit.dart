import 'package:flutter/material.dart';

class editDetalles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar detalles",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF572772),
      ),
      body: Center(
        child: Text('Página para editar detalles'),
      ),
    );
  }
}