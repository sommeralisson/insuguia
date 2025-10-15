import 'package:flutter/material.dart';

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({super.key});

  Widget _getProtocolContent(BuildContext context, int scenarioId) {
    String title;
    String content;

    switch (scenarioId) {
      case 1:
        title = "Não crítico";
        content =
            "TODO: Detalhar o protocolo para pacientes não críticos, incluindo cálculo de dose total diária (DTD), esquema basal-bolus, e metas glicêmicas.";
        break;
      case 2:
        title = "Gestante";
        content =
            "TODO: Detalhar o protocolo para gestantes. Metas glicêmicas mais rigorosas. Insulinas seguras na gestação.";
        break;
      case 3:
        title = "Paciente Crítico";
        content =
            "TODO: Detalhar o protocolo para pacientes críticos. Terapia com bomba de infusão contínua (BIC) de insulina endovenosa.";
        break;
      case 4:
        title = "Cuidados Paliativos";
        content =
            "TODO: Detalhar o protocolo para cuidados paliativos. Foco em evitar hipoglicemia sintomática. Metas glicêmicas mais permissivas.";
        break;
      case 5:
        title = "Perioperatório";
        content =
            "TODO: Detalhar o protocolo para o período perioperatório. Manejo da insulina no pré, intra e pós-operatório.";
        break;
      default:
        title = "Cenário Inválido";
        content = "Nenhum cenário foi selecionado ou o cenário é inválido.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Divider(height: 30),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/prescricao');
          },
          child: const Text('Gerar Prescrição'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final scenarioId = args?['scenarioId'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Protocolo — Cenário $scenarioId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _getProtocolContent(context, scenarioId),
          ),
        ),
      ),
    );
  }
}
