import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restofind/services/auth_service.dart';
import 'package:restofind/providers/review_provider.dart';
import 'package:restofind/screens/add_review_screen.dart';
import 'package:restofind/screens/review_photos_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false).fetchUserReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reviewProvider = Provider.of<ReviewProvider>(context);

    final String userId = authService.currentUser?.uid ?? 'No autenticado';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final bool confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro de que quieres cerrar la sesión?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Cerrar Sesión'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (confirmLogout) {
                await authService.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'ID de Usuario: $userId',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              context,
              icon: Icons.rate_review,
              title: 'Reseñas de restaurantes visitados',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddReviewScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildOptionTile(
              context,
              icon: Icons.camera_alt,
              title: 'Fotos Reseña',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReviewPhotosScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Tus Reseñas:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 10),
            reviewProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviewProvider.errorMessage != null
                    ? Center(
                        child: Text('Error al cargar reseñas: ${reviewProvider.errorMessage}',
                            style: const TextStyle(color: Colors.red)))
                    : reviewProvider.userReviews.isEmpty
                        ? const Center(
                            child: Text(
                              'Aún no tienes reseñas. ¡Haz una!',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviewProvider.userReviews.length,
                            itemBuilder: (context, index) {
                              final review = reviewProvider.userReviews[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.restaurantName,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 20),
                                          const SizedBox(width: 4),
                                          Text('${review.rating}', style: const TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        review.description,
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8),
                                      if (review.imageUrls != null && review.imageUrls!.isNotEmpty)
                                        Container(
                                          height: 100,
                                          width: 100,
                                          margin: const EdgeInsets.only(top: 8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              review.imageUrls![0],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          'Fecha: ${review.timestamp.toLocal().toString().split(' ')[0]}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ],
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

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}