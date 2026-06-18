import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String ownerId;
  final String truckId;
  final String origin;
  final String destination;
  final DateTime? availableDate;
  final bool isFlexible;
  final List<String> cargoPreferences;
  final String pricingModel;
  final double rate;
  final bool negotiable;
  final String notes;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.ownerId,
    required this.truckId,
    required this.origin,
    required this.destination,
    this.availableDate,
    required this.isFlexible,
    required this.cargoPreferences,
    required this.pricingModel,
    required this.rate,
    required this.negotiable,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'truckId': truckId,
      'origin': origin,
      'destination': destination,
      'availableDate': availableDate != null
          ? Timestamp.fromDate(availableDate!)
          : null,
      'isFlexible': isFlexible,
      'cargoPreferences': cargoPreferences,
      'pricingModel': pricingModel,
      'rate': rate,
      'negotiable': negotiable,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory ListingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ListingModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      truckId: map['truckId'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      availableDate: map['availableDate'] != null
          ? _parseDate(map['availableDate'])
          : null,
      isFlexible: map['isFlexible'] ?? false,
      cargoPreferences: List<String>.from(map['cargoPreferences'] ?? []),
      pricingModel: map['pricingModel'] ?? '',
      rate: (map['rate'] ?? 0).toDouble(),
      negotiable: map['negotiable'] ?? false,
      notes: map['notes'] ?? '',
      createdAt: _parseDate(map['createdAt']),
    );
  }
}
