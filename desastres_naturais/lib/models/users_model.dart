class Usuario {
  final String id;
  final String nome;
  final String email;
  final bool emPerigo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.emPerigo = false,
  });

  // Transforma o Objeto em dados para o Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'emPerigo': emPerigo,
    };
  }

  // Transforma os dados do Firebase em um Objeto Usuario
  factory Usuario.fromMap(Map<String, dynamic> map, String docId) {
    return Usuario(
      id: docId,
      nome: map['nome'] ?? 'Usuário Desconhecido',
      email: map['email'] ?? '',
      emPerigo: map['emPerigo'] ?? false,
    );
  }
}