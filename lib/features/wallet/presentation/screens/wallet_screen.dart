import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/wallet_providers.dart';
import '../widgets/card_stack.dart';
import '../widgets/empty_wallet.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).state = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(filteredCardsProvider);
    final allCards = ref.watch(cardsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search cards...',
                  border: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              )
            : const Text('StackWallet'),
        actions: [
          if (allCards.isNotEmpty)
            IconButton(
              icon:
                  Icon(_isSearching ? Icons.close : Icons.search_rounded),
              onPressed: _toggleSearch,
              tooltip: _isSearching ? 'Close search' : 'Search',
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: allCards.isEmpty
          ? EmptyWallet(onAddCard: () => context.push('/add'))
          : cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cards match your search',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : CardStack(
                  cards: cards,
                  onCardTap: (card) => context.push('/card/${card.id}'),
                  onCardLongPress: (card) {
                    ref.read(cardsProvider.notifier).toggleFavorite(card.id);
                  },
                ),
      floatingActionButton: allCards.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push('/add'),
              tooltip: 'Add card',
              child: const Icon(Icons.add_card_rounded),
            )
          : null,
    );
  }
}
