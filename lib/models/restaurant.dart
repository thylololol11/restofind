import 'package:cloud_firestore/cloud_firestore.dart'; 

class Restaurant {
  final String id; 
  final String name;
  final String address;
  final double? rating; 
  final List<String>? imageUrls; 
  final List<String>? foodTypes; 
  final String? description; 
  final String? menuUrl;


  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    this.rating,
    this.imageUrls,
    this.foodTypes,
    this.description, 
    this.menuUrl, 

  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id, 
      name: data['name'] as String? ?? 'Nombre desconocido',
      address: data['address'] as String? ?? 'Dirección desconocida',
      rating: (data['rating'] as num?)?.toDouble(),
      imageUrls: (data['imageUrls'] as List?)?.map((url) => url as String).toList(),
      foodTypes: (data['foodTypes'] as List?)?.map((type) => type as String).toList(),
      description: data['description'] as String?,
      menuUrl: data['menuUrl'] as String?, 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'rating': rating,
      'imageUrls': imageUrls ?? [],
      'foodTypes': foodTypes ?? [],
      'description': description,
      'menuUrl': menuUrl, 

    };
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}