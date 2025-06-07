import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:restofind/models/review.dart';
import 'package:restofind/models/restaurant.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> addReview(Review review) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }
      await _db.collection('reviews').add(review.toFirestore());
      debugPrint('Reseña añadida con éxito: ${review.restaurantName}');
    } catch (e) {
      debugPrint('Error al añadir reseña: $e');
      throw Exception('No se pudo añadir la reseña. Inténtalo de nuevo.');
    }
  }

  Stream<List<Review>> getReviewsForCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _db
        .collection('reviews')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Future<void> updateReviewImageUrls(String reviewId, List<String> newImageUrls) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }
      final reviewRef = _db.collection('reviews').doc(reviewId);
      final doc = await reviewRef.get();
      List<String> currentImageUrls = [];
      if (doc.exists && doc.data() != null && doc.data()!['imageUrls'] != null) {
        currentImageUrls = List<String>.from(doc.data()!['imageUrls']);
      }
      final updatedImageUrls = [...currentImageUrls, ...newImageUrls];
      await reviewRef.update({
        'imageUrls': updatedImageUrls,
      });
      debugPrint('URLs de imagen actualizadas para la reseña $reviewId');
    } catch (e) {
      debugPrint('Error al actualizar URLs de imagen de la reseña: $e');
      throw Exception('No se pudieron actualizar las URLs de imagen de la reseña.');
    }
  }


  Future<void> addRestaurant(Restaurant restaurant) async {
    try {
      await _db.collection('restaurants').add(restaurant.toFirestore());
      debugPrint('Restaurante añadido con éxito: ${restaurant.name}');
    } catch (e) {
      debugPrint('Error al añadir restaurante: $e');
      throw Exception('No se pudo añadir el restaurante. Inténtalo de nuevo.');
    }
  }

  Stream<List<Restaurant>> getRestaurants() {
    return _db.collection('restaurants').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList());
  }

  Stream<List<Restaurant>> getRestaurantsByCity(String city) {
    return _db.collection('restaurants').snapshots().map((snapshot) {
      final allRestaurants = snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
      return allRestaurants.where((restaurant) {
        return restaurant.address.toLowerCase().contains(city.toLowerCase());
      }).toList();
    });
  }

  Stream<List<Restaurant>> getRestaurantsByFoodTypeAndCity(String foodType, String city) {
    return _db.collection('restaurants').snapshots().map((snapshot) {
      final allRestaurants = snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
      return allRestaurants.where((restaurant) {
        final bool matchesFoodType = restaurant.foodTypes != null &&
            restaurant.foodTypes!.any((type) => type.toLowerCase() == foodType.toLowerCase());
        final bool matchesCity = restaurant.address.toLowerCase().contains(city.toLowerCase());
        return matchesFoodType && matchesCity;
      }).toList();
    });
  }
}