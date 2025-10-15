import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _pesoController = TextEditingController(text: '70');
  final _alturaController = TextEditingController(text: '165');

  String? _selectedSex = 'M';
  String? _selectedLocation = 'Enfermaria';
  int? _selectedScenario;
  String _imcResult = '';
  String _tfgResult = '';

  @override
  void initState() {
    super.initState();
    _pesoController.addListener(_calculateBasics);
    _alturaController.addListener(_calculateBasics);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateBasics());
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _calculateBasics() {
    final double peso = double.tryParse(_pesoController.text) ?? 0;
    final double alturaCm = double.tryParse(_alturaController.text) ?? 0;

    if (peso > 0 && alturaCm > 0) {
      final double alturaM = alturaCm / 100;
      final double imc = peso / (alturaM * alturaM);
      setState(() {
        _imcResult = imc.toStringAsFixed(1);
      });
    } else {
      setState(() => _imcResult = '');
    }

    setState(() {
      _tfgResult = '124';
    });
  }

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
          content: Text(
            'Por favor, selecione uma classificação clínica para avançar.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro do Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dados do Paciente',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Sexo'),
                        initialValue: _selectedSex,
                        items: const [
                          DropdownMenuItem(
                            value: 'M',
                            child: Text('Masculino'),
                          ),
                          DropdownMenuItem(value: 'F', child: Text('Feminino')),
                        ],
                        onChanged: (value) {
                          _selectedSex = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Idade (anos)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pesoController,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _alturaController,
                        decoration: const InputDecoration(
                          labelText: 'Altura (cm)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Creatinina (mg/dL)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Local de internação',
                        ),
                        value: _selectedLocation,
                        items: const [
                          DropdownMenuItem(
                            value: 'Enfermaria',
                            child: Text('Enfermaria'),
                          ),
                          DropdownMenuItem(value: 'UTI', child: Text('UTI')),
                          DropdownMenuItem(
                            value: 'Centro cirúrgico',
                            child: Text('Centro cirúrgico'),
                          ),
                          DropdownMenuItem(
                            value: 'Obstetrícia',
                            child: Text('Obstetrícia'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedLocation = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'IMC: $_imcResult kg/m²',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'TFG: $_tfgResult mL/min/1,73m²',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dados salvos para as próximas telas.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 40),
                Text(
                  'Classificação Clínica',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(5, (index) {
                    final scenarioNum = index + 1;
                    final titles = [
                      'Não crítico',
                      'Gestante',
                      'Crítico',
                      'Paliativos',
                      'Perioperatório',
                    ];
                    return ChoiceChip(
                      label: Text('$scenarioNum) ${titles[index]}'),
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedScenario == scenarioNum
                            ? Colors.white
                            : Colors.black,
                      ),
                      selected: _selectedScenario == scenarioNum,
                      onSelected: (selected) => setState(
                        () => _selectedScenario = selected ? scenarioNum : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _advanceToProtocol,
                  child: const Text('Avançar para Protocolo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
