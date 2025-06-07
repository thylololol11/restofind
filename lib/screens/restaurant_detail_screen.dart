import 'package:flutter/material.dart';
import 'package:restofind/models/restaurant.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  Future<void> _launchMenuUrl() async {
    if (restaurant.menuUrl != null && restaurant.menuUrl!.isNotEmpty) {
      final Uri url = Uri.parse(restaurant.menuUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'No se pudo lanzar la URL: ${restaurant.menuUrl}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurant.imageUrls != null && restaurant.imageUrls!.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: restaurant.imageUrls!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          restaurant.imageUrls![index],
                          width: MediaQuery.of(context).size.width * 0.8,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant.address,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (restaurant.rating != null)
              Row(
                children: [
                  RatingBarIndicator(
                    rating: restaurant.rating!,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 25.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${restaurant.rating}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (restaurant.foodTypes != null && restaurant.foodTypes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Comida:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: restaurant.foodTypes!
                        .map((type) => Chip(
                              label: Text(type),
                              backgroundColor: Colors.deepPurple[50],
                              labelStyle: TextStyle(color: Colors.deepPurple[700]),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            if (restaurant.description != null && restaurant.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Descripción del Lugar:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description!,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carta (Menú):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  if (restaurant.menuUrl != null && restaurant.menuUrl!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await _launchMenuUrl();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al abrir la carta: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Ver Carta (PDF/Web)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  else
                    const Text(
                      'Carta no disponible. Puedes añadir una URL desde la pantalla de añadir restaurante.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reseñas de Usuarios:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí se mostrarán las reseñas de otros usuarios. Puedes obtenerlas de Firebase y listarlas aquí.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidad de Reseñas por implementar.')),
                      );
                    },
                    icon: const Icon(Icons.reviews),
                    label: const Text('Ver Reseñas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}