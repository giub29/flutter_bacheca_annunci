import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../providers/auth_provider.dart';
import 'candidatura_form_screen.dart';

class AnnuncioDetailScreen extends StatelessWidget {
  final Annuncio annuncio;

  const AnnuncioDetailScreen({super.key, required this.annuncio});

  Future<void> _apriCandidatura(BuildContext context) async {
    final inviata = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) {
          return CandidaturaFormScreen(annuncio: annuncio);
        },
      ),
    );

    if (!context.mounted) return;

    if (inviata == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidatura inviata con successo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            annuncio.titolo,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(annuncio.descrizione),
          const SizedBox(height: 32),
          if (!auth.isLoggedIn)
            ElevatedButton(
              onPressed: () => _apriCandidatura(context),
              child: const Text('Candidati'),
            )
          else
            const Text(
              'Hai effettuato l’accesso come azienda. '
              'Per candidarti come visitatore, effettua il logout.',
            ),
        ],
      ),
    );
  }
}
