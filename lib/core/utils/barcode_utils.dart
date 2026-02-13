import 'package:barcode/barcode.dart' as bc;

import '../../features/wallet/data/models/loyalty_card.dart';

class BarcodeUtils {
  BarcodeUtils._();

  static bc.Barcode getBarcodeType(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.code128 => bc.Barcode.code128(),
      BarcodeFormat.code39 => bc.Barcode.code39(),
      BarcodeFormat.ean13 => bc.Barcode.ean13(),
      BarcodeFormat.ean8 => bc.Barcode.ean8(),
      BarcodeFormat.qrCode => bc.Barcode.qrCode(),
      BarcodeFormat.upcA => bc.Barcode.upcA(),
      BarcodeFormat.pdf417 => bc.Barcode.pdf417(),
    };
  }

  static String formatDisplayNumber(String number) {
    if (number.length <= 4) return number;
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(number[i]);
    }
    return buffer.toString();
  }

  static String formatLabel(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.code128 => 'Code 128',
      BarcodeFormat.code39 => 'Code 39',
      BarcodeFormat.ean13 => 'EAN-13',
      BarcodeFormat.ean8 => 'EAN-8',
      BarcodeFormat.qrCode => 'QR Code',
      BarcodeFormat.upcA => 'UPC-A',
      BarcodeFormat.pdf417 => 'PDF417',
    };
  }
}
