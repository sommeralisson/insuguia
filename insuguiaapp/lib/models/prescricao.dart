class Prescricao {
  int? id;
  int pacienteId;
  String tipoBasal;
  String? posologiaNph;
  String? insulinaRapida;
  double step;
  double tdd;
  double basalTotal;
  double prandialTotal;
  String? notas;

  Prescricao({
    this.id,
    required this.pacienteId,
    required this.tipoBasal,
    this.posologiaNph,
    this.insulinaRapida,
    required this.step,
    required this.tdd,
    required this.basalTotal,
    required this.prandialTotal,
    this.notas,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'paciente_id': pacienteId,
    'tipo_basal': tipoBasal,
    'posologia_nph': posologiaNph,
    'insulina_rapida': insulinaRapida,
    'step': step,
    'tdd': tdd,
    'basal_total': basalTotal,
    'prandial_total': prandialTotal,
    'notas': notas,
  };

  factory Prescricao.fromMap(Map<String, dynamic> map) => Prescricao(
    id: map['id'],
    pacienteId: map['paciente_id'],
    tipoBasal: map['tipo_basal'],
    posologiaNph: map['posologia_nph'],
    insulinaRapida: map['insulina_rapida'],
    step: (map['step'] as num).toDouble(),
    tdd: (map['tdd'] as num).toDouble(),
    basalTotal: (map['basal_total'] as num).toDouble(),
    prandialTotal: (map['prandial_total'] as num).toDouble(),
    notas: map['notas'],
  );
}
