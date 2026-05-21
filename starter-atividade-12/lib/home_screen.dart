import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';
import 'new_pokemon_screen.dart';
import 'trainer_profile_screen.dart';
import 'type_chip.dart';

Future<int?> _loadAvatarIndex() async {
  final doc = await FirebaseFirestore.instance
      .collection('config')
      .doc('treinador')
      .get();
  if (!doc.exists) return null;
  return doc.data()?['avatarIndex'] as int?;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final collection = FirebaseFirestore.instance.collection('pokemons');
  late Future<int?> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatarIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pokédex', style: TextStyle(fontSize: 18)),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<int?>(
            future: _avatarFuture,
            builder: (context, snapshot) {
              final index = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () async {
                  final selected = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrainerProfileScreen()),
                  );
                  if (selected != null) {
                    setState(() { _avatarFuture = Future.value(selected); });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    'assets/trainers/trainer_${index + 1}.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewPokemonScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon cadastrado.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final pokemon = Pokemon.fromDoc(docs[index]);
              return Card(
                child: ListTile(
                  leading: ClipOval(
                    child: pokemon.spriteUrl.isNotEmpty
                        ? Image.network(
                            pokemon.spriteUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.deepPurple.shade100,
                              child: const Icon(Icons.catching_pokemon),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: Colors.deepPurple.shade100,
                            child: const Icon(Icons.catching_pokemon),
                          ),
                  ),
                  title: Text(pokemon.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pokemon.types.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Row(
                            children: List.generate(
                              pokemon.types.length,
                              (i) => typeChip(pokemon.types[i]),
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Text('Nível ${pokemon.level}'),
                          if (pokemon.hasLocation) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.place,
                              size: 14,
                              color: Colors.deepPurple.shade400,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                    onPressed: () => collection.doc(docId).delete(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PokemonScreen(pokemon: pokemon, docId: docId),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
