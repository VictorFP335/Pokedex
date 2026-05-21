import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'location_service.dart';
import 'pokemon_service.dart';
import 'type_chip.dart';

String _spriteUrl(int? id) => id != null
    ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png'
    : '';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {
  late Future<List<Map<String, dynamic>>> _searchFuture;
  final _queryController = TextEditingController();
  Map<String, dynamic>? _selected;
  bool _loadingDetails = false;
  bool _capturing = false;

  final _formKey = GlobalKey<FormState>();
  final _levelController = TextEditingController();
  final collection = FirebaseFirestore.instance.collection('pokemons');

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchPokemonList();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _buscar() {
    final query = _queryController.text.trim();
    setState(() {
      _searchFuture = query.isEmpty
          ? fetchPokemonList()
          : fetchPokemonByName(query);
    });
  }

  Future<void> _selectPokemon(String name) async {
    setState(() => _loadingDetails = true);
    try {
      final details = await fetchPokemonDetails(name);
      setState(() {
        _selected = details;
        _loadingDetails = false;
      });
    } catch (_) {
      setState(() => _loadingDetails = false);
    }
  }

  Future<void> _capturar() async {
    if (_selected == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _capturing = true);
    final position = await getLocation();

    await collection.add({
      'name': _selected!['name'],
      'spriteId': _selected!['spriteId'],
      'level': int.parse(_levelController.text.trim()),
      'types': _selected!['types'],
      if (position != null) 'latitude': position.latitude,
      if (position != null) 'longitude': position.longitude,
    });

    if (!mounted) return;
    setState(() => _capturing = false);

    final mensagem = position != null
        ? '${_selected!['name']} capturado em '
            '${position.latitude.toStringAsFixed(4)}°, '
            '${position.longitude.toStringAsFixed(4)}°!'
        : '${_selected!['name']} capturado sem localização.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), duration: const Duration(seconds: 4)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pokémon'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: _selected == null ? _buildList() : _buildForm(),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Pokémon',
                    hintText: 'Ex: pikachu',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loadingDetails ? null : _buscar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _searchFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final name = item['name'] as String;
                  final spriteUrl = _spriteUrl(item['spriteId'] as int?);
                  final typesList = item['types'] as List<dynamic>? ?? [];
                  return ListTile(
                    leading: spriteUrl.isNotEmpty
                        ? Image.network(
                            spriteUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                ? child
                                : const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.catching_pokemon,
                              color: Colors.deepPurple,
                            ),
                          )
                        : const Icon(
                            Icons.catching_pokemon,
                            color: Colors.deepPurple,
                          ),
                    title: Text(name),
                    subtitle: typesList.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: List.generate(
                                typesList.length,
                                (j) => typeChip(typesList[j] as String),
                              ),
                            ),
                          )
                        : null,
                    trailing: _loadingDetails
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _loadingDetails ? null : () => _selectPokemon(name),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              leading: Image.network(
                _spriteUrl(_selected!['spriteId'] as int?),
                width: 56,
                height: 56,
              ),
              title: Text(
                _selected!['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                onPressed: _capturing
                    ? null
                    : () => setState(() => _selected = null),
                child: const Text('Trocar'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _levelController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nível inicial',
                    hintText: 'Ex: 5',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final lvl = int.tryParse(value ?? '');
                    if (lvl == null) return 'Digite um número';
                    if (lvl < 1 || lvl > 100) return 'Nível deve ser entre 1 e 100';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4,
                  children: List.generate(
                    (_selected!['types'] as List<dynamic>).length,
                    (i) => typeChip(
                      (_selected!['types'] as List<dynamic>)[i] as String,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.deepPurple.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Ao capturar, o navegador pedirá sua localização '
                          'para registrar onde o Pokémon foi pego.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _capturing ? null : _capturar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _capturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.catching_pokemon),
                  label: Text(_capturing ? 'Capturando...' : 'Capturar Pokémon'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
