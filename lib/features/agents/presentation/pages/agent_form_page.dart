// lib/features/agents/presentation/pages/agent_form_page.dart

import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/features/agents/domain/entities/agent_entity.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/providers/agents_provider.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/providers/succursales_provider.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/shared/widgets/feedback/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AgentFormPage extends ConsumerStatefulWidget {
  final String? agentId;

  const AgentFormPage({super.key, this.agentId});

  bool get isEdit => agentId != null;

  @override
  ConsumerState<AgentFormPage> createState() => _AgentFormPageState();
}

class _AgentFormPageState extends ConsumerState<AgentFormPage> {
  final _formKey      = GlobalKey<FormState>();
  final _nomCtrl      = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _limiteCtrl   = TextEditingController(text: '5000');

  String?      _succursaleId;
  AgentStatus  _status = AgentStatus.actif;
  bool         _obscurePassword = true;
  String?      _errorMessage;
  bool         _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _loadAgent();
  }

  Future<void> _loadAgent() async {
    final result = await ref
        .read(agentsRepositoryProvider)
        .getAgentById(widget.agentId!);
    result.fold(
      (f) => setState(() => _errorMessage = f.message),
      (agent) {
        setState(() {
          _nomCtrl.text   = agent.nom;
          _phoneCtrl.text = agent.phone;
          _limiteCtrl.text = agent.limiteJournaliere.toStringAsFixed(0);
          _succursaleId   = agent.succursaleId;
          _status         = agent.status;
        });
      },
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _limiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_succursaleId == null) {
      setState(() => _errorMessage = 'Veuillez sélectionner une succursale.');
      return;
    }

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    String? error;

    if (widget.isEdit) {
      error = await ref
          .read(agentsNotifierProvider.notifier)
          .updateAgent(
            id: widget.agentId!,
            data: {
              'nom':               _nomCtrl.text.trim(),
              'phone':             _phoneCtrl.text.trim(),
              'succursaleId':      _succursaleId,
              'limiteJournaliere': double.tryParse(_limiteCtrl.text) ?? 5000,
              'status':            _status.name,
            },
          );
    } else {
      error = await ref
          .read(agentsNotifierProvider.notifier)
          .createAgent(
            nom:               _nomCtrl.text.trim(),
            phone:             _phoneCtrl.text.trim(),
            succursaleId:      _succursaleId!,
            motDePasseTemp:    _passwordCtrl.text,
            limiteJournaliere: double.tryParse(_limiteCtrl.text) ?? 5000,
          );
    }

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else if (mounted) {
      _showSuccess();
      context.go(RouteNames.agentsList);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.isEdit
                  ? 'Agent modifié avec succès'
                  : 'Agent créé avec succès',
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────
                _FormHeader(isEdit: widget.isEdit),

                const SizedBox(height: AppSpacing.lg),

                // ── Formulaire ───────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Informations personnelles ──
                          const _SectionTitle(
                            icon:  Icons.person_rounded,
                            label: 'Informations personnelles',
                          ),

                          const SizedBox(height: AppSpacing.md),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nomCtrl,
                                  decoration: const InputDecoration(
                                    labelText:  'Nom complet',
                                    prefixIcon: Icon(Icons.badge_rounded),
                                  ),
                                  validator: (v) =>
                                      Validators.required(v, label: 'Le nom'),
                                  textCapitalization:
                                      TextCapitalization.words,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneCtrl,
                                  decoration: const InputDecoration(
                                    labelText:  'Téléphone',
                                    prefixIcon: Icon(Icons.phone_rounded),
                                    hintText:   'ex: 36000000',
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator:    Validators.phone,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Mot de passe (création seulmt) ──
                          if (!widget.isEdit) ...[
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText:  'Mot de passe temporaire',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword =
                                        !_obscurePassword,
                                  ),
                                ),
                              ),
                              validator: Validators.password,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // ── Succursale ──────────────────
                          const _SectionTitle(
                            icon:  Icons.store_mall_directory_rounded,
                            label: 'Affectation',
                          ),

                          const SizedBox(height: AppSpacing.md),

                          _SuccursaleDropdown(
                            value:    _succursaleId,
                            onChanged: (v) =>
                                setState(() => _succursaleId = v),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ── Limites & statut ────────────
                          const _SectionTitle(
                            icon:  Icons.tune_rounded,
                            label: 'Paramètres',
                          ),

                          const SizedBox(height: AppSpacing.md),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _limiteCtrl,
                                  decoration: const InputDecoration(
                                    labelText:  'Limite journalière (G)',
                                    prefixIcon: Icon(Icons.speed_rounded),
                                    suffixText: 'G',
                                  ),
                                  keyboardType:
                                      TextInputType.number,
                                  validator: Validators.positiveAmount,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _StatusDropdown(
                                  value:    _status,
                                  onChanged: (v) =>
                                      setState(() => _status = v!),
                                ),
                              ),
                            ],
                          ),

                          // ── Erreur ──────────────────────
                          if (_errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _ErrorBanner(message: _errorMessage!),
                          ],

                          const SizedBox(height: AppSpacing.lg),

                          // ── Boutons ─────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => context.go(
                                  RouteNames.agentsList,
                                ),
                                child: const Text('Annuler'),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submit,
                                icon: Icon(
                                  widget.isEdit
                                      ? Icons.save_rounded
                                      : Icons.person_add_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  widget.isEdit
                                      ? 'Enregistrer'
                                      : 'Créer l\'agent',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sous-widgets du formulaire ────────────────────────────────

class _FormHeader extends StatelessWidget {
  final bool isEdit;
  const _FormHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:    const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color:        AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
            color: AppColors.primary,
            size:  22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Modifier l\'agent' : 'Nouvel agent',
              style: const TextStyle(
                fontSize:   22,
                fontWeight: FontWeight.w800,
                color:      AppColors.primary,
              ),
            ),
            Text(
              isEdit
                  ? 'Modifiez les informations de cet agent'
                  : 'Créez un nouveau compte vendeur',
              style: TextStyle(
                fontSize: 13,
                color:    Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Divider(color: Colors.grey.shade200),
        ),
      ],
    );
  }
}

class _SuccursaleDropdown extends ConsumerWidget {
  final String?           value;
  final ValueChanged<String?> onChanged;

  const _SuccursaleDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succursalesAsync = ref.watch(succursalesStreamProvider);

    return succursalesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error:   (e, _) => const Text('Erreur chargement succursales'),
      data:    (succursales) {
        return DropdownButtonFormField<String>(
          initialValue:       value,
          onChanged:   onChanged,
          decoration:  const InputDecoration(
            labelText:  'Succursale',
            prefixIcon: Icon(Icons.store_mall_directory_rounded),
          ),
          hint: const Text('Sélectionner une succursale'),
          items: succursales
              .where((s) => s.isActif)
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.nom),
                ),
              )
              .toList(),
          validator: (v) =>
              v == null ? 'Veuillez sélectionner une succursale.' : null,
        );
      },
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final AgentStatus                 value;
  final ValueChanged<AgentStatus?>  onChanged;

  const _StatusDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AgentStatus>(
      initialValue:      value,
      onChanged:  onChanged,
      decoration: const InputDecoration(
        labelText:  'Statut',
        prefixIcon: Icon(Icons.toggle_on_rounded),
      ),
      items: AgentStatus.values.map((s) {
        final label = switch (s) {
          AgentStatus.actif   => 'Actif',
          AgentStatus.inactif => 'Inactif',
          AgentStatus.bloque  => 'Bloqué',
        };
        return DropdownMenuItem(value: s, child: Text(label));
      }).toList(),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color:        AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppColors.danger.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color:    AppColors.danger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}