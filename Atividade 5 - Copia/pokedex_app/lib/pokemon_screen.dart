import 'package:flutter/material.dart';
import 'pokemon.dart';

// Mapa de tipos: typeId -> {nome, cor}
const typeInfo = {
  1:  {'name': 'Normal',   'color': 0xFFA8A878},
  2:  {'name': 'Fighting', 'color': 0xFFC03028},
  3:  {'name': 'Flying',   'color': 0xFFA890F0},
  4:  {'name': 'Poison',   'color': 0xFFA040A0},
  5:  {'name': 'Ground',   'color': 0xFFE0C068},
  6:  {'name': 'Rock',     'color': 0xFFB8A038},
  7:  {'name': 'Bug',      'color': 0xFFA8B820},
  8:  {'name': 'Ghost',    'color': 0xFF705898},
  9:  {'name': 'Steel',    'color': 0xFFB8B8D0},
  10: {'name': 'Fire',     'color': 0xFFF08030},
  11: {'name': 'Water',    'color': 0xFF6890F0},
  12: {'name': 'Grass',    'color': 0xFF78C850},
  13: {'name': 'Electric', 'color': 0xFFF8D030},
  14: {'name': 'Psychic',  'color': 0xFFF85888},
  15: {'name': 'Ice',      'color': 0xFF98D8D8},
  16: {'name': 'Dragon',   'color': 0xFF7038F8},
  17: {'name': 'Dark',     'color': 0xFF705848},
  18: {'name': 'Fairy',    'color': 0xFFEE99AC},
};

class PokemonScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonScreen({super.key, required this.pokemon});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  static const int maxHp = 100;
  static const int xpPerLevel = 100;

  late int hp;
  late int xp;
  late int level;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    hp = maxHp;
    xp = 0;
    level = widget.pokemon.level;
    statusMessage = 'Pronto para batalhar!';
  }

  void _attack() {
    if (hp <= 0) return;

    setState(() {
      final damage = 10 + (level ~/ 5);
      hp = (hp - damage).clamp(0, maxHp);
      xp += 20;
      statusMessage = '${widget.pokemon.name} atacou causando $damage de dano!';

      if (xp >= xpPerLevel) {
        xp -= xpPerLevel;
        level++;
        statusMessage = '🎉 ${widget.pokemon.name} subiu para o Nível $level!';
      }

      if (hp <= 0) {
        statusMessage = '${widget.pokemon.name} desmaiou!';
      }
    });
  }

  void _heal() {
    setState(() {
      hp = maxHp;
      statusMessage = '${widget.pokemon.name} foi totalmente curado!';
    });
  }

  void _endBattle() {
    Navigator.pop(context, level);
  }

  Color get _hpColor {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          widget.pokemon.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Sprite
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.network(
                  widget.pokemon.spriteUrl,
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Tipos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pokemon.typeIds.map((id) {
                  final info = typeInfo[id];
                  final color = Color(info?['color'] as int? ?? 0xFF888888);
                  final name = info?['name'] as String? ?? 'Unknown';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Nível
              Text(
                'Nível $level',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // HP
              Row(
                children: [
                  const Text('HP', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: hp / maxHp,
                        minHeight: 14,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(_hpColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$hp/$maxHp'),
                ],
              ),
              const SizedBox(height: 8),

              // XP
              Row(
                children: [
                  const Text('XP', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: xp / xpPerLevel,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$xp/$xpPerLevel'),
                ],
              ),
              const SizedBox(height: 16),

              // Mensagem de status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),

              // Golpes
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Golpes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.pokemon.moves.map((move) {
                  return Chip(
                    label: Text(move),
                    backgroundColor: Colors.purple[100],
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Botões Atacar / Curar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: hp > 0 ? _attack : null,
                      icon: const Icon(Icons.sports_martial_arts),
                      label: const Text('Atacar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _heal,
                      icon: const Icon(Icons.favorite),
                      label: const Text('Curar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Botão Encerrar Batalha
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _endBattle,
                  icon: const Icon(Icons.flag),
                  label: const Text('Encerrar Batalha'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
