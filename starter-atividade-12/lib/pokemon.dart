import 'package:cloud_firestore/cloud_firestore.dart';

class Pokemon {
  final String name;
  final List<String> types;
  final String spriteUrl;
  int level;
  final double? latitude;
  final double? longitude;

  Pokemon({
    required this.name,
    required this.types,
    required this.spriteUrl,
    required this.level,
    this.latitude,
    this.longitude,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory Pokemon.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawName = data['name'] as String? ?? '';

    final url = data['spriteUrl'] as String?;
    final spriteUrl = (url != null && url.isNotEmpty)
        ? url
        : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${data['spriteId']}.png';

    return Pokemon(
      name: rawName.isEmpty
          ? ''
          : '${rawName[0].toUpperCase()}${rawName.substring(1)}',
      types: List<String>.from(data['types'] as List? ?? []),
      spriteUrl: spriteUrl,
      level: data['level'] as int? ?? 0,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
}
