import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';

class AnnuncioFormScreen extends StatefulWidget {
  const AnnuncioFormScreen({super.key});

  @override
  State<AnnuncioFormScreen> createState() => _AnnuncioFormScreenState();
}

class _AnnuncioFormScreenState extends State<AnnuncioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titolo = TextEditingController();
  final _descrizione = TextEditingController();

  bool _invioInCorso = false;
  String? _errore;

  @override
  void dispose() {
    _titolo.dispose();
    _descrizione.dispose();
    super.dispose();
  }

  Future<void> _pubblica() async {
    if (_invioInCorso) return;
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<ApiClient>();

    setState(() {
      _invioInCorso = true;
      _errore = null;
    });

    try {
      await api.creaAnnuncio(
        titolo: _titolo.text,
        descrizione: _descrizione.text,
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
        'Impossibile confermare la pubblicazione. '
            'Controlla la connessione e verifica i tuoi annunci '
            'prima di riprovare.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _invioInCorso = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo annuncio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titolo,
              enabled: !_invioInCorso,
              decoration: const InputDecoration(
                labelText: 'Titolo',
              ),
              validator: (valore) {
                final testo = valore?.trim() ?? '';

                if (testo.isEmpty) {
                  return 'Inserisci il titolo.';
                }

                if (testo.length > 100) {
                  return 'Il titolo può contenere al massimo 100 caratteri.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descrizione,
              enabled: !_invioInCorso,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                alignLabelWithHint: true,
              ),
              validator: (valore) {
                final testo = valore?.trim() ?? '';

                if (testo.isEmpty) {
                  return 'Inserisci la descrizione.';
                }

                if (testo.length > 5000) {
                  return 'La descrizione può contenere al massimo 5000 caratteri.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_errore != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errore!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _invioInCorso ? null : _pubblica,
              child: _invioInCorso
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              )
                  : const Text('Pubblica'),
            ),
          ],
        ),
      ),
    );
  }
}