import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserCredential? userCredential;
  final bool requiresEmailVerification;

  AuthResult({
    required this.success,
    required this.message,
    this.userCredential,
    this.requiresEmailVerification = false,
  });
}

/// Service class to handle all authentication related operations
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Authentication state
  bool get isSignedIn => _auth.currentUser != null;

  /// Handle Firebase Auth exceptions
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email. Please sign up first.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'invalid-email':
        message = 'Invalid email address format.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled. Please contact support.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message =
            'Email/password sign in is not enabled. Please contact support.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'weak-password':
        message = 'Password is too weak. Please use a stronger password.';
        break;
      case 'account-exists-with-different-credential':
        message = 'An account already exists with a different sign-in method.';
        break;
      case 'invalid-credential':
        message = 'The sign-in credential is invalid. Please try again.';
        break;
      case 'email-not-verified':
        message = 'Please verify your email before signing in.';
        break;
      case 'verification-email-sent':
        message =
            'A verification email has been sent. Please verify your email before signing in.';
        break;
      default:
        message =
            e.message ?? 'An unexpected error occurred. Please try again.';
    }
    return FirebaseAuthException(code: e.code, message: message);
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await signOut();
        return AuthResult(
          success: false,
          message:
              'Please verify your email before signing in. A new verification email has been sent.',
          requiresEmailVerification: true,
        );
      }

      return AuthResult(
        success: true,
        message: 'Successfully signed in',
        userCredential: userCredential,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      return AuthResult(
        success: true,
        message:
            'Account created successfully. Please check your email for verification.',
        userCredential: userCredential,
        requiresEmailVerification: true,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred during sign up.',
      );
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(success: false, message: 'Sign in was cancelled');
      }

      try {
        // Obtain auth details from request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with credential
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        // Update user profile if needed
        if (userCredential.user != null &&
            userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(googleUser.displayName);
        }

        return AuthResult(
          success: true,
          message: 'Successfully signed in with Google',
          userCredential: userCredential,
        );
      } catch (_) {
        // Clean up by signing out from Google
        await _googleSignIn.signOut();
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (e) {
      String message = 'An error occurred during Google sign in.';
      if (e.toString().contains('network_error')) {
        message = 'Please check your internet connection and try again.';
      } else if (e.toString().contains('404')) {
        message =
            'Google Sign-In is not properly configured. Please contact support.';
      }
      return AuthResult(success: false, message: message);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (_) {
      debugPrint('Error during sign out');
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e.code));
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'Failed to send password reset email. Please try again.',
      );
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      if (displayName != null && displayName.trim().isEmpty) {
        throw 'Display name cannot be empty.';
      }

      await user.updateDisplayName(displayName?.trim());
      await user.updatePhotoURL(photoURL?.trim());

      notifyListeners();
    } catch (e) {
      throw 'Failed to update user profile.';
    }
  }

  /// Verify email
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw 'Failed to send email verification.';
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account.';
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<UserCredential> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently signed in.',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      return await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
