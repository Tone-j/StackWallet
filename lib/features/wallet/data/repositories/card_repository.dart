import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/loyalty_card.dart';

class CardRepository {
  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(AppConstants.cardsBoxName);

  List<LoyaltyCard> getAllCards() {
    return _box.values.map((value) {
      final json = Map<String, dynamic>.from(value);
      return LoyaltyCard.fromJson(json);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  LoyaltyCard? getCard(String id) {
    final value = _box.get(id);
    if (value == null) return null;
    return LoyaltyCard.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> saveCard(LoyaltyCard card) async {
    await _box.put(card.id, card.toJson());
  }

  Future<void> deleteCard(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleFavorite(String id) async {
    final card = getCard(id);
    if (card != null) {
      await saveCard(card.copyWith(isFavorite: !card.isFavorite));
    }
  }
}
