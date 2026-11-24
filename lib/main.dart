import 'package:flutter/material.dart';

void main() {
  runApp(const BachecaLavoroApp());
}

class BachecaLavoroApp extends StatelessWidget {
  const BachecaLavoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca lavoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const BachecaScreen(),
    );
  }
}

class BachecaScreen extends StatelessWidget {
  const BachecaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca lavoro'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Gli annunci di lavoro saranno mostrati qui.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}