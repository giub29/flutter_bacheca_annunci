import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _invioInCorso = false;
  String? _errore;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _accedi() async {
    if (_invioInCorso) return;
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    setState(() {
      _invioInCorso = true;
      _errore = null;
    });

    try {
      await auth.login(
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
        'Impossibile completare il login. '
            'Controlla la connessione e riprova.';
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
        title: const Text('Accesso azienda'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _email,
              enabled: !_invioInCorso,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (valore) {
                if (valore == null || valore.trim().isEmpty) {
                  return 'Inserisci l’email.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              enabled: !_invioInCorso,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              validator: (valore) {
                if (valore == null || valore.isEmpty) {
                  return 'Inserisci la password.';
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
              onPressed: _invioInCorso ? null : _accedi,
              child: _invioInCorso
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              )
                  : const Text('Accedi'),
            ),
          ],
        ),
      ),
    );
  }
}