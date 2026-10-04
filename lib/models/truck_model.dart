import 'package:cloud_firestore/cloud_firestore.dart';

class TruckModel {
  final String id;
  final String ownerId;
  final String licensePlate;
  final String truckType;
  final double payloadCapacity;
  final String homeBase;
  final String? preferredRoutes;
  final String? photoUrl;
  final DateTime createdAt;

  TruckModel({
    required this.id,
    required this.ownerId,
    required this.licensePlate,
    required this.truckType,
    required this.payloadCapacity,
    required this.homeBase,
    this.preferredRoutes,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'licensePlate': licensePlate,
      'truckType': truckType,
      'payloadCapacity': payloadCapacity,
      'homeBase': homeBase,
      'preferredRoutes': preferredRoutes,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory TruckModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TruckModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      truckType: map['truckType'] ?? '',
      payloadCapacity: (map['payloadCapacity'] ?? 0).toDouble(),
      homeBase: map['homeBase'] ?? '',
      preferredRoutes: map['preferredRoutes'],
      photoUrl: map['photoUrl'],
      createdAt: _parseDate(map['createdAt']),
    );
  }
}
