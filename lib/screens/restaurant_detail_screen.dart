import 'package:flutter/material.dart';
import 'package:restofind/models/restaurant.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:restofind/screens/dummy_reviews_screen.dart'; 
class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {


  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.restaurant.imageUrls != null && widget.restaurant.imageUrls!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.network(
                  widget.restaurant.imageUrls![0],
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.restaurant.address,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.restaurant.rating != null)
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: widget.restaurant.rating!,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 25.0,
                          direction: Axis.horizontal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.restaurant.rating?.toStringAsFixed(1) ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (widget.restaurant.foodTypes != null && widget.restaurant.foodTypes!.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: widget.restaurant.foodTypes!
                          .map((type) => Chip(
                                label: Text(type, style: const TextStyle(fontSize: 14)),
                                backgroundColor: Colors.deepPurple.shade100,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    widget.restaurant.description ?? 'No hay descripción disponible.',
                    style: const TextStyle(fontSize: 16),
                  ),
 
                  const Divider(height: 30, thickness: 1), 
                  Text(
                    'Reseñas de Usuarios',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DummyReviewsScreen(
                            restaurantName: widget.restaurant.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                    label: const Text('Ver Reseñas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Aquí se mostrarán las reseñas de otros usuarios. (Haz clic en "Ver Reseñas")',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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