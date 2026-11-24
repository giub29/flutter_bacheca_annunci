import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../services/api_client.dart';
import '../services/cv_picker_service.dart';

class CandidaturaFormScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidaturaFormScreen({super.key, required this.annuncio});

  @override
  State<CandidaturaFormScreen> createState() => _CandidaturaFormScreenState();
}

class _CandidaturaFormScreenState extends State<CandidaturaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();

  final _cvPicker = CvPickerService();

  CvSelezionato? _cv;
  bool _occupato = false;
  String? _errore;

  String? _campoObbligatorio(String? valore) {
    if (valore == null || valore.trim().isEmpty) {
      return 'Campo obbligatorio.';
    }

    return null;
  }

  Future<void> _selezionaCv() async {
    setState(() {
      _occupato = true;
      _errore = null;
    });

    try {
      final cv = await _cvPicker.seleziona();

      if (!mounted) return;

      if (cv != null) {
        setState(() {
          _cv = cv;
        });
      }
    } on FormatException catch (errore) {
      if (!mounted) return;

      setState(() {
        _errore = errore.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errore = 'Impossibile leggere il PDF. Riprova.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _occupato = false;
        });
      }
    }
  }

  Future<void> _invia() async {
    if (!_formKey.currentState!.validate()) return;

    final cv = _cv;

    if (cv == null) {
      setState(() {
        _errore = 'Seleziona il curriculum in formato PDF.';
      });
      return;
    }

    final api = context.read<ApiClient>();

    setState(() {
      _occupato = true;
      _errore = null;
    });

    try {
      await api.inviaCandidatura(
        annuncioId: widget.annuncio.id,
        nome: _nomeController.text,
        cognome: _cognomeController.text,
        email: _emailController.text,
        cvNomeOriginale: cv.nome,
        cvBytes: cv.bytes,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on ApiException catch (errore) {
      if (!mounted) return;

      setState(() {
        _errore = errore.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errore =
            'Non è stato possibile confermare l’invio. '
            'La candidatura potrebbe essere stata ricevuta: '
            'un nuovo tentativo potrebbe duplicarla.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _occupato = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invia candidatura')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              widget.annuncio.titolo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nomeController,
              enabled: !_occupato,
              decoration: const InputDecoration(labelText: 'Nome'),
              maxLength: 100,
              validator: _campoObbligatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cognomeController,
              enabled: !_occupato,
              decoration: const InputDecoration(labelText: 'Cognome'),
              maxLength: 100,
              validator: _campoObbligatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              enabled: !_occupato,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              maxLength: 254,
              validator: _campoObbligatorio,
            ),
            const SizedBox(height: 24),
            const Text('Curriculum PDF — massimo 5 MiB'),
            const SizedBox(height: 8),
            Text(_cv?.nome ?? 'Nessun file selezionato.'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _occupato ? null : _selezionaCv,
              child: const Text('Seleziona PDF'),
            ),
            const SizedBox(height: 16),
            if (_errore != null) ...[
              Text(
                _errore!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
            ],
            if (_occupato) const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _occupato ? null : _invia,
              child: const Text('Invia candidatura'),
            ),
          ],
        ),
      ),
    );
  }
}
