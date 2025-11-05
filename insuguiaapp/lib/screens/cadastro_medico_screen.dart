import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Importe para capturar exceções do DB
import '../data/medico_repository.dart'; // Verifique se este caminho está correto
import '../models/medico.dart';

class CadastroMedicoScreen extends StatefulWidget {
  const CadastroMedicoScreen({super.key});

  @override
  State<CadastroMedicoScreen> createState() => _CadastroMedicoScreenState();
}

class _CadastroMedicoScreenState extends State<CadastroMedicoScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _repo = MedicoRepository();
  String? _msg;
  bool _isLoading = false; // Para mostrar o loading

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    if (_isLoading) return; // Evita cliques duplicados

    if (_nomeCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _senhaCtrl.text.isEmpty) {
      setState(() => _msg = 'Preencha todos os campos');
      return;
    }

    setState(() {
      _isLoading = true;
      _msg = null; // Limpa mensagens antigas
    });

    try {
      await _repo.cadastrar(
        Medico(
          nome: _nomeCtrl.text,
          email: _emailCtrl.text.trim().toLowerCase(),
          senha: _senhaCtrl.text, // Idealmente, a senha deve ser criptografada
        ),
      );

      // Se chegou aqui, o cadastro funcionou
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Retorna para a tela de login
      }
    } on DatabaseException catch (e) {
      // Erro específico do banco de dados
      if (e.isUniqueConstraintError()) {
        setState(() => _msg = 'Este e-mail já está cadastrado.');
      } else {
        setState(() => _msg = 'Erro no banco de dados: ${e.toString()}');
      }
    } catch (e) {
      // Outros erros
      setState(() => _msg = 'Ocorreu um erro: ${e.toString()}');
    } finally {
      // Garante que o loading pare, mesmo se der erro
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Médico')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        // Use SingleChildScrollView para evitar overflow em telas pequenas
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome completo'),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _senhaCtrl,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: _cadastrar,
                // Mostra um loading ou o texto
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text('Cadastrar'),
              ),
              if (_msg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  // Mensagem de erro em vermelho, sucesso em verde
                  child: Text(
                    _msg!,
                    style: TextStyle(
                      color:
                          _msg!.startsWith('Erro') ||
                              _msg!.startsWith('Este e-mail')
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
