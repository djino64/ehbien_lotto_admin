// lib/features/notifications/presentation/widgets/send_notification_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';

class SendNotificationDialog extends ConsumerStatefulWidget {
  const SendNotificationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const SendNotificationDialog(),
    );
  }

  @override
  ConsumerState<SendNotificationDialog> createState() =>
      _SendNotificationDialogState();
}

class _SendNotificationDialogState
    extends ConsumerState<SendNotificationDialog> {
  final _formKey  = GlobalKey<FormState>();
  final _titreCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool              _broadcast = true;
  String?           _agentId;
  NotificationType  _type = NotificationType.message;
  String?           _error;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_broadcast && _agentId == null) {
      setState(() => _error = 'Veuillez sélectionner un agent.');
      return;
    }

    setState(() => _error = null);

    String? err;
    if (_broadcast) {
      err = await ref
          .read(notificationsNotifierProvider.notifier)
          .broadcast(
            type:    _type,
            titre:   _titreCtrl.text.trim(),
            message: _messageCtrl.text.trim(),
          );
    } else {
      err = await ref
          .read(notificationsNotifierProvider.notifier)
          .send(
            agentId: _agentId,
            type:    _type,
            titre:   _titreCtrl.text.trim(),
            message: _messageCtrl.text.trim(),
          );
    }

    if (err != null) {
      setState(() => _error = err);
    } else if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(notificationsNotifierProvider).isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.dialogRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth:  520,
          maxHeight: 620,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ──────────────────────────────────
              Row(
                children: [
                  Container(
                    padding:    const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                      size:  18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Envoyer une notification',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:      const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding:   EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32, minHeight: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Destinataire ────────────────
                        const _SectionLabel(
                          'Destinataire',
                          Icons.people_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Row(
                          children: [
                            Expanded(
                              child: _TargetOption(
                                label:    'Tous les agents',
                                subtitle: 'Broadcast',
                                icon:     Icons.public_rounded,
                                selected: _broadcast,
                                onTap: () =>
                                    setState(() => _broadcast = true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _TargetOption(
                                label:    'Agent spécifique',
                                subtitle: 'Ciblé',
                                icon:     Icons.person_rounded,
                                selected: !_broadcast,
                                onTap: () =>
                                    setState(() => _broadcast = false),
                              ),
                            ),
                          ],
                        ),

                        if (!_broadcast) ...[
                          const SizedBox(height: AppSpacing.md),
                          _AgentDropdown(
                            value:     _agentId,
                            onChanged: (v) =>
                                setState(() => _agentId = v),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.md),

                        // ── Type ────────────────────────
                        const _SectionLabel(
                          'Type de notification',
                          Icons.label_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Wrap(
                          spacing: AppSpacing.sm,
                          children: NotificationType.values
                              .map(
                                (t) => ChoiceChip(
                                  label: Text(
                                    _typeLabel(t),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _type == t
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                  selected:      _type == t,
                                  onSelected: (_) =>
                                      setState(() => _type = t),
                                  selectedColor: _typeColor(t),
                                  backgroundColor:
                                      _typeColor(t).withOpacity(0.08),
                                  side: BorderSide(
                                    color: _typeColor(t).withOpacity(0.4),
                                  ),
                                ),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Contenu ─────────────────────
                        const _SectionLabel(
                          'Contenu',
                          Icons.edit_rounded,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        TextFormField(
                          controller: _titreCtrl,
                          decoration: const InputDecoration(
                            labelText:  'Titre',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (v) =>
                              Validators.required(v, label: 'Le titre'),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        TextFormField(
                          controller: _messageCtrl,
                          maxLines:   4,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            prefixIcon: Icon(Icons.message_rounded),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => Validators.required(
                            v,
                            label: 'Le message',
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color:    AppColors.danger,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Actions ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _send,
                      icon: isLoading
                          ? const SizedBox(
                              width:  16,
                              height: 16,
                              child:  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:       Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              size: 16,
                            ),
                      label: Text(
                        isLoading ? 'Envoi...' : 'Envoyer',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(NotificationType t) => switch (t) {
    NotificationType.tirage   => 'Tirage',
    NotificationType.resultat => 'Résultat',
    NotificationType.gagnant  => 'Gagnant',
    NotificationType.blocage  => 'Blocage',
    NotificationType.message  => 'Message',
  };

  Color _typeColor(NotificationType t) => switch (t) {
    NotificationType.tirage   => AppColors.info,
    NotificationType.resultat => AppColors.success,
    NotificationType.gagnant  => AppColors.warning,
    NotificationType.blocage  => AppColors.danger,
    NotificationType.message  => AppColors.primary,
  };
}

// ── Sous-widgets ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String   label;
  final IconData icon;

  const _SectionLabel(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w600,
            color:      AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _TargetOption extends StatelessWidget {
  final String   label;
  final String   subtitle;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _TargetOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color:        selected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size:  18,
              color: selected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                    color:      selected
                        ? AppColors.primary
                        : Colors.grey.shade700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color:    Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentDropdown extends ConsumerWidget {
  final String?            value;
  final ValueChanged<String?> onChanged;

  const _AgentDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(agentsStreamProvider).valueOrNull ?? [];
    return DropdownButtonFormField<String>(
      initialValue:      value,
      onChanged:  onChanged,
      decoration: const InputDecoration(
        labelText:  'Agent destinataire',
        prefixIcon: Icon(Icons.person_rounded),
      ),
      hint: const Text('Sélectionner un agent'),
      items: agents
          .where((a) => a.isActif)
          .map(
            (a) => DropdownMenuItem(
              value: a.id,
              child: Text(a.nom),
            ),
          )
          .toList(),
    );
  }
}