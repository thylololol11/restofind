import 'package:flutter/material.dart';
import 'package:restofind/models/review.dart';
import 'package:restofind/services/firestore_service.dart'; 

class ReviewProvider extends ChangeNotifier {
  final FirestoreService _firestoreService; 
  List<Review> _userReviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  ReviewProvider(this._firestoreService);

  List<Review> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _firestoreService.getReviewsForCurrentUser().listen((reviews) {
        _userReviews = reviews;
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
}