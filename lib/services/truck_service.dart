import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/truck_model.dart';

class TruckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<TruckModel?> addTruck({
    required String licensePlate,
    required String truckType,
    required double payloadCapacity,
    required String homeBase,
    String? preferredRoutes,
    File? imageFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      DocumentReference docRef = _firestore.collection('trucks').doc();
      
      String? photoUrl;
      if (imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('truck_photos')
            .child('${docRef.id}.jpg');
        await storageRef.putFile(imageFile);
        photoUrl = await storageRef.getDownloadURL();
      }

      TruckModel truck = TruckModel(
        id: docRef.id,
        ownerId: user.uid,
        licensePlate: licensePlate,
        truckType: truckType,
        payloadCapacity: payloadCapacity,
        homeBase: homeBase,
        preferredRoutes: preferredRoutes,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await docRef.set(truck.toMap());
      return truck;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<List<TruckModel>> getMyTrucks() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      QuerySnapshot snapshot = await _firestore
          .collection('trucks')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      return snapshot.docs
          .map((doc) => TruckModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<TruckModel?> getTruckById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('trucks').doc(id).get();
      if (doc.exists) {
        return TruckModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<TruckModel?> getTruckByOwnerId(String ownerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('trucks')
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return TruckModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
