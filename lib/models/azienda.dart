class Azienda {
  final int id;
  final String nome;
  final String email;

  const Azienda({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory Azienda.fromJson(Map<String, dynamic> json) {
    return Azienda(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }
}