import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:restofind/services/auth_service.dart';
import 'package:restofind/services/local_storage_service.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); 
  bool _isLogin = true; 

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green, 
      ),
    );
  }

  Future<void> _authenticate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final localStorageService = Provider.of<LocalStorageService>(context, listen: false);

    try {
      if (_isLogin) {
        await authService.signIn(_emailController.text, _passwordController.text);
        await localStorageService.saveBool('isLoggedIn', true); 
        _showSnackBar('Inicio de sesión exitoso');
      } else {
        await authService.signUp(_emailController.text, _passwordController.text);
        await localStorageService.saveBool('isLoggedIn', true); 
        _showSnackBar('Registro exitoso');
      }
    } catch (e) {
      String errorMessage = 'Ocurrió un error. Inténtalo de nuevo.';
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No se encontró un usuario con ese correo.';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Contraseña incorrecta.';
      } else if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'El correo ya está en uso.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'El formato del correo es inválido.';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'La contraseña es demasiado débil.';
      }
      _showSnackBar(errorMessage, isError: true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'), 
        backgroundColor: Theme.of(context).primaryColor, 
      ),
      body: Center(
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)), 
                  ),
                  prefixIcon: Icon(Icons.email), 
                ),
                keyboardType: TextInputType.emailAddress, 
              ),
              const SizedBox(height: 20), 
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.lock), 
                ),
                obscureText: true, 
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, 
                child: ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), 
                    ),
                    backgroundColor: Theme.of(context).primaryColor, 
                    foregroundColor: Colors.white, 
                  ),
                  child: Text(
                    _isLogin ? 'Iniciar Sesión' : 'Registrarse', 
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; 
                  });
                },
                child: Text(
                  _isLogin
                      ? '¿No tienes una cuenta? Regístrate aquí'
                      : '¿Ya tienes una cuenta? Inicia sesión', 
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}