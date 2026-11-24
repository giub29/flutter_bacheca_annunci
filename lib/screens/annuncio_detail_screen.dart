import 'package:flutter/material.dart';

import '../models/annuncio.dart';

class AnnuncioDetailScreen extends StatelessWidget {
  final Annuncio annuncio;

  const AnnuncioDetailScreen({
    super.key,
    required this.annuncio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio annuncio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            annuncio.titolo,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(annuncio.descrizione),
        ],
      ),
    );
  }
}