import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  // 1. En la versión 7+, ya no se usa "GoogleSignIn()", es un Singleton:
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _inicializado = false;

  Future<bool> signInWithGoogle() async {
    try {
      // 2. NUEVO: Google ahora exige inicializar la librería antes de usarla
      if (!_inicializado) {
        await _googleSignIn.initialize();
        _inicializado = true;
      }

      // 3. NUEVO: "signIn()" dejó de existir. Ahora se usa "authenticate()"
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return false; // Si el usuario cancela, no hacemos nada

      // 4. Obtenemos el Token de identidad
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 5. ¡Le pegamos a tu API de Node.js!
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': googleAuth.idToken,
          'nombre': googleUser.displayName,
          'correo': googleUser.email
        }),
      );

      // 6. Si tu backend lo aprueba, guardamos la sesión
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return true;
      } else {
        print("Backend rechazó el login: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error en Google Sign In: $e");
      return false;
    }
  }
}