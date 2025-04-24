import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up with name
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty || name.trim().isEmpty) {
        throw 'All fields are required';
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw 'Failed to create user account';
      }

      // Update the user's display name
      await userCredential.user?.updateDisplayName(name.trim());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during sign up';
      }
      throw errorMessage;
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw 'Email and password are required';
      }

      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error occurred. Please check your internet connection.';
          break;
        case 'invalid-credential':
          errorMessage = 'The provided credentials are invalid.';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred during sign in. Please try again.';
      }
      throw errorMessage;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw 'Failed to get Google authentication tokens';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Error signing in with Google';
    } catch (e) {
      throw 'An unexpected error occurred during Google sign in';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (_auth.currentUser == null) {
        throw 'No user is currently signed in';
      }

      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      throw 'Error signing out: ${e.toString()}';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw 'Email address is required';
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for this email.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many password reset attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Error resetting password';
      }
      throw errorMessage;
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      if (displayName != null && displayName.trim().isEmpty) {
        throw 'Display name cannot be empty';
      }

      await user.updateDisplayName(displayName?.trim());
      await user.updatePhotoURL(photoURL?.trim());
    } catch (e) {
      throw 'Error updating user profile: ${e.toString()}';
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}