class Medico {
  int? id;
  String nome;
  String email;
  String senha;

  Medico({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'email': email,
    'senha': senha,
  };

  factory Medico.fromMap(Map<String, dynamic> map) => Medico(
    id: map['id'],
    nome: map['nome'],
    email: map['email'],
    senha: map['senha'],
  );
}
