import 'package:flutter/material.dart';

class DummyReviewsScreen extends StatelessWidget {
  final String restaurantName; 

  const DummyReviewsScreen({super.key, required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyReviews = [
      {
        'user': 'María P.',
        'rating': '5.0',
        'comment': '¡Excelente experiencia! La comida deliciosa y el ambiente muy agradable. Súper recomendado.',
      },
      {
        'user': 'Juan G.',
        'rating': '4.5',
        'comment': 'Buen lugar para ir con amigos. El servicio fue un poco lento, pero la calidad de la comida compensa.',
      },
      {
        'user': 'Ana L.',
        'rating': '4.0',
        'comment': 'Me gustó mucho el concepto. Las porciones son generosas. Volvería a probar otros platos.',
      },
      {
        'user': 'Carlos R.',
        'rating': '5.0',
        'comment': 'Sin duda uno de mis favoritos. Todo impecable, desde la entrada hasta el postre.',
      },
      {
        'user': 'Sofía M.',
        'rating': '3.5',
        'comment': 'La comida estaba bien, pero el lugar era un poco ruidoso. Ideal para un almuerzo rápido.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas de ${restaurantName}'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: dummyReviews.isEmpty
          ? const Center(
              child: Text('No hay reseñas disponibles.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dummyReviews.length,
              itemBuilder: (context, index) {
                final review = dummyReviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['user']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Calificación: ${review['rating']!}',
                              style: const TextStyle(fontSize: 14, color: Colors.amber),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          review['comment']!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
