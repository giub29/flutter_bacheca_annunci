import 'package:file_picker/file_picker.dart';

class CvSelezionato {
  final String nome;
  final List<int> bytes;

  const CvSelezionato({
    required this.nome,
    required this.bytes,
  });
}

class CvPickerService {
  Future<CvSelezionato?> seleziona() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (file == null) {
      return null;
    }

    const maxBytes = 5 * 1024 * 1024;

    final dimensione = await file.length();

    if (dimensione != null && dimensione > maxBytes) {
      throw const FormatException(
        'Il curriculum supera il limite di 5 MiB.',
      );
    }

    if (!file.name.toLowerCase().endsWith('.pdf')) {
      throw const FormatException(
        'Seleziona un file PDF.',
      );
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw const FormatException(
        'Il curriculum selezionato è vuoto.',
      );
    }

    if (bytes.length > maxBytes) {
      throw const FormatException(
        'Il curriculum supera il limite di 5 MiB.',
      );
    }

    return CvSelezionato(
      nome: file.name,
      bytes: bytes,
    );
  }
}