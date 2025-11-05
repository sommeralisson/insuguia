import 'package:flutter/material.dart';
import '../data/medico_repository.dart';
import '../models/medico.dart';
import 'cadastro_medico_screen.dart';
import 'pacientes_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _repo = MedicoRepository();
  String? _erro;

  void _login() async {
    final medico = await _repo.login(_emailCtrl.text, _senhaCtrl.text);
    if (medico != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PacientesScreen(medico: medico)),
      );
    } else {
      setState(() => _erro = 'E-mail ou senha inválidos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('InsuGuia', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 32),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: _senhaCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 16),
            if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('Entrar')),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroMedicoScreen()),
              ),
              child: const Text('Cadastrar novo médico'),
            ),
          ],
        ),
      ),
    );
  }
}
