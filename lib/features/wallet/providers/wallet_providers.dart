import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/loyalty_card.dart';
import '../data/repositories/card_repository.dart';

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository();
});

final cardsProvider =
    StateNotifierProvider<CardsNotifier, List<LoyaltyCard>>((ref) {
  final repository = ref.read(cardRepositoryProvider);
  return CardsNotifier(repository);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCardsProvider = Provider<List<LoyaltyCard>>((ref) {
  final cards = ref.watch(cardsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return cards;

  return cards.where((card) {
    return card.storeName.toLowerCase().contains(query) ||
        card.cardNumber.contains(query) ||
        (card.memberName?.toLowerCase().contains(query) ?? false);
  }).toList();
});

final cardByIdProvider = Provider.family<LoyaltyCard?, String>((ref, id) {
  final cards = ref.watch(cardsProvider);
  for (final card in cards) {
    if (card.id == id) return card;
  }
  return null;
});

class CardsNotifier extends StateNotifier<List<LoyaltyCard>> {
  final CardRepository _repository;

  CardsNotifier(this._repository) : super([]) {
    _loadCards();
  }

  void _loadCards() {
    state = _repository.getAllCards();
  }

  Future<void> addCard(LoyaltyCard card) async {
    await _repository.saveCard(card);
    state = _repository.getAllCards();
  }

  Future<void> updateCard(LoyaltyCard card) async {
    await _repository.saveCard(card);
    state = _repository.getAllCards();
  }

  Future<void> deleteCard(String id) async {
    await _repository.deleteCard(id);
    state = _repository.getAllCards();
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    state = _repository.getAllCards();
  }
}
