import 'package:flutter/material.dart';

import '../../features/wallet/data/models/loyalty_card.dart';

class StoreConfig {
  final String id;
  final String name;
  final Color brandColor;
  final BarcodeFormat defaultFormat;
  final String logoAsset;

  const StoreConfig({
    required this.id,
    required this.name,
    required this.brandColor,
    this.defaultFormat = BarcodeFormat.code128,
    required this.logoAsset,
  });
}

class StoreRegistry {
  StoreRegistry._();

  static const List<StoreConfig> stores = [
    StoreConfig(
      id: 'clicks',
      name: 'Clicks ClubCard',
      brandColor: Color(0xFF0072BC),
      logoAsset: 'assets/loyalty/clicks.svg',
    ),
    StoreConfig(
      id: 'pick_n_pay',
      name: 'Pick n Pay Smart Shopper',
      brandColor: Color(0xFF003DA5),
      logoAsset: 'assets/loyalty/pick_n_pay.svg',
    ),
    StoreConfig(
      id: 'woolworths',
      name: 'Woolworths WRewards',
      brandColor: Color(0xFF1A1A1A),
      logoAsset: 'assets/loyalty/woolworths.svg',
    ),
    StoreConfig(
      id: 'checkers',
      name: 'Checkers Xtra Savings',
      brandColor: Color.fromARGB(255, 68, 201, 238),
      logoAsset: 'assets/loyalty/checkers.svg',
    ),
    StoreConfig(
      id: 'dischem',
      name: 'Dis-Chem Benefit',
      brandColor: Color(0xFF00A651),
      logoAsset: 'assets/loyalty/dischem.svg',
    ),
    StoreConfig(
      id: 'spar',
      name: 'Spar Rewards',
      brandColor: Color.fromARGB(255, 94, 240, 75),
      logoAsset: 'assets/loyalty/spar.svg',
    ),
    StoreConfig(
      id: 'makro',
      name: 'Makro mCard',
      brandColor: Color.fromARGB(255, 216, 238, 19),
      logoAsset: 'assets/loyalty/makro.svg',
    ),
    StoreConfig(
      id: 'game',
      name: 'Game',
      brandColor: Color.fromARGB(255, 207, 65, 209),
      logoAsset: 'assets/loyalty/game.svg',
    ),
    StoreConfig(
      id: 'tfg',
      name: 'TFG Rewards',
      brandColor: Color.fromARGB(255, 13, 74, 138),
      logoAsset: 'assets/loyalty/tfg.svg',
    ),
    StoreConfig(
      id: 'mr_price',
      name: 'Mr Price Money',
      brandColor: Color(0xFFE31837),
      logoAsset: 'assets/loyalty/mr_price.svg',
    ),
    StoreConfig(
      id: 'engen',
      name: 'Engen 1Plus',
      brandColor: Color(0xFF004B87),
      logoAsset: 'assets/loyalty/engen.svg',
    ),
    StoreConfig(
      id: 'shell',
      name: 'Shell V+',
      brandColor: Color(0xFFDD1D21),
      logoAsset: 'assets/loyalty/shell.svg',
    ),
    StoreConfig(
      id: 'sasol',
      name: 'Sasol Rewards',
      brandColor: Color(0xFF003F87),
      logoAsset: 'assets/loyalty/sasol.svg',
    ),
    StoreConfig(
      id: 'edgars',
      name: 'Edgars Thank U',
      brandColor: Color.fromARGB(255, 172, 6, 6),
      logoAsset: 'assets/loyalty/edgars.svg',
    ),
    StoreConfig(
      id: 'jet',
      name: 'Jet Thank U',
      brandColor: Color.fromARGB(255, 89, 23, 22),
      logoAsset: 'assets/loyalty/jet.svg',
    ),
    StoreConfig(
      id: 'vitality',
      name: 'Vitality Health',
      brandColor: Color(0xFFF26522),
      logoAsset: 'assets/loyalty/vitality.svg',
    ),
    StoreConfig(
      id: 'capitec',
      name: 'Capitec Live Better',
      brandColor: Color(0xFF003DA5),
      logoAsset: 'assets/loyalty/capitec.svg',
    ),
    StoreConfig(
      id: 'fnb',
      name: 'FNB eBucks',
      brandColor: Color.fromARGB(255, 33, 137, 185),
      logoAsset: 'assets/loyalty/fnb.svg',
    ),
    StoreConfig(
      id: 'builders',
      name: 'Builders Warehouse',
      brandColor: Color.fromARGB(255, 240, 240, 18),
      logoAsset: 'assets/loyalty/builders.svg',
    ),
    StoreConfig(
      id: 'ackermans',
      name: 'Ackermans',
      brandColor: Color.fromARGB(255, 17, 215, 74),
      logoAsset: 'assets/loyalty/ackermans.svg',
    ),
    StoreConfig(
      id: 'pep',
      name: 'Pep',
      brandColor: Color.fromARGB(255, 86, 152, 209),
      logoAsset: 'assets/loyalty/pep.svg',
    ),
  ];

  static StoreConfig? findByName(String name) {
    final lower = name.toLowerCase();
    for (final store in stores) {
      if (store.name.toLowerCase() == lower) {
        return store;
      }
    }
    return null;
  }

  static StoreConfig? findById(String id) {
    for (final store in stores) {
      if (store.id == id) return store;
    }
    return null;
  }
}
