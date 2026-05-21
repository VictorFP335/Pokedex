import 'package:flutter/material.dart';

class BattleProvider extends ChangeNotifier {
  final String pokemonName;
  int hp = 100;
  int xp = 0;
  int level;

  BattleProvider({
    required this.pokemonName,
    required this.level,
  });

  Color get hpColor {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.yellow;
    return Colors.red;
  }

  String get statusMessage {
    if (hp == 0) return '$pokemonName desmaiou!';
    if (hp <= 30) return 'HP crítico!';
    return '';
  }

  void attack() {
    hp -= 20;
    if (hp < 0) hp = 0;
    
    xp += 10;
    if (xp >= 100) {
      level++;
      xp = 0;
    }
    
    notifyListeners();
  }

  void heal() {
    hp += 30;
    if (hp > 100) hp = 100;
    
    notifyListeners();
  }
}
