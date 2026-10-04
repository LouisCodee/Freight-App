import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus { pending, completed, failed }

class TransactionModel {
  final String id;
  final String ownerId;
  final String title;
  final double amount;
  final bool isPositive;
  final DateTime date;
  final TransactionStatus status;

  TransactionModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.amount,
    required this.isPositive,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'amount': amount,
      'isPositive': isPositive,
      'date': Timestamp.fromDate(date),
      'status': status.toString().split('.').last,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static TransactionStatus _parseStatus(String value) {
    switch (value) {
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      case 'completed':
      default:
        return TransactionStatus.completed;
    }
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      isPositive: map['isPositive'] ?? true,
      date: _parseDate(map['date']),
      status: _parseStatus(map['status'] ?? 'completed'),
    );
  }
}
