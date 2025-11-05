class Glicemia {
  int? id;
  int pacienteId;
  int valor;
  String horario;
  String tipo;

  Glicemia({
    this.id,
    required this.pacienteId,
    required this.valor,
    required this.horario,
    required this.tipo,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'paciente_id': pacienteId,
    'valor': valor,
    'horario': horario,
    'tipo': tipo,
  };

  factory Glicemia.fromMap(Map<String, dynamic> map) => Glicemia(
    id: map['id'],
    pacienteId: map['paciente_id'],
    valor: map['valor'],
    horario: map['horario'],
    tipo: map['tipo'],
  );
}
