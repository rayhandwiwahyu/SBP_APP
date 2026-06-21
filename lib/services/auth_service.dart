import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn   => _auth.currentUser != null;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // null = berhasil
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti';
        case 'invalid-credential':
          return 'Email atau password salah';
        default:
          return 'Login gagal. Coba lagi';
      }
    } catch (e) {
      return 'Terjadi kesalahan. Coba lagi';
    }
  }

  // Register
static Future<String?> register({
  required String email,
  required String password,
}) async {
  try {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return null; // null = berhasil
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      default:
        return 'Registrasi gagal. Coba lagi';
    }
  } catch (e) {
    return 'Terjadi kesalahan. Coba lagi';
  }
}

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }
}