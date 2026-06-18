import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) state = state.copyWith(user: user, isLoading: false);
    });
  }

  final _auth = FirebaseAuth.instance;

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      state = state.copyWith(isLoading: false);
      return null; // null = succès
    } on FirebaseAuthException catch (e) {
      final msg = _translateError(e.code);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    } catch (e) {
      const msg = 'Erreur de connexion inattendue.';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    }
  }

  Future<String?> register(String email, String password,
      {String? displayName}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }

      state = state.copyWith(isLoading: false);
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = _translateError(e.code);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    } catch (e) {
      const msg = 'Erreur d\'inscription inattendue.';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = const AuthState();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // succès
    } on FirebaseAuthException catch (e) {
      return _translateError(e.code);
    }
  }


  String _translateError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte associé à cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect. Réessayez.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caractères).';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion internet.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'operation-not-allowed':
        return 'Cette méthode de connexion n\'est pas activée.';
      default:
        return 'Erreur d\'authentification ($code).';
    }
  }
}


final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);