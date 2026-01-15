import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      return {
        'id': googleUser.id,
        'name': googleUser.displayName ?? '',
        'email': googleUser.email,
        'photoUrl': googleUser.photoUrl,
        'idToken': googleAuth.idToken,
      };
    } catch (e) {
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }
}
