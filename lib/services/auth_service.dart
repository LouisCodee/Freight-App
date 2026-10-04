import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '787052587038-mrbfkbetualc0cu88t9mk1eihk4if3vv.apps.googleusercontent.com',
    serverClientId: '787052587038-3ih786j8bucn1610k6rigp15tqf5aglh.apps.googleusercontent.com',
  );

  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        UserModel userModel = UserModel(
          uid: cred.user!.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(cred.user!.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Signs in with Google.
  ///
  /// Returns a [GoogleSignInResult]:
  ///   - [GoogleSignInResult.user] — the existing UserModel (if Firestore doc exists)
  ///   - [GoogleSignInResult.isNewUser] — true when this is a first-time Google user
  ///     who still needs to pick a role.
  ///   - [GoogleSignInResult.firebaseUid] — the Firebase UID for new users so the
  ///     caller can persist the Firestore doc after role selection.
  Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential cred =
          await _auth.signInWithCredential(credential);
      if (cred.user == null) return null;

      final uid = cred.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        // Returning Google user — Firestore profile already set up.
        final userModel =
            UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
        return GoogleSignInResult(
          user: userModel,
          isNewUser: false,
          firebaseUid: uid,
          displayName: googleUser.displayName ?? '',
          email: googleUser.email,
        );
      } else {
        // Brand-new Google user — no Firestore doc yet. Caller must collect role.
        return GoogleSignInResult(
          user: null,
          isNewUser: true,
          firebaseUid: uid,
          displayName: googleUser.displayName ?? '',
          email: googleUser.email,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Creates the Firestore user document for a Google-authenticated new user
  /// after they have chosen their role.
  Future<UserModel> saveGoogleUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    final userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: '',
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(userModel.toMap());
    return userModel;
  }

  Future<UserModel?> getCurrentUser() async {
    if (_auth.currentUser != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    }
    return null;
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'phone': phone,
      });
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

/// Holds the result of a Google Sign-In attempt.
class GoogleSignInResult {
  /// Set when the user already has a Firestore profile.
  final UserModel? user;

  /// True when this is a first-time sign-in and no Firestore doc exists yet.
  final bool isNewUser;

  /// The Firebase UID — always present regardless of [isNewUser].
  final String firebaseUid;

  /// The name from the Google account (useful for pre-filling forms).
  final String displayName;

  /// The email from the Google account.
  final String email;

  const GoogleSignInResult({
    required this.user,
    required this.isNewUser,
    required this.firebaseUid,
    required this.displayName,
    required this.email,
  });
}
