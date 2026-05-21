import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final _nameController = TextEditingController();
  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] as String? ?? '';
        _selectedAvatar = data['avatarIndex'] as int? ?? 0;
      });
    }
  }

  Future<void> _salvar() async {
    final nome = _nameController.text.trim();
    if (nome.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome deve ter pelo menos 2 caracteres.')),
      );
      return;
    }
    await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .set({'name': nome, 'avatarIndex': _selectedAvatar},
            SetOptions(merge: true));
    if (mounted) Navigator.pop(context, _selectedAvatar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Treinador'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do treinador',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Escolha seu avatar:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (i) {
                final isSelected = _selectedAvatar == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = i),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Colors.deepPurple.shade50
                          : Colors.transparent,
                    ),
                    child: Image.asset(
                      'assets/trainers/trainer_${i + 1}.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Salvar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
