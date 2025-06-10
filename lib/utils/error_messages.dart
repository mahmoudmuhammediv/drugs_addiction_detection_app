String getErrorMessage(String code) {
  switch (code) {
    // Firebase Auth Error Codes
    case 'user-not-found':
      return 'No user found with this email address.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'email-already-in-use':
      return 'An account already exists with this email address.';
    case 'operation-not-allowed':
      return 'This sign-in method is not allowed. Please contact support.';
    case 'weak-password':
      return 'Please choose a stronger password.';
    case 'network-error':
      return 'Please check your internet connection and try again.';
    case 'sign-in-cancelled':
      return 'Sign in was cancelled.';
    case 'popup-blocked':
      return 'Sign in popup was blocked by your browser. Please allow popups for this site.';
    case 'popup-closed-by-user':
      return 'Sign in popup was closed before completing the process.';
    case 'account-exists-with-different-credential':
      return 'An account already exists with the same email address but different sign-in credentials.';
    case 'invalid-credential':
      return 'The sign-in credential is invalid. Please try again.';
    case 'user-mismatch':
      return 'The supplied credentials do not correspond to the previously signed in user.';
    case 'invalid-verification-code':
      return 'Invalid verification code. Please try again.';
    case 'invalid-verification-id':
      return 'Invalid verification ID. Please try again.';
    case 'expired-action-code':
      return 'The action code has expired. Please request a new one.';
    case 'invalid-action-code':
      return 'The action code is invalid. Please request a new one.';
    case 'missing-verification-code':
      return 'Please enter the verification code.';
    case 'missing-verification-id':
      return 'Missing verification ID.';
    case 'credential-already-in-use':
      return 'This credential is already associated with a different user account.';
    case 'requires-recent-login':
      return 'This operation requires recent authentication. Please sign in again.';
    case 'provider-already-linked':
      return 'The account is already linked with another provider.';
    case 'no-such-provider':
      return 'No authentication provider found for the given email.';
    case 'unverified-email':
      return 'Please verify your email address before signing in.';
    case 'email-not-verified':
      return 'Please verify your email before signing in.';
    case 'verification-email-sent':
      return 'A verification email has been sent. Please check your inbox.';
    case 'google-sign-in-failed':
      return 'Google sign in failed. Please try again.';
    case 'sign-out-failed':
      return 'Failed to sign out. Please try again.';
    case 'no-current-user':
      return 'No user is currently signed in.';
    default:
      return 'An unexpected error occurred. Please try again.';
  }
}
