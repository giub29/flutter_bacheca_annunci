import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';

class CvOpenService {
  final ApiClient _api;

  CvOpenService(this._api);

  Future<void> apri(int candidaturaId) async {
    final bytes = await _api.scaricaCv(candidaturaId);

    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/cv-$candidaturaId.pdf');

    await file.writeAsBytes(bytes, flush: true);

    final risultato = await OpenFilex.open(file.path, type: 'application/pdf');

    if (risultato.type == ResultType.noAppToOpen) {
      throw const CvOpenException(
        'Sul dispositivo non è disponibile un’app '
        'per aprire i PDF.',
      );
    }

    if (risultato.type != ResultType.done) {
      throw const CvOpenException(
        'Non è stato possibile aprire il curriculum.',
      );
    }
  }
}

class CvOpenException implements Exception {
  final String message;

  const CvOpenException(this.message);

  @override
  String toString() => message;
}
