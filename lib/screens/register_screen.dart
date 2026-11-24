import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _conferma = TextEditingController();

  bool _invio = false;
  String? _errore;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _password.dispose();
    _conferma.dispose();
    super.dispose();
  }

  Future<void> _registra() async {
    if (_invio || !_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();

    setState(() {
      _invio = true;
      _errore = null;
    });

    try {
      await auth.register(
        nome: _nome.text,
        email: _email.text,
        password: _password.text,
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
        'Registrazione non completata. Controlla la connessione '
            'e riprova. Se l’account risulta già creato, usa il login.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _invio = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione azienda'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_errore != null) ...[
              Text(
                _errore!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nome,
              enabled: !_invio,
              decoration: const InputDecoration(
                labelText: 'Nome azienda',
              ),
              validator: (value) {
                final nome = value?.trim() ?? '';

                if (nome.isEmpty) return 'Inserisci il nome azienda.';
                if (nome.length > 100) return 'Massimo 100 caratteri.';

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              enabled: !_invio,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                final pattern =
                RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

                if (!pattern.hasMatch(email)) {
                  return 'Inserisci un’email valida.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              enabled: !_invio,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: '8–64 caratteri, almeno una lettera e un numero.',
              ),
              validator: (value) {
                final pattern =
                RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,64}$');

                if (!pattern.hasMatch(value ?? '')) {
                  return 'La password non rispetta i requisiti.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _conferma,
              enabled: !_invio,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Conferma password',
              ),
              validator: (value) {
                if (value != _password.text) {
                  return 'Le password non coincidono.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _invio ? null : _registra,
              child: Text(
                _invio ? 'Registrazione in corso…' : 'Crea account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}