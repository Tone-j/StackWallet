import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/barcode_utils.dart';
import '../../data/models/loyalty_card.dart';

class BarcodeDisplay extends StatelessWidget {
  final LoyaltyCard card;

  const BarcodeDisplay({super.key, required this.card});

  bool get _isQrCode => card.barcodeFormat == BarcodeFormat.qrCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHeight = _isQrCode ? 220.0 : 120.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: effectiveHeight,
            child: BarcodeWidget(
              barcode: BarcodeUtils.getBarcodeType(card.barcodeFormat),
              data: card.cardNumber,
              color: Colors.black,
              drawText: false,
              errorBuilder: (context, error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.error, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Could not generate barcode',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check the card number format',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            BarcodeUtils.formatDisplayNumber(card.cardNumber),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
              color: Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            BarcodeUtils.formatLabel(card.barcodeFormat),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
