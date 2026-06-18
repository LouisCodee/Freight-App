import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> logout() async {
    await _auth.signOut();
  }
}
