import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

enum BarcodeFormat {
  code128,
  code39,
  ean13,
  ean8,
  qrCode,
  upcA,
  pdf417,
}

@immutable
class LoyaltyCard {
  final String id;
  final String storeName;
  final String cardNumber;
  final String? memberName;
  final BarcodeFormat barcodeFormat;
  final int brandColor;
  final String? customLogoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final String? notes;

  const LoyaltyCard({
    required this.id,
    required this.storeName,
    required this.cardNumber,
    this.memberName,
    this.barcodeFormat = BarcodeFormat.code128,
    required this.brandColor,
    this.customLogoPath,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.notes,
  });

  factory LoyaltyCard.create({
    required String storeName,
    required String cardNumber,
    String? memberName,
    BarcodeFormat barcodeFormat = BarcodeFormat.code128,
    required int brandColor,
    String? customLogoPath,
    String? notes,
  }) {
    final now = DateTime.now();
    return LoyaltyCard(
      id: const Uuid().v4(),
      storeName: storeName,
      cardNumber: cardNumber,
      memberName: memberName,
      barcodeFormat: barcodeFormat,
      brandColor: brandColor,
      customLogoPath: customLogoPath,
      createdAt: now,
      updatedAt: now,
      notes: notes,
    );
  }

  LoyaltyCard copyWith({
    String? storeName,
    String? cardNumber,
    String? memberName,
    BarcodeFormat? barcodeFormat,
    int? brandColor,
    String? customLogoPath,
    bool? isFavorite,
    String? notes,
  }) {
    return LoyaltyCard(
      id: id,
      storeName: storeName ?? this.storeName,
      cardNumber: cardNumber ?? this.cardNumber,
      memberName: memberName ?? this.memberName,
      barcodeFormat: barcodeFormat ?? this.barcodeFormat,
      brandColor: brandColor ?? this.brandColor,
      customLogoPath: customLogoPath ?? this.customLogoPath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeName': storeName,
      'cardNumber': cardNumber,
      'memberName': memberName,
      'barcodeFormat': barcodeFormat.index,
      'brandColor': brandColor,
      'customLogoPath': customLogoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'notes': notes,
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      storeName: json['storeName'] as String,
      cardNumber: json['cardNumber'] as String,
      memberName: json['memberName'] as String?,
      barcodeFormat: BarcodeFormat.values[json['barcodeFormat'] as int],
      brandColor: json['brandColor'] as int,
      customLogoPath: json['customLogoPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
