import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restofind/providers/restaurant_provider.dart';
import 'package:restofind/models/restaurant.dart';
import 'package:restofind/screens/restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  final String searchType;
  final String? city;
  final String? foodType;

  const RestaurantListScreen({
    super.key,
    required this.searchType,
    this.city,
    this.foodType,
  });

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRestaurants();
    });
  }

  Future<void> _fetchRestaurants() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

    if (widget.searchType == 'city' && widget.city != null) {
      await restaurantProvider.fetchRestaurantsByCity(widget.city!);
    } else if (widget.searchType == 'food_type' && widget.foodType != null && widget.city != null) {
      await restaurantProvider.fetchRestaurantsByFoodTypeAndCity(widget.foodType!, widget.city!);
    } else {
      await restaurantProvider.fetchAllRestaurants();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, restaurantProvider, child) {
          if (restaurantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (restaurantProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${restaurantProvider.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (restaurantProvider.restaurants.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron restaurantes. Intenta con otra búsqueda o añade uno nuevo.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return ListView.builder(
              itemCount: restaurantProvider.restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurantProvider.restaurants[index];
                return _buildRestaurantCard(context, restaurant, restaurantProvider);
              },
            );
          }
        },
      ),
    );
  }

  String _getTitle() {
    if (widget.searchType == 'city' && widget.city != null) {
      return 'Restaurantes en ${widget.city}';
    } else if (widget.searchType == 'food_type' && widget.foodType != null && widget.city != null) {
      return 'Restaurantes de ${widget.foodType} en ${widget.city}';
    }
    return 'Explorar Restaurantes';
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant, RestaurantProvider provider) {
    final bool isFav = provider.isFavorite(restaurant);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: restaurant.imageUrls != null && restaurant.imageUrls!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          restaurant.imageUrls![0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.restaurant_menu,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.address,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (restaurant.rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.rating}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                    if (restaurant.foodTypes != null && restaurant.foodTypes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tipos: ${restaurant.foodTypes!.join(', ')}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (isFav) {
                    provider.removeFavorite(restaurant);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${restaurant.name} eliminado de favoritos')),
                    );
                  } else {
                    provider.addFavorite(restaurant);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${restaurant.name} añadido a favoritos')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}