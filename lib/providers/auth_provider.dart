import 'package:flutter/foundation.dart';
import '../models/azienda.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;

  Azienda? _azienda;

  AuthProvider(this._api);

  Azienda? get azienda => _azienda;

  bool get isLoggedIn => _azienda != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final dati = await _api.login(
      email: email,
      password: password,
    );

    final azienda = Azienda.fromJson(
      dati['azienda'] as Map<String, dynamic>,
    );

    final token = dati['token'] as String;

    _api.token = token;
    _azienda = azienda;

    notifyListeners();
  }

  Future<void> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    await _api.registraAzienda(
      nome: nome,
      email: email,
      password: password,
    );
  }
}