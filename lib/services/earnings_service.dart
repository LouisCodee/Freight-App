import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class EarningsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<TransactionModel>> getTransactions() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('transactions')
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<double> getTotalBalance() {
    return getTransactions().map((transactions) {
      double total = 0.0;
      for (var tx in transactions) {
        if (tx.status != TransactionStatus.failed) {
          if (tx.isPositive) {
            total += tx.amount;
          } else {
            total -= tx.amount;
          }
        }
      }
      return total;
    });
  }

  // Temporary helper to add dummy data for verification
  Future<void> addDummyTransaction({
    required String title,
    required double amount,
    required bool isPositive,
    TransactionStatus status = TransactionStatus.completed,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('transactions').doc();
    final tx = TransactionModel(
      id: docRef.id,
      ownerId: user.uid,
      title: title,
      amount: amount,
      isPositive: isPositive,
      date: DateTime.now(),
      status: status,
    );

    await docRef.set(tx.toMap());
  }
}
