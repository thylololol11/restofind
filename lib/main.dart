import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:restofind/providers/restaurant_provider.dart';
import 'package:restofind/services/local_storage_service.dart';
import 'package:restofind/services/auth_service.dart';
import 'package:restofind/services/firestore_service.dart';
import 'package:restofind/providers/review_provider.dart';
import 'package:restofind/screens/auth_wrapper.dart';
import 'package:restofind/screens/home_screen.dart';
import 'package:restofind/screens/favorites_screen.dart';
import 'package:restofind/screens/profile_screen.dart';
import 'package:restofind/screens/review_photos_screen.dart';
import 'package:restofind/screens/add_restaurant_screen.dart';
import 'package:restofind/screens/restaurant_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalStorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => LocalStorageService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProxyProvider<FirestoreService, ReviewProvider>(
          create: (context) => ReviewProvider(
            Provider.of<FirestoreService>(context, listen: false),
          ),
          update: (context, firestoreService, previousReviewProvider) =>
              ReviewProvider(firestoreService),
        ),
        ChangeNotifierProxyProvider2<LocalStorageService, FirestoreService, RestaurantProvider>(
          create: (context) => RestaurantProvider(
            Provider.of<LocalStorageService>(context, listen: false),
            Provider.of<FirestoreService>(context, listen: false),
          ),
          update: (context, localStorageService, firestoreService, previousRestaurantProvider) =>
              RestaurantProvider(localStorageService, firestoreService),
        ),
      ],
      child: MaterialApp(
        title: 'RestoFind',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        routes: {
          '/': (context) => const AuthWrapper(),
          '/home': (context) => const HomeScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/review_photos': (context) => const ReviewPhotosScreen(),
          '/add_restaurant': (context) => const AddRestaurantScreen(),
          '/restaurants': (context) => const RestaurantListScreen(searchType: 'all'),
        },
        initialRoute: '/',
      ),
    );
  }
}