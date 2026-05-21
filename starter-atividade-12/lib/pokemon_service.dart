import 'dart:convert';
import 'package:http/http.dart' as http;

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

Future<List<Map<String, dynamic>>> fetchPokemonList() async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'),
  );
  if (response.statusCode != 200) throw Exception('Erro ${response.statusCode}');
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final results = data['results'] as List<dynamic>;
  final names = results
      .map((p) => (p as Map<String, dynamic>)['name'] as String)
      .toList();
  return Future.wait(names.map((name) => fetchPokemonDetails(name)));
}

Future<List<Map<String, dynamic>>> fetchPokemonByName(String name) async {
  final details = await fetchPokemonDetails(name.toLowerCase().trim());
  return [details];
}

Future<Map<String, dynamic>> fetchPokemonDetails(String name) async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
  );
  if (response.statusCode != 200) throw Exception('Erro ${response.statusCode}');
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final id = data['id'] as int;

  final rawTypes = data['types'] as List<dynamic>;
  final types = rawTypes
      .map((t) => _capitalize(
          ((t as Map<String, dynamic>)['type'] as Map<String, dynamic>)['name'] as String))
      .toList();

  return {
    'name': _capitalize(data['name'] as String),
    'spriteId': id,
    'types': types,
  };
}
