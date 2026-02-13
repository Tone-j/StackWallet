import 'package:flutter/material.dart';

import '../../features/wallet/data/models/loyalty_card.dart';

class SARetailer {
  final String name;
  final Color brandColor;
  final BarcodeFormat defaultFormat;

  const SARetailer({
    required this.name,
    required this.brandColor,
    this.defaultFormat = BarcodeFormat.code128,
  });
}

class SARetailers {
  SARetailers._();

  static const List<SARetailer> all = [
    SARetailer(name: 'Clicks ClubCard', brandColor: Color(0xFF0072BC)),
    SARetailer(name: 'Pick n Pay Smart Shopper', brandColor: Color(0xFF003DA5)),
    SARetailer(name: 'Woolworths WRewards', brandColor: Color(0xFF1A1A1A)),
    SARetailer(name: 'Checkers Xtra Savings', brandColor: Color(0xFFD52B1E)),
    SARetailer(name: 'Dis-Chem Benefit', brandColor: Color(0xFF00A651)),
    SARetailer(name: 'Spar Rewards', brandColor: Color(0xFFE30613)),
    SARetailer(name: 'Makro mCard', brandColor: Color(0xFF0033A0)),
    SARetailer(name: 'Game', brandColor: Color(0xFF00529B)),
    SARetailer(name: 'TFG Rewards', brandColor: Color(0xFF1A1A1A)),
    SARetailer(name: 'Mr Price Money', brandColor: Color(0xFFE31837)),
    SARetailer(name: 'Engen 1Plus', brandColor: Color(0xFF004B87)),
    SARetailer(name: 'Shell V+', brandColor: Color(0xFFDD1D21)),
    SARetailer(name: 'Sasol Rewards', brandColor: Color(0xFF003F87)),
    SARetailer(name: 'Edgars Thank U', brandColor: Color(0xFF1A1A1A)),
    SARetailer(name: 'Jet Thank U', brandColor: Color(0xFFE31837)),
    SARetailer(name: 'Vitality Health', brandColor: Color(0xFFF26522)),
    SARetailer(name: 'Capitec Live Better', brandColor: Color(0xFF003DA5)),
    SARetailer(name: 'FNB eBucks', brandColor: Color(0xFF009A44)),
    SARetailer(name: 'Builders Warehouse', brandColor: Color(0xFF003DA5)),
    SARetailer(name: 'Ackermans', brandColor: Color(0xFFE4002B)),
    SARetailer(name: 'Pep', brandColor: Color(0xFFE31837)),
  ];

  static SARetailer? findByName(String name) {
    final lower = name.toLowerCase();
    for (final retailer in all) {
      if (retailer.name.toLowerCase().contains(lower) ||
          lower.contains(retailer.name.toLowerCase())) {
        return retailer;
      }
    }
    return null;
  }
}
