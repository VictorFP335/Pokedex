import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pokemon.dart';
import 'type_chip.dart';
import 'battle_provider.dart';
import 'stat_bar.dart';

class PokemonScreen extends StatelessWidget {
  final Pokemon pokemon;
  final String docId;

  const PokemonScreen({super.key, required this.pokemon, required this.docId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BattleProvider(
        pokemonName: pokemon.name,
        level: pokemon.level,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(pokemon.name),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PokemonCard(pokemon: pokemon),
              const SizedBox(height: 16),
              LocationCard(pokemon: pokemon),
              const SizedBox(height: 16),
              BattlePanel(docId: docId),
            ],
          ),
        ),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final level = context.select((BattleProvider p) => p.level);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                pokemon.spriteUrl,
                width: 72,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.deepPurple.shade100,
                  child: const Icon(Icons.catching_pokemon, size: 36),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pokemon.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nível $level',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple.shade400,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    pokemon.types.length,
                    (i) => typeChip(pokemon.types[i]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final Pokemon pokemon;

  const LocationCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              pokemon.hasLocation ? Icons.place : Icons.location_off,
              color: pokemon.hasLocation
                  ? Colors.deepPurple
                  : Colors.grey.shade500,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local da captura',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pokemon.hasLocation
                        ? '${pokemon.latitude!.toStringAsFixed(4)}°, '
                            '${pokemon.longitude!.toStringAsFixed(4)}°'
                        : 'Localização não registrada',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BattlePanel extends StatelessWidget {
  final String docId;

  const BattlePanel({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    final battle = context.watch<BattleProvider>();
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            StatBar(label: 'HP', value: battle.hp, maxValue: 100, color: battle.hpColor),
            StatBar(label: 'XP', value: battle.xp, maxValue: 100, color: Colors.blue),
            if (battle.statusMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                battle.statusMessage,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: battle.hp > 0 ? () => context.read<BattleProvider>().attack() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Atacar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: battle.hp < 100 ? () => context.read<BattleProvider>().heal() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Usar Poção'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final currentLevel = context.read<BattleProvider>().level;
                  await FirebaseFirestore.instance
                      .collection('pokemons')
                      .doc(docId)
                      .update({'level': currentLevel});
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Encerrar Batalha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
