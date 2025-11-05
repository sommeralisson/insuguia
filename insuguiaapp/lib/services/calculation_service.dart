import 'dart:math';

class CalcResult {
  final double tdd;
  final double basal;
  final double prandial;
  final double basalRounded;
  final double prandialPerMealRounded;
  final int fs;

  CalcResult({
    required this.tdd,
    required this.basal,
    required this.prandial,
    required this.basalRounded,
    required this.prandialPerMealRounded,
    required this.fs,
  });
}

class CalculationService {
  static int fatorSensibilidadeCoef(String sensibilidade) {
    if (sensibilidade == 'sensivel') return 80;
    if (sensibilidade == 'resistente') return 20;
    return 40; // usual
  }

  static double fatorTDD(String sensibilidade) {
    if (sensibilidade == 'sensivel') return 0.25;
    if (sensibilidade == 'resistente') return 0.6;
    return 0.4;
  }

  static double roundNearest(double x, double step) =>
      (x / step).roundToDouble() * step;

  static CalcResult calcular({
    required double peso,
    required String sensibilidade,
    required String dieta,
    required String corticoide,
    required double step,
  }) {
    double tdd = peso * fatorTDD(sensibilidade);

    if (corticoide == 'pred_baixa') tdd *= 1.05;
    if (corticoide == 'pred_media') tdd *= 1.10;
    if (corticoide == 'pred_alta') tdd *= 1.15;

    double basal = 0, prandial = 0;
    if (dieta == 'oral') {
      basal = tdd * 0.5;
      prandial = tdd * 0.5;
    } else if (dieta == 'npo' || dieta == 'enteral') {
      basal = tdd * 0.75;
      prandial = 0;
    }

    double basalRounded = roundNearest(basal, step);
    double prandialPerMeal = prandial > 0
        ? roundNearest(prandial / 3, step)
        : 0;

    return CalcResult(
      tdd: tdd,
      basal: basal,
      prandial: prandial,
      basalRounded: basalRounded,
      prandialPerMealRounded: prandialPerMeal,
      fs: fatorSensibilidadeCoef(sensibilidade),
    );
  }
}
