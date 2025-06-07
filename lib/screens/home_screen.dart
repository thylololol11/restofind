import 'package:flutter/material.dart';
import 'package:restofind/screens/favorites_screen.dart';
import 'package:restofind/screens/filter_by_location_screen.dart'; 
import 'package:restofind/screens/profile_screen.dart';
import 'package:restofind/screens/restaurant_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:restofind/services/local_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeContent(), 
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explora Restaurantes'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: const [],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Center( 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            _buildActionButton(
              context,
              'Filtrar por Lugar',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FilterByLocationScreen()), 
                );
              },
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'Búsqueda por tipo de comida',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchByFoodTypeScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'Lista de todos los restaurantes',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RestaurantListScreen(
                      searchType: 'all',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.deepPurple[800],
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class SearchByFoodTypeScreen extends StatefulWidget {
  const SearchByFoodTypeScreen({super.key});

  @override
  State<SearchByFoodTypeScreen> createState() => _SearchByFoodTypeScreenState();
}

class _SearchByFoodTypeScreenState extends State<SearchByFoodTypeScreen> {
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _lastSearchedCity;

  @override
  void initState() {
    super.initState();
    _loadLastSearchedCity();
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
        title: const Text('Búsqueda por tipo de comida'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Ingrese el tipo de comida (ej. "italiana", "mexicana")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ingrese la ciudad (ej. "Bogotá")',
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
                  if (_foodTypeController.text.isNotEmpty && _cityController.text.isNotEmpty) {
                    Provider.of<LocalStorageService>(context, listen: false)
                        .saveString('lastSearchedCity', _cityController.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantListScreen(
                          searchType: 'food_type',
                          foodType: _foodTypeController.text,
                          city: _cityController.text,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Por favor, ingrese el tipo de comida y la ciudad.')),
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