class Prescricao {
  final int? id;
  final int pacienteId;
  final String tipoBasal;
  final double step;
  final double tdd;
  final double basalTotal;
  final double prandialTotal;
  final double prandialPerMeal;
  final String dieta;
  final String corticoide;
  final int doencaHepatica;
  final String classificacaoClinica;
  final String insulinaBasalSchedule;
  final String insulinaRapidaTipo;
  final String bolusPrandial;
  final String notas;
  final String? criadoEm;

  Prescricao({
    this.id,
    required this.pacienteId,
    required this.tipoBasal,
    required this.step,
    required this.tdd,
    required this.basalTotal,
    required this.prandialTotal,
    required this.prandialPerMeal,
    required this.dieta,
    required this.corticoide,
    required this.doencaHepatica,
    required this.classificacaoClinica,
    required this.insulinaBasalSchedule,
    required this.insulinaRapidaTipo,
    required this.bolusPrandial,
    required this.notas,
    this.criadoEm,
  });

  factory Prescricao.fromMap(Map<String, dynamic> map) {
    return Prescricao(
      id: map['id'],
      pacienteId: map['paciente_id'],
      tipoBasal: map['tipo_basal'],
      step: map['step'],
      tdd: map['tdd'],
      basalTotal: map['basal_total'],
      prandialTotal: map['prandial_total'],
      prandialPerMeal: map['prandial_por_refeicao'],
      dieta: map['dieta'],
      corticoide: map['corticoide'],
      doencaHepatica: map['doenca_hepatica'],
      classificacaoClinica: map['classificacao_clinica'],
      insulinaBasalSchedule: map['insulina_basal_schedule'],
      insulinaRapidaTipo: map['insulina_rapida_tipo'],
      bolusPrandial: map['bolus_prandial'],
      notas: map['notas'],
      criadoEm: map['criado_em'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paciente_id': pacienteId,
      'tipo_basal': tipoBasal,
      'step': step,
      'tdd': tdd,
      'basal_total': basalTotal,
      'prandial_total': prandialTotal,
      'prandial_por_refeicao': prandialPerMeal,
      'dieta': dieta,
      'corticoide': corticoide,
      'doenca_hepatica': doencaHepatica,
      'classificacao_clinica': classificacaoClinica,
      'insulina_basal_schedule': insulinaBasalSchedule,
      'insulina_rapida_tipo': insulinaRapidaTipo,
      'bolus_prandial': bolusPrandial,
      'notas': notas,
    };
  }
}
