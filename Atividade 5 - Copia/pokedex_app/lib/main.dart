import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Popula o Firestore com dados iniciais (não bloqueia o app)
  _seedPokemons();

  runApp(const MyApp());
}

void _seedPokemons() async {
  try {
    final collection = FirebaseFirestore.instance.collection('pokemons');
    
    // Dados para inserir
    final pokemonsData = [
      {
        'name': 'Charizard',
        'spriteId': 6,
        'level': 38,
        'types': ['Fire', 'Flying'],
        'moves': ['Flamethrower', 'Fly', 'Slash', 'Dragon Rage'],
      },
      {
        'name': 'Mewtwo',
        'spriteId': 150,
        'level': 70,
        'types': ['Psychic'],
        'moves': ['Psystrike', 'Shadow Ball', 'Aura Sphere', 'Ice Beam'],
      },
      {
        'name': 'Eevee',
        'spriteId': 133,
        'level': 15,
        'types': ['Normal'],
        'moves': ['Tackle', 'Sand Attack', 'Quick Attack', 'Bite'],
      },
    ];

    for (final data in pokemonsData) {
      // Verifica se o Pokemon já existe pelo nome para não duplicar
      final query = await collection.where('name', isEqualTo: data['name']).get();
      
      if (query.docs.isEmpty) {
        await collection.add(data);
        debugPrint('✅ Adicionado: ${data['name']}');
      } else {
        debugPrint('ℹ️ ${data['name']} já existe no Firestore.');
      }
    }

    debugPrint('✨ Verificação de dados concluída!');
  } catch (e) {
    debugPrint('❌ Erro ao popular Firestore: $e');
    // Se der erro de permissão, avise o usuário
    if (e.toString().contains('permission-denied')) {
      debugPrint('🚨 ATENÇÃO: As REGRAS do Firestore no Console podem estar bloqueando o acesso.');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
