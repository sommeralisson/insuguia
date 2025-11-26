import 'dart:math';

class CalcResult {
  final double tdd;
  final double basalRounded;
  final double prandialTotal;
  final double prandialRef;
  final double step;
  final int fatorSensibilidade;

  final String description;

  CalcResult({
    required this.tdd,
    required this.basalRounded,
    required this.prandialTotal,
    required this.prandialRef,
    required this.step,
    required this.fatorSensibilidade,
    this.description = '',
  });
}

class CalculationService {
  static CalcResult calcular({
    required double peso,
    required String sensibilidade,
    required String dieta,
    required String corticoide,
    required bool doencaHepatica,
    double step = 1,
  }) {
    double fatorPeso = 0.45;
    int fs = 40;

    if (sensibilidade == 'sensivel') {
      fatorPeso = 0.25;
      fs = 80;
    } else if (sensibilidade == 'resistente') {
      fatorPeso = 0.70;
      fs = 20;
    }

    double tdd = peso * fatorPeso;

    if (doencaHepatica) {
      tdd = tdd * 0.80;
    }

    double cortBoost = 0.0;
    switch (corticoide) {
      case 'pred_baixa':
        cortBoost = 0.05;
        break;
      case 'pred_media':
        cortBoost = 0.10;
        break;
      case 'pred_alta':
        cortBoost = 0.15;
        break;
    }

    double basal = 0;
    double prandialTotal = 0;
    double prandialRef = 0;

    if (dieta == 'oral' || dieta == 'oral_ba') {
      basal = tdd * 0.5;
      prandialTotal = (tdd * 0.5) * (1 + cortBoost);
      prandialRef = prandialTotal / 3;
    } else if (dieta == 'oral_ma') {
      basal = tdd * 0.6;
      prandialTotal = (tdd * 0.4) * (1 + cortBoost);
      prandialRef = 0;
    } else if (dieta == 'enteral') {
      basal = tdd * 0.5;
      prandialTotal = (tdd * 0.5) * (1 + cortBoost);
      prandialRef = prandialTotal / 4;
    } else {
      basal = tdd * 0.75;
      prandialTotal = 0;
      prandialRef = 0;
    }

    double roundTo(double value) {
      if (step == 2) {
        return (value / step).ceil() * step;
      }
      return ((value / step).round()) * step;
    }

    return CalcResult(
      tdd: tdd,
      basalRounded: roundTo(basal),
      prandialTotal: prandialTotal,
      prandialRef: roundTo(prandialRef),
      step: step,
      fatorSensibilidade: fs,
    );
  }

  static double calculateCKDEPI(double creatinina, int idade, String sexo) {
    if (creatinina <= 0) return 0;
    double k = (sexo == 'F') ? 0.7 : 0.9;
    double a = (sexo == 'F') ? -0.241 : -0.302;
    double minPart = min(creatinina / k, 1);
    double maxPart = max(creatinina / k, 1);

    double eGFR =
        142 *
        pow(minPart, a) *
        pow(maxPart, -1.200) *
        pow(0.9938, idade) *
        ((sexo == 'F') ? 1.012 : 1);

    return eGFR;
  }
}
