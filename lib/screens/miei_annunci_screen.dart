import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/annuncio.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import 'annuncio_form_screen.dart';

class MieiAnnunciScreen extends StatefulWidget {
  const MieiAnnunciScreen({super.key});

  @override
  State<MieiAnnunciScreen> createState() => _MieiAnnunciScreenState();
}

class _MieiAnnunciScreenState extends State<MieiAnnunciScreen> {
  late final ApiClient _api;
  late Future<List<Annuncio>> _annunci;

  @override
  void initState() {
    super.initState();

    _api = context.read<ApiClient>();
    _annunci = _api.getMieiAnnunci();
  }

  void _ricarica() {
    setState(() {
      _annunci = _api.getMieiAnnunci();
    });
  }

  Future<void> _apriNuovoAnnuncio() async {
    final pubblicato = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => const AnnuncioFormScreen(),
      ),
    );

    if (!mounted) return;

    if (pubblicato == true) {
      _ricarica();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annuncio pubblicato.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Area azienda'),
        ),
        body: const Center(
          child: Text('Effettua il login per accedere.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei annunci'),
        actions: [
          IconButton(
            onPressed: _ricarica,
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna i miei annunci',
          ),
          IconButton(
            onPressed: _apriNuovoAnnuncio,
            icon: const Icon(Icons.add),
            tooltip: 'Nuovo annuncio',
          ),
        ],
      ),
      body: FutureBuilder<List<Annuncio>>(
        future: _annunci,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            final errore = snapshot.error;

            final messaggio = errore is ApiException
                ? errore.message
                : 'Impossibile caricare i tuoi annunci.';

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messaggio,
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
            return const Center(
              child: Text('Non hai ancora pubblicato annunci.'),
            );
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
              );
            },
          );
        },
      ),
    );
  }
}