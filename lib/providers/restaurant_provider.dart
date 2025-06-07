import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart'; 

class RestaurantProvider extends ChangeNotifier {
  final LocalStorageService _localStorageService;
  final FirestoreService _firestoreService; 

  List<Restaurant> _restaurants = [];
  List<Restaurant> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  RestaurantProvider(this._localStorageService, this._firestoreService) {
    _loadFavorites();
  }

  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadFavorites() {
    _favorites = _localStorageService.getList<Restaurant>(
      'favoriteRestaurants',
      (jsonMap) {
        return Restaurant(
          id: jsonMap['id'] as String? ?? UniqueKey().toString(),
          name: jsonMap['name'] as String? ?? 'Nombre Desconocido',
          address: jsonMap['address'] as String? ?? 'Dirección Desconocida',
          rating: (jsonMap['rating'] as num?)?.toDouble(),
          imageUrls: (jsonMap['imageUrls'] as List?)?.map((url) => url as String).toList(),
          foodTypes: (jsonMap['foodTypes'] as List?)?.map((type) => type as String).toList(),
          description: jsonMap['description'] as String?, 
        );
      },
    );
    notifyListeners();
  }

  void _saveFavorites() {
    _localStorageService.saveList<Restaurant>(
      'favoriteRestaurants',
      _favorites,
      (restaurant) => {
        'id': restaurant.id,
        'name': restaurant.name,
        'address': restaurant.address,
        'rating': restaurant.rating,
        'imageUrls': restaurant.imageUrls,
        'foodTypes': restaurant.foodTypes,
        'description': restaurant.description, 
      },
    );
  }

  Future<void> fetchRestaurantsByCity(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _firestoreService.getRestaurantsByCity(city).listen((restaurants) {
        _restaurants = restaurants;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (e) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantsByFoodTypeAndCity(String foodType, String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _firestoreService.getRestaurantsByFoodTypeAndCity(foodType, city).listen((restaurants) {
        _restaurants = restaurants;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (e) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _firestoreService.getRestaurants().listen((restaurants) {
        _restaurants = restaurants;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (e) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void addFavorite(Restaurant restaurant) {
    if (!_favorites.contains(restaurant)) {
      _favorites.add(restaurant);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(Restaurant restaurant) {
    _favorites.remove(restaurant);
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(Restaurant restaurant) {
    return _favorites.contains(restaurant);
  }
}
