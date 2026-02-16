import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/sa_retailers.dart';
import '../../../../core/utils/barcode_utils.dart';
import '../../data/models/loyalty_card.dart';
import '../../providers/wallet_providers.dart';

class AddEditCardScreen extends ConsumerStatefulWidget {
  final String? cardId;

  const AddEditCardScreen({super.key, this.cardId});

  bool get isEditing => cardId != null;

  @override
  ConsumerState<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends ConsumerState<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _notesController = TextEditingController();

  BarcodeFormat _selectedFormat = BarcodeFormat.code128;
  Color _selectedColor = AppColors.brandColorPalette.first;
  String? _customLogoPath;
  bool _initialized = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _cardNumberController.dispose();
    _memberNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFromCard(LoyaltyCard card) {
    if (_initialized) return;
    _initialized = true;
    _storeNameController.text = card.storeName;
    _cardNumberController.text = card.cardNumber;
    _memberNameController.text = card.memberName ?? '';
    _notesController.text = card.notes ?? '';
    _selectedFormat = card.barcodeFormat;
    _selectedColor = Color(card.brandColor);
    _customLogoPath = card.customLogoPath;
  }

  void _onRetailerMatch(String value) {
    final retailer = SARetailers.findByName(value);
    if (retailer != null) {
      setState(() {
        _selectedColor = retailer.brandColor;
        _selectedFormat = retailer.defaultFormat;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _customLogoPath = image.path);
    }
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) return;

    final storeName = _storeNameController.text.trim();
    final cardNumber = _cardNumberController.text.trim();
    final memberName = _memberNameController.text.trim();
    final notes = _notesController.text.trim();

    if (widget.isEditing) {
      final existing = ref.read(cardByIdProvider(widget.cardId!));
      if (existing == null) return;

      final updated = existing.copyWith(
        storeName: storeName,
        cardNumber: cardNumber,
        memberName: memberName.isEmpty ? null : memberName,
        barcodeFormat: _selectedFormat,
        brandColor: _selectedColor.toARGB32(),
        customLogoPath: _customLogoPath,
        notes: notes.isEmpty ? null : notes,
      );
      ref.read(cardsProvider.notifier).updateCard(updated);
    } else {
      final card = LoyaltyCard.create(
        storeName: storeName,
        cardNumber: cardNumber,
        memberName: memberName.isEmpty ? null : memberName,
        barcodeFormat: _selectedFormat,
        brandColor: _selectedColor.toARGB32(),
        customLogoPath: _customLogoPath,
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
            // Live preview card
            _buildPreviewCard(),
            const SizedBox(height: 32),

            // Store Name with autocomplete
            const _SectionLabel(label: 'Store Name'),
            const SizedBox(height: 8),
            Autocomplete<SARetailer>(
              initialValue:
                  TextEditingValue(text: _storeNameController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<SARetailer>.empty();
                }
                return SARetailers.all.where(
                  (r) => r.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()),
                );
              },
              displayStringForOption: (retailer) => retailer.name,
              onSelected: (retailer) {
                _storeNameController.text = retailer.name;
                setState(() {
                  _selectedColor = retailer.brandColor;
                  _selectedFormat = retailer.defaultFormat;
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onSubmitted) {
                controller.addListener(() {
                  if (controller.text != _storeNameController.text) {
                    _storeNameController.text = controller.text;
                    _onRetailerMatch(controller.text);
                  }
                });
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Clicks ClubCard',
                    prefixIcon: Icon(Icons.store_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Store name is required'
                      : null,
                  onChanged: (_) => setState(() {}),
                );
              },
            ),
            const SizedBox(height: 20),

            // Card Number
            const _SectionLabel(label: 'Card Number'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                hintText: 'Enter your card number',
                prefixIcon: Icon(Icons.credit_card_rounded),
              ),
              keyboardType: TextInputType.text,
              onChanged: (_) => setState(() {}),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Card number is required'
                  : null,
            ),
            const SizedBox(height: 20),

            // Member Name
            const _SectionLabel(label: 'Member Name (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memberNameController,
              decoration: const InputDecoration(
                hintText: 'Your name on the card',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Barcode Format
            const _SectionLabel(label: 'Barcode Format'),
            const SizedBox(height: 8),
            _buildFormatSelector(),
            const SizedBox(height: 20),

            // Brand Colour
            const _SectionLabel(label: 'Card Colour'),
            const SizedBox(height: 8),
            _buildColorPicker(theme),
            const SizedBox(height: 20),

            // Logo
            const _SectionLabel(label: 'Card Logo (Optional)'),
            const SizedBox(height: 8),
            _buildLogoPicker(theme),
            const SizedBox(height: 20),

            // Notes
            const _SectionLabel(label: 'Notes (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Any additional notes...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
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
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Preview ──────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    final textColor = _selectedColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    final subtextColor = _selectedColor.computeLuminance() > 0.5
        ? Colors.black54
        : Colors.white70;

    final storeName = _storeNameController.text.isEmpty
        ? 'Store Name'
        : _storeNameController.text;
    final cardNumber = _cardNumberController.text.isEmpty
        ? '0000 0000 0000'
        : _cardNumberController.text;
    final memberName = _memberNameController.text;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _selectedColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withAlpha(77),
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
                  if (memberName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      memberName,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
    if (_customLogoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_customLogoPath!),
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _buildLetterAvatar(textColor),
        ),
      );
    }
    return _buildLetterAvatar(textColor);
  }

  Widget _buildLetterAvatar(Color textColor) {
    final name = _storeNameController.text;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'S',
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

  // ── Colour Picker ────────────────────────────────────────────────────

  Widget _buildColorPicker(ThemeData theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppColors.brandColorPalette.map((color) {
        final isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(102),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ── Logo Picker ──────────────────────────────────────────────────────

  Widget _buildLogoPicker(ThemeData theme) {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(77),
              ),
            ),
            child: _customLogoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_customLogoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_rounded),
                    ),
                  )
                : const Icon(Icons.add_photo_alternate_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _customLogoPath != null
                ? 'Logo selected'
                : 'Tap to add a store logo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (_customLogoPath != null)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => setState(() => _customLogoPath = null),
          ),
      ],
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
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
