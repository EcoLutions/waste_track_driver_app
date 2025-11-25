import 'package:flutter/material.dart';

class RouteHistoryPage extends StatelessWidget {
  const RouteHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Rutas'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '🚧 En construcción',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}