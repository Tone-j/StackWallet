import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/barcode_utils.dart';
import '../../data/models/loyalty_card.dart';

class BarcodeFullscreenScreen extends StatefulWidget {
  final LoyaltyCard card;

  const BarcodeFullscreenScreen({super.key, required this.card});

  @override
  State<BarcodeFullscreenScreen> createState() =>
      _BarcodeFullscreenScreenState();
}

class _BarcodeFullscreenScreenState extends State<BarcodeFullscreenScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQr = widget.card.barcodeFormat == BarcodeFormat.qrCode;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.card.storeName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isQr ? 300 : double.infinity,
                        maxHeight: isQr ? 300 : 200,
                      ),
                      child: BarcodeWidget(
                        barcode: BarcodeUtils.getBarcodeType(
                          widget.card.barcodeFormat,
                        ),
                        data: widget.card.cardNumber,
                        color: Colors.black,
                        drawText: false,
                        errorBuilder:
                            (context, error) => const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    BarcodeUtils.formatDisplayNumber(widget.card.cardNumber),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.0,
                      color: Colors.black87,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap anywhere to close',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
