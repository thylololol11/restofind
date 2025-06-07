import 'package:cloud_firestore/cloud_firestore.dart'; 

class Review {
  final String id; 
  final String userId; 
  final String restaurantName;
  final double rating; 
  final String description; 
  final List<String>? imageUrls; 
  final DateTime timestamp; 

  Review({
    required this.id,
    required this.userId,
    required this.restaurantName,
    required this.rating,
    required this.description,
    this.imageUrls,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id, 
      userId: data['userId'] as String? ?? '',
      restaurantName: data['restaurantName'] as String? ?? 'Desconocido',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      imageUrls: (data['imageUrls'] as List?)?.map((url) => url as String).toList(),
      timestamp: (data['timestamp'] as Timestamp).toDate(), 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'restaurantName': restaurantName,
      'rating': rating,
      'description': description,
      'imageUrls': imageUrls ?? [],
      'timestamp': Timestamp.fromDate(timestamp), 
    };
  }
}
