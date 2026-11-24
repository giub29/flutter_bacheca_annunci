import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../models/candidatura.dart';
import '../services/api_client.dart';
import 'candidatura_detail_screen.dart';

class CandidatureScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidatureScreen({super.key, required this.annuncio});

  @override
  State<CandidatureScreen> createState() => _CandidatureScreenState();
}

class _CandidatureScreenState extends State<CandidatureScreen> {
  late final ApiClient _api;
  late Future<List<Candidatura>> _candidature;

  @override
  void initState() {
    super.initState();

    _api = context.read<ApiClient>();
    _candidature = _api.getCandidature(widget.annuncio.id);
  }

  void _ricarica() {
    setState(() {
      _candidature = _api.getCandidature(widget.annuncio.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidature ricevute'),
        actions: [
          IconButton(
            onPressed: _ricarica,
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna candidature',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.annuncio.titolo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Candidatura>>(
              future: _candidature,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  final errore = snapshot.error;

                  final messaggio = errore is ApiException
                      ? errore.message
                      : 'Impossibile caricare le candidature. '
                            'Controlla la connessione al server.';

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(messaggio, textAlign: TextAlign.center),
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

                final candidature = snapshot.data!;

                if (candidature.isEmpty) {
                  return const Center(
                    child: Text('Nessuna candidatura ricevuta.'),
                  );
                }

                return ListView.builder(
                  itemCount: candidature.length,
                  itemBuilder: (context, index) {
                    final candidatura = candidature[index];

                    return ListTile(
                      title: Text('${candidatura.nome} ${candidatura.cognome}'),
                      subtitle: Text(candidatura.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return CandidaturaDetailScreen(
                                candidatura: candidatura,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
