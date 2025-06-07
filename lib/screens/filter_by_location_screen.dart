import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restofind/screens/restaurant_list_screen.dart';
import 'package:restofind/services/local_storage_service.dart';

class FilterByLocationScreen extends StatefulWidget {
  const FilterByLocationScreen({super.key});

  @override
  State<FilterByLocationScreen> createState() => _FilterByLocationScreenState();
}

class _FilterByLocationScreenState extends State<FilterByLocationScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _lastSearchedCity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLastSearchedCity();
    });
  }

  Future<void> _loadLastSearchedCity() async {
    final localStorageService = Provider.of<LocalStorageService>(context, listen: false);
    _lastSearchedCity = localStorageService.getString('lastSearchedCity');
    if (_lastSearchedCity != null) {
      _cityController.text = _lastSearchedCity!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrar por Lugar'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ingrese la ciudad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_cityController.text.isNotEmpty) {
                    Provider.of<LocalStorageService>(context, listen: false)
                        .saveString('lastSearchedCity', _cityController.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantListScreen(
                          searchType: 'city',
                          city: _cityController.text,
                        ),
                      ),
                    );
                  } else {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RestaurantListScreen(
                          searchType: 'all', 
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mostrando todos los restaurantes.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Buscar Restaurantes',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}