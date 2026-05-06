// lib/features/settings/presentation/widgets/setting_tile.dart

import 'package:ehbien_lotto_admin/core/extensions/datetime_ext.dart';
import 'package:ehbien_lotto_admin/features/settings/domain/entities/app_setting_entity.dart';
import 'package:ehbien_lotto_admin/features/settings/presentation/providers/settings_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingTile extends ConsumerWidget {
  final AppSettingEntity setting;
  final IconData         icon;
  final String           label;
  final SettingType      type;

  const SettingTile({
    super.key,
    required this.setting,
    required this.icon,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // ── Icône ──────────────────────────────────
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:        AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Label + description ────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.primary,
                  ),
                ),
                if (setting.description.isNotEmpty)
                  Text(
                    setting.description,
                    style: TextStyle(
                      fontSize: 11,
                      color:    Colors.grey.shade500,
                    ),
                  ),
                Text(
                  'Mis à jour : ${setting.updatedAt.toDisplayDate}',
                  style: TextStyle(
                    fontSize: 10,
                    color:    Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Valeur éditable ────────────────────────
          _SettingValueEditor(
            setting: setting,
            type:    type,
            onSave: (newValue) async {
              await ref
                  .read(settingsNotifierProvider.notifier)
                  .updateSetting(
                    key:         setting.id,
                    valeur:      newValue,
                    description: setting.description,
                  );
            },
          ),
        ],
      ),
    );
  }
}

// ── Type de paramètre ─────────────────────────────────────────

enum SettingType { text, number, toggle, currency }

// ── Éditeur de valeur ─────────────────────────────────────────

class _SettingValueEditor extends StatefulWidget {
  final AppSettingEntity        setting;
  final SettingType             type;
  final Future<void> Function(dynamic) onSave;

  const _SettingValueEditor({
    required this.setting,
    required this.type,
    required this.onSave,
  });

  @override
  State<_SettingValueEditor> createState() =>
      _SettingValueEditorState();
}

class _SettingValueEditorState
    extends State<_SettingValueEditor> {
  bool _editing  = false;
  bool _loading  = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.setting.valeurString,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    dynamic value;
    switch (widget.type) {
      case SettingType.number:
      case SettingType.currency:
        value = double.tryParse(_ctrl.text) ??
            widget.setting.valeur;
        break;
      case SettingType.toggle:
        value = widget.setting.valeurBool;
        break;
      case SettingType.text:
        value = _ctrl.text.trim();
        break;
    }

    await widget.onSave(value);
    setState(() {
      _loading = false;
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == SettingType.toggle) {
      return _buildToggle();
    }

    if (_editing) {
      return _buildEditField();
    }

    return _buildDisplayValue();
  }

  Widget _buildToggle() {
    return Switch(
      value:    widget.setting.valeurBool,
      onChanged: _loading
          ? null
          : (v) => widget.onSave(v),
      activeThumbColor: AppColors.success,
    );
  }

  Widget _buildDisplayValue() {
    final suffix = widget.type == SettingType.currency
        ? ' G'
        : '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical:   6,
          ),
          decoration: BoxDecoration(
            color:        AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.setting.valeurString}$suffix',
            style: const TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon:    const Icon(Icons.edit_rounded, size: 16),
          color:   Colors.grey.shade400,
          onPressed: () => setState(() => _editing = true),
          tooltip: 'Modifier',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth:  32,
            minHeight: 32,
          ),
        ),
      ],
    );
  }

  Widget _buildEditField() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: TextFormField(
            controller:   _ctrl,
            autofocus:    true,
            keyboardType: widget.type == SettingType.number ||
                    widget.type == SettingType.currency
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical:   8,
              ),
              suffixText: widget.type == SettingType.currency
                  ? 'G'
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        _loading
            ? const SizedBox(
                width:  24,
                height: 24,
                child:  CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : IconButton(
                icon: const Icon(
                  Icons.check_rounded,
                  size: 16,
                ),
                color:     AppColors.success,
                onPressed: _save,
                tooltip:   'Sauvegarder',
                padding:   EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth:  32,
                  minHeight: 32,
                ),
              ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 16),
          color:     Colors.grey.shade400,
          onPressed: () => setState(() => _editing = false),
          tooltip:   'Annuler',
          padding:   EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth:  32,
            minHeight: 32,
          ),
        ),
      ],
    );
  }
}