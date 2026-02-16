import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'Appearance', theme: theme),
          _ThemeModeSelector(
            currentMode: themeMode,
            onChanged: (mode) {
              ref.read(themeModeProvider.notifier).state = mode;
            },
          ),
          const Divider(height: 1),
          _SectionHeader(title: 'About', theme: theme),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('App Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          const ListTile(
            leading: Icon(Icons.card_membership_rounded),
            title: Text(AppConstants.appName),
            subtitle: Text(
              'Your digital loyalty card wallet',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          subtitle: const Text('Always use light theme'),
          secondary: const Icon(Icons.light_mode_rounded),
          value: ThemeMode.light,
          groupValue: currentMode,
          onChanged: (v) => onChanged(v!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          subtitle: const Text('Always use dark theme'),
          secondary: const Icon(Icons.dark_mode_rounded),
          value: ThemeMode.dark,
          groupValue: currentMode,
          onChanged: (v) => onChanged(v!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System'),
          subtitle: const Text('Follow device settings'),
          secondary: const Icon(Icons.settings_brightness_rounded),
          value: ThemeMode.system,
          groupValue: currentMode,
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}
