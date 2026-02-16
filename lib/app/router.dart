import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/wallet/presentation/screens/add_edit_card_screen.dart';
import '../features/wallet/presentation/screens/card_detail_screen.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const WalletScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),
      GoRoute(
        path: '/card/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage<void>(
            key: state.pageKey,
            child: CardDetailScreen(cardId: id),
          );
        },
      ),
      GoRoute(
        path: '/add',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AddEditCardScreen(),
              fullscreenDialog: true,
            ),
      ),
      GoRoute(
        path: '/edit/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage<void>(
            key: state.pageKey,
            child: AddEditCardScreen(cardId: id),
            fullscreenDialog: true,
          );
        },
      ),
    ],
  );
});
