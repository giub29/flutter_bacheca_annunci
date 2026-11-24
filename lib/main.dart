import 'package:flutter/material.dart';
import 'services/api_client.dart';

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

class BachecaScreen extends StatefulWidget {
  const BachecaScreen({super.key});

  @override
  State<BachecaScreen> createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  final ApiClient _api = ApiClient();
  late Future<bool> _connessione;

  @override
  void initState() {
    super.initState();
    _connessione = _api.verificaConnessione();
  }

  void _riprova() {
    setState(() {
      _connessione = _api.verificaConnessione();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca lavoro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<bool>(
            future: _connessione,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Impossibile verificare la connessione. '
                          'Controlla che il server sia avviato.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _riprova,
                      child: const Text('Riprova'),
                    ),
                  ],
                );
              }

              return const Text(
                'Connessione al server riuscita.\n'
                    'Gli annunci di lavoro saranno mostrati qui.',
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ),
    );
  }
}

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