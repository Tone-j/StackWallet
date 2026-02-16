import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/store_registry.dart';
import '../../../../core/utils/barcode_utils.dart';
import '../../data/models/loyalty_card.dart';
import '../../providers/wallet_providers.dart';
import 'barcode_scanner_screen.dart';

class AddEditCardScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const AddEditCardScreen({super.key, this.cardId});

  bool get isEditing => cardId != null;

  @override
  ConsumerState<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends ConsumerState<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _notesController = TextEditingController();

  StoreConfig? _selectedStore;
  BarcodeFormat _selectedFormat = BarcodeFormat.code128;
  bool _initialized = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _memberNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromCard(LoyaltyCard card) {
    if (_initialized) return;
    _initialized = true;
    _selectedStore = StoreRegistry.findByName(card.storeName);
    _cardNumberController.text = card.cardNumber;
    _memberNameController.text = card.memberName ?? '';
    _notesController.text = card.notes ?? '';
    _selectedFormat = card.barcodeFormat;
  }

  Color get _cardColor =>
      _selectedStore?.brandColor ?? const Color(0xFF263238);

  Future<void> _scanBarcode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _cardNumberController.text = result;
      });
    }
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a store'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final storeName = _selectedStore!.name;
    final cardNumber = _cardNumberController.text.trim();
    final memberName = _memberNameController.text.trim();
    final notes = _notesController.text.trim();
    final brandColor = _selectedStore!.brandColor.toARGB32();

    if (widget.isEditing) {
      final existing = ref.read(cardByIdProvider(widget.cardId!));
      if (existing == null) return;

      final updated = existing.copyWith(
        storeName: storeName,
        cardNumber: cardNumber,
        memberName: memberName.isEmpty ? null : memberName,
        barcodeFormat: _selectedFormat,
        brandColor: brandColor,
        notes: notes.isEmpty ? null : notes,
      );
      ref.read(cardsProvider.notifier).updateCard(updated);
    } else {
      final card = LoyaltyCard.create(
        storeName: storeName,
        cardNumber: cardNumber,
        memberName: memberName.isEmpty ? null : memberName,
        barcodeFormat: _selectedFormat,
        brandColor: brandColor,
        notes: notes.isEmpty ? null : notes,
      );
      ref.read(cardsProvider.notifier).addCard(card);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_initialized) {
      final card = ref.read(cardByIdProvider(widget.cardId!));
      if (card != null) _initFromCard(card);
    }
    if (!widget.isEditing) _initialized = true;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isEditing ? 'Edit Card' : 'Add Card'),
        actions: [
          TextButton(
            onPressed: _saveCard,
            child: Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 32),

            // Store Dropdown
            const _SectionLabel(label: 'Store'),
            const SizedBox(height: 8),
            _buildStoreDropdown(theme),
            const SizedBox(height: 20),

            // Card Number with scanner
            const _SectionLabel(label: 'Card Number'),
            const SizedBox(height: 8),
            _buildCardNumberField(),
            const SizedBox(height: 20),

            // Barcode Format
            const _SectionLabel(label: 'Barcode Format'),
            const SizedBox(height: 8),
            _buildFormatSelector(),
            const SizedBox(height: 32),

            // Save Button
            FilledButton(
              onPressed: _saveCard,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isEditing ? 'Update Card' : 'Add to Wallet',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Store Dropdown ──────────────────────────────────────────────────

  Widget _buildStoreDropdown(ThemeData theme) {
    return DropdownButtonFormField<StoreConfig>(
      value: _selectedStore,
      decoration: const InputDecoration(
        hintText: 'Select a store',
        prefixIcon: Icon(Icons.store_rounded),
      ),
      isExpanded: true,
      items: StoreRegistry.stores.map((store) {
        return DropdownMenuItem<StoreConfig>(
          value: store,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SvgPicture.asset(
                  store.logoAsset,
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  store.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (store) {
        if (store != null) {
          setState(() {
            _selectedStore = store;
            _selectedFormat = store.defaultFormat;
          });
        }
      },
      validator: (v) => v == null ? 'Please select a store' : null,
    );
  }

  // ── Card Number Field ─────────────────────────────────────────────

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: InputDecoration(
        hintText: 'Enter or scan your card number',
        prefixIcon: const Icon(Icons.credit_card_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          onPressed: _scanBarcode,
          tooltip: 'Scan barcode',
        ),
      ),
      keyboardType: TextInputType.text,
      onChanged: (_) => setState(() {}),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Card number is required' : null,
    );
  }

  // ── Preview ──────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    final textColor =
        _cardColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    final storeName = _selectedStore?.name ?? 'Store Name';
    final cardNumber = _cardNumberController.text.isEmpty
        ? '0000 0000 0000'
        : _cardNumberController.text;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPreviewLogo(textColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          storeName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    BarcodeUtils.formatDisplayNumber(cardNumber),
                    style: TextStyle(
                      color: textColor,
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
    );
  }

  Widget _buildPreviewLogo(Color textColor) {
    if (_selectedStore != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.asset(
          _selectedStore!.logoAsset,
          width: 36,
          height: 36,
        ),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ── Format Selector ──────────────────────────────────────────────────

  Widget _buildFormatSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BarcodeFormat.values.map((format) {
        final isSelected = format == _selectedFormat;
        return ChoiceChip(
          label: Text(BarcodeUtils.formatLabel(format)),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedFormat = format),
        );
      }).toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
