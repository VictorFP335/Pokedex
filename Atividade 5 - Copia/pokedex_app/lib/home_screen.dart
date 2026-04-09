import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pokemons = [
    Pokemon(
      name: 'Gengar',
      spriteId: 94,
      typeIds: [8, 4],
      level: 42,
      moves: ['Hypnosis', 'Dream Eater', 'Shadow Ball', 'Lick'],
    ),
    Pokemon(
      name: 'Charizard',
      spriteId: 6,
      typeIds: [10, 3],
      level: 38,
      moves: ['Flamethrower', 'Fly', 'Slash', 'Dragon Rage'],
    ),
    Pokemon(
      name: 'Pikachu',
      spriteId: 25,
      typeIds: [13],
      level: 25,
      moves: ['Thunderbolt', 'Quick Attack', 'Iron Tail', 'Volt Tackle'],
    ),
    Pokemon(
      name: 'Mewtwo',
      spriteId: 150,
      typeIds: [14],
      level: 70,
      moves: ['Psystrike', 'Shadow Ball', 'Aura Sphere', 'Ice Beam'],
    ),
    Pokemon(
      name: 'Eevee',
      spriteId: 133,
      typeIds: [1],
      level: 15,
      moves: ['Tackle', 'Sand Attack', 'Quick Attack', 'Bite'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.catching_pokemon, size: 28),
            SizedBox(width: 8),
            Text(
              'Pokédex',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: pokemons.length,
        itemBuilder: (context, index) {
          final pokemon = pokemons[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[100],
                backgroundImage: NetworkImage(pokemon.spriteUrl),
              ),
              title: Text(
                pokemon.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                'Nível ${pokemon.level}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () async {
                final novoNivel = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokemonScreen(pokemon: pokemon),
                  ),
                );
                if (novoNivel != null) {
                  setState(() {
                    pokemon.level = novoNivel;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}
