import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/barcode_utils.dart';
import '../../data/models/loyalty_card.dart';
import '../../providers/wallet_providers.dart';
import '../widgets/barcode_display.dart';
import '../widgets/wallet_card.dart';
import 'barcode_fullscreen_screen.dart';

class CardDetailScreen extends ConsumerWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  void _openFullscreenBarcode(BuildContext context, LoyaltyCard card) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => BarcodeFullscreenScreen(card: card),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(cardByIdProvider(cardId));
    final theme = Theme.of(context);

    if (card == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Card not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(card.storeName),
        actions: [
          IconButton(
            icon: Icon(
              card.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: card.isFavorite ? Colors.amber : null,
            ),
            onPressed: () {
              ref.read(cardsProvider.notifier).toggleFavorite(card.id);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  context.push('/edit/${card.id}');
                case 'delete':
                  final confirmed = await _showDeleteDialog(context);
                  if (confirmed && context.mounted) {
                    ref.read(cardsProvider.notifier).deleteCard(card.id);
                    context.go('/');
                  }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_rounded),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_rounded,
                      color: theme.colorScheme.error),
                  title: Text('Delete',
                      style: TextStyle(color: theme.colorScheme.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'card-${card.id}',
              child: WalletCard(
                card: card,
                onBarcodeTap: () => _openFullscreenBarcode(context, card),
              ),
            ),
            const SizedBox(height: 24),
            BarcodeDisplay(
              card: card,
              onTap: () => _openFullscreenBarcode(context, card),
            ),
            const SizedBox(height: 24),
            _InfoSection(card: card),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Card'),
            content: const Text(
              'Are you sure you want to delete this card? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _InfoSection extends StatelessWidget {
  final LoyaltyCard card;

  const _InfoSection({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Card Number',
            value: BarcodeUtils.formatDisplayNumber(card.cardNumber),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: card.cardNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card number copied'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Copy card number',
            ),
          ),
          if (card.memberName != null && card.memberName!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(label: 'Member Name', value: card.memberName!),
          ],
          const Divider(height: 24),
          _InfoRow(
            label: 'Barcode Format',
            value: BarcodeUtils.formatLabel(card.barcodeFormat),
          ),
          if (card.notes != null && card.notes!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(label: 'Notes', value: card.notes!),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
