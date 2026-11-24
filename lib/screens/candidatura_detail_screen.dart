import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/candidatura.dart';
import '../services/api_client.dart';
import '../services/cv_open_service.dart';

class CandidaturaDetailScreen extends StatefulWidget {
  final Candidatura candidatura;

  const CandidaturaDetailScreen({super.key, required this.candidatura});

  @override
  State<CandidaturaDetailScreen> createState() =>
      _CandidaturaDetailScreenState();
}

class _CandidaturaDetailScreenState extends State<CandidaturaDetailScreen> {
  bool _aperturaInCorso = false;
  String? _errore;

  Future<void> _apriCv() async {
    if (_aperturaInCorso) return;

    final servizio = CvOpenService(context.read<ApiClient>());

    setState(() {
      _aperturaInCorso = true;
      _errore = null;
    });

    try {
      await servizio.apri(widget.candidatura.id);
    } on ApiException catch (errore) {
      if (!mounted) return;

      setState(() {
        _errore = errore.message;
      });
    } on CvOpenException catch (errore) {
      if (!mounted) return;

      setState(() {
        _errore = errore.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errore =
            'Impossibile scaricare o aprire il curriculum. '
            'Controlla la connessione e riprova.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _aperturaInCorso = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidatura = widget.candidatura;

    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio candidatura')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '${candidatura.nome} ${candidatura.cognome}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const Text('Email'),
          const SizedBox(height: 4),
          SelectableText(candidatura.email),
          const SizedBox(height: 24),
          const Text('Curriculum'),
          const SizedBox(height: 4),
          Text(candidatura.cvNomeOriginale),
          const SizedBox(height: 4),
          Text('${(candidatura.cvDimensione / 1024).toStringAsFixed(1)} KiB'),
          const SizedBox(height: 24),
          if (_errore != null) ...[
            Text(
              _errore!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          if (_aperturaInCorso) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _aperturaInCorso ? null : _apriCv,
            child: const Text('Apri CV'),
          ),
        ],
      ),
    );
  }
}
