import 'package:flutter/material.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  int? _selectedScenario;

  void _advanceToProtocol() {
    if (_selectedScenario != null) {
      Navigator.pushNamed(
        context,
        '/protocolo',
        arguments: {'scenarioId': _selectedScenario!},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um cenário para continuar.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = [
      'Não crítico (Diabetes mellitus prévio/Hiperglicemia hospitalar)',
      'Gestante (Diabetes mellitus prévio/Diabetes mellitus gestacional)',
      'Paciente crítico',
      'Cuidados paliativos',
      'Perioperatório',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Classificação Clínica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Classificação Clínica',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scenarios.length,
                  itemBuilder: (context, index) {
                    final scenarioId = index + 1;
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedScenario == scenarioId
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        side: BorderSide(
                          color: _selectedScenario == scenarioId
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedScenario = scenarioId;
                        });
                      },
                      child: Text(
                        '${scenarioId}) ${scenarios[index]}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('‹ Voltar'),
                    ),
                    ElevatedButton(
                      onPressed: _advanceToProtocol,
                      child: const Text('Avançar para Protocolo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
