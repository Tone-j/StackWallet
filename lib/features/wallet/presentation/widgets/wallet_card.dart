import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/store_registry.dart';
import '../../../../core/utils/barcode_utils.dart';
import '../../data/models/loyalty_card.dart';

class WalletCard extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback? onBarcodeTap;

  const WalletCard({super.key, required this.card, this.onBarcodeTap});

  Color get _bg => Color(card.brandColor);

  Color get _textColor =>
      _bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

  Color get _subtextColor =>
      _bg.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _bg.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(13),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(8),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildLogo(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          card.storeName,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (card.isFavorite)
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber.shade300,
                          size: 22,
                        ),
                    ],
                  ),
                  if (card.memberName != null &&
                      card.memberName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      card.memberName!,
                      style: TextStyle(
                        color: _subtextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: onBarcodeTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: BarcodeWidget(
                            barcode: BarcodeUtils.getBarcodeType(
                              card.barcodeFormat,
                            ),
                            data: card.cardNumber,
                            color: _textColor,
                            drawText: false,
                            errorBuilder: (context, error) => Text(
                              'Invalid barcode',
                              style: TextStyle(
                                color: _subtextColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          BarcodeUtils.formatDisplayNumber(card.cardNumber),
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final store = StoreRegistry.findByName(card.storeName);
    if (store != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.asset(
          store.logoAsset,
          width: 36,
          height: 36,
        ),
      );
    }
    return _buildLetterAvatar();
  }

  Widget _buildLetterAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          card.storeName.isNotEmpty ? card.storeName[0].toUpperCase() : '?',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
