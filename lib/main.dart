import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/annuncio.dart';
import 'providers/auth_provider.dart';
import 'screens/annuncio_detail_screen.dart';
import 'services/api_client.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<ApiClient>(),
          ),
        ),
      ],
      child: const BachecaLavoroApp(),
    ),
  );
}

class BachecaLavoroApp extends StatelessWidget {
  const BachecaLavoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca lavoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  late final ApiClient _api;
  late Future<List<Annuncio>> _annunci;

  @override
  void initState() {
    super.initState();

    _api = context.read<ApiClient>();
    _annunci = _api.getAnnunci();
  }

  void _ricarica() {
    setState(() {
      _annunci = _api.getAnnunci();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca lavoro'),
        actions: [
          IconButton(
            onPressed: _ricarica,
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna annunci',
          ),
        ],
      ),
      body: FutureBuilder<List<Annuncio>>(
        future: _annunci,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Impossibile caricare gli annunci. '
                      'Controlla la connessione al server.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _ricarica,
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          final annunci = snapshot.data!;

          if (annunci.isEmpty) {
            return const Center(child: Text('Nessun annuncio disponibile.'));
          }

          return ListView.builder(
            itemCount: annunci.length,
            itemBuilder: (context, index) {
              final annuncio = annunci[index];

              return ListTile(
                title: Text(annuncio.titolo),
                subtitle: Text(
                  annuncio.descrizione,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) {
                        return AnnuncioDetailScreen(annuncio: annuncio);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
