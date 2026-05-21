import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mensagemErro(String code) => switch (code) {
        'invalid-email' => 'E-mail inválido.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'weak-password' => 'Senha muito fraca. Use pelo menos 6 caracteres.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        'network-request-failed' => 'Sem conexão com a internet.',
        _ => 'Erro inesperado. Tente novamente.',
      };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mensagemErro(e.code));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: const Icon(
                    Icons.catching_pokemon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Liga Pokémon' : 'Registro de Treinador',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Entre com sua conta de treinador'
                      : 'Crie sua conta de treinador',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                    if (!v.contains('@')) return 'E-mail inválido.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha.';
                    if (!_isLogin && v.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: Text(
                          _isLogin ? 'Entrar' : 'Registrar',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _isLogin = !_isLogin;
                    _error = null;
                    _formKey.currentState?.reset();
                  }),
                  child: Text(
                    _isLogin
                        ? 'Novo treinador? Registrar'
                        : 'Já tem conta? Entrar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
