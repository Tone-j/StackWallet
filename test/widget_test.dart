import 'package:flutter_test/flutter_test.dart';

import 'package:stack_wallet/features/wallet/data/models/loyalty_card.dart';

void main() {
  group('LoyaltyCard', () {
    test('create() generates unique id and timestamps', () {
      final card = LoyaltyCard.create(
        storeName: 'Clicks ClubCard',
        cardNumber: '1234567890',
        brandColor: 0xFF0072BC,
      );

      expect(card.id, isNotEmpty);
      expect(card.storeName, equals('Clicks ClubCard'));
      expect(card.cardNumber, equals('1234567890'));
      expect(card.isFavorite, isFalse);
      expect(card.barcodeFormat, equals(BarcodeFormat.code128));
    });

    test('toJson/fromJson round-trips correctly', () {
      final original = LoyaltyCard.create(
        storeName: 'Pick n Pay',
        cardNumber: '9876543210',
        memberName: 'Test User',
        brandColor: 0xFF003DA5,
        barcodeFormat: BarcodeFormat.qrCode,
        notes: 'Smart Shopper',
      );

      final json = original.toJson();
      final restored = LoyaltyCard.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.storeName, equals(original.storeName));
      expect(restored.cardNumber, equals(original.cardNumber));
      expect(restored.memberName, equals(original.memberName));
      expect(restored.barcodeFormat, equals(original.barcodeFormat));
      expect(restored.brandColor, equals(original.brandColor));
      expect(restored.notes, equals(original.notes));
    });

    test('copyWith preserves unchanged fields', () {
      final card = LoyaltyCard.create(
        storeName: 'Woolworths',
        cardNumber: '1111222233',
        brandColor: 0xFF1A1A1A,
      );

      final updated = card.copyWith(storeName: 'Woolworths WRewards');

      expect(updated.id, equals(card.id));
      expect(updated.storeName, equals('Woolworths WRewards'));
      expect(updated.cardNumber, equals(card.cardNumber));
      expect(updated.brandColor, equals(card.brandColor));
    });
  });
}
