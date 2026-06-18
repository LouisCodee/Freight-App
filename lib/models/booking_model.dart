import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String listingId;
  final String shipperId;
  final String carrierId;
  final String status;
  final double price;
  final Map<String, dynamic> cargoDetails;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.listingId,
    required this.shipperId,
    required this.carrierId,
    required this.status,
    required this.price,
    required this.cargoDetails,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'shipperId': shipperId,
      'carrierId': carrierId,
      'status': status,
      'price': price,
      'cargoDetails': cargoDetails,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingModel(
      id: documentId,
      listingId: map['listingId'] ?? '',
      shipperId: map['shipperId'] ?? '',
      carrierId: map['carrierId'] ?? '',
      status: map['status'] ?? 'pending',
      price: (map['price'] ?? 0).toDouble(),
      cargoDetails: Map<String, dynamic>.from(map['cargoDetails'] ?? {}),
      createdAt: _parseDate(map['createdAt']),
    );
  }
}
