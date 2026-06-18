import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<BookingModel?> createBooking({
    required String listingId,
    required String carrierId,
    required double price,
    required Map<String, dynamic> cargoDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      DocumentReference docRef = _firestore.collection('bookings').doc();

      BookingModel booking = BookingModel(
        id: docRef.id,
        listingId: listingId,
        shipperId: user.uid,
        carrierId: carrierId,
        status: 'pending',
        price: price,
        cargoDetails: cargoDetails,
        createdAt: DateTime.now(),
      );

      await docRef.set(booking.toMap());
      return booking;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  /// Bookings for the current shipper, sorted newest-first client-side.
  /// Avoids composite index requirement (where + orderBy).
  Stream<List<BookingModel>> getShipperBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('bookings')
        .where('shipperId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  /// Bookings for the current carrier, sorted newest-first client-side.
  /// Avoids composite index requirement (where + orderBy).
  Stream<List<BookingModel>> getCarrierBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('bookings')
        .where('carrierId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }
}
