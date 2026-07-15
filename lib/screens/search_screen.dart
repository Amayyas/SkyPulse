import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skypulse/providers/weather_provider.dart';
import 'package:skypulse/services/weather_service.dart';
import 'package:skypulse/models/city_suggestion.dart';
import 'package:skypulse/widgets/error_view.dart';
import 'dart:async';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  late final WeatherService _weatherService;
  List<CitySuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;
  Object? _error;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    // Use the app-wide service via Riverpod instead of constructing one here:
    // that keeps the screen testable with a mocked client, and avoids leaking
    // an http.Client on every visit.
    _weatherService = ref.read(weatherServiceProvider);
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _controller.text.trim();
      // The controller notifies on every change, including cursor moves and
      // selection. Only hit the network when the query text actually changed.
      if (query.length >= 2) {
        if (query != _lastQuery) _searchCities(query);
      } else {
        _lastQuery = null;
        setState(() {
          _suggestions = [];
          _error = null;
        });
      }
    });
  }

  Future<void> _searchCities(String query) async {
    _lastQuery = query;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final suggestions = await _weatherService.searchCities(query);
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      // Une recherche qui échoue affichait auparavant une page blanche,
      // impossible à distinguer d'une ville qui n'existe pas — ou d'une appli
      // cassée. On dit ce qui s'est passé.
      if (!mounted) return;
      setState(() {
        _error = e;
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  void _selectCity(CitySuggestion city) {
    ref.read(selectedCityProvider.notifier).setCity(city);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher une ville')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Entrez le nom de la ville',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _lastQuery = null;
                              setState(() {
                                _suggestions = [];
                                _error = null;
                              });
                            },
                          ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty && _suggestions.isNotEmpty) {
                      _selectCity(_suggestions.first);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(selectedCityProvider.notifier)
                        .clearCity(); // Use GPS
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Utiliser ma position actuelle'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: () => _searchCities(_controller.text),
      );
    }

    if (_suggestions.isNotEmpty) {
      return ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final city = _suggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(
              city.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              city.state.isNotEmpty
                  ? '${city.state}, ${city.country}'
                  : city.country,
            ),
            onTap: () => _selectCity(city),
          );
        },
      );
    }

    // Une recherche aboutie mais sans résultat n'est pas une erreur : l'API
    // répond 200 avec un tableau vide. Le dire explicitement, au lieu de
    // laisser une page blanche qu'on ne peut pas distinguer d'une panne.
    if (!_isLoading && _controller.text.length >= 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Aucune ville ne correspond à « ${_controller.text} »',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
