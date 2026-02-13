import 'package:flutter/material.dart';

import '../../data/models/loyalty_card.dart';
import 'wallet_card.dart';

class CardStack extends StatelessWidget {
  final List<LoyaltyCard> cards;
  final void Function(LoyaltyCard card) onCardTap;
  final void Function(LoyaltyCard card)? onCardLongPress;

  const CardStack({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.onCardLongPress,
  });

  static const double _cardHeight = 200.0;
  static const double _visiblePortion = 88.0;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final totalHeight =
        (cards.length - 1) * _visiblePortion + _cardHeight + 24;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < cards.length; i++)
              Positioned(
                top: i * _visiblePortion,
                left: 0,
                right: 0,
                height: _cardHeight,
                child: _CardEntry(
                  card: cards[i],
                  onTap: () => onCardTap(cards[i]),
                  onLongPress: onCardLongPress != null
                      ? () => onCardLongPress!(cards[i])
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardEntry extends StatefulWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CardEntry({
    required this.card,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_CardEntry> createState() => _CardEntryState();
}

class _CardEntryState extends State<_CardEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Hero(
          tag: 'card-${widget.card.id}',
          child: WalletCard(card: widget.card),
        ),
      ),
    );
  }
}
