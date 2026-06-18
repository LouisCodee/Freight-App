import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ListingModel?> addListing({
    required String truckId,
    required String origin,
    required String destination,
    DateTime? availableDate,
    required bool isFlexible,
    required List<String> cargoPreferences,
    required String pricingModel,
    required double rate,
    required bool negotiable,
    required String notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      DocumentReference docRef = _firestore.collection('listings').doc();

      ListingModel listing = ListingModel(
        id: docRef.id,
        ownerId: user.uid,
        truckId: truckId,
        origin: origin,
        destination: destination,
        availableDate: availableDate,
        isFlexible: isFlexible,
        cargoPreferences: cargoPreferences,
        pricingModel: pricingModel,
        rate: rate,
        negotiable: negotiable,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await docRef.set(listing.toMap());
      return listing;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  /// Returns all listings, sorted newest-first on the client side.
  /// This avoids needing a Firestore index and handles mixed date types.
  Stream<List<ListingModel>> getAvailableListings() {
    return _firestore
        .collection('listings')
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList();
          // Client-side sort: newest first
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  /// Returns listings belonging to the current user, sorted newest-first.
  Future<List<ListingModel>> getMyListings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // No orderBy — filter only, sort client-side to avoid composite index requirement
      QuerySnapshot snapshot = await _firestore
          .collection('listings')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      final items = snapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}
