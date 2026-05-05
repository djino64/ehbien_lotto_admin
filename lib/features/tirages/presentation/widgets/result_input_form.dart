// lib/features/tirages/presentation/widgets/result_input_form.dart

import 'package:ehbien_lotto_admin/features/tirages/domain/entities/tirage_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ResultInputForm extends StatefulWidget {
  final TirageType type;
  final List<String> initialBoules;
  final ValueChanged<List<String>> onChanged;

  const ResultInputForm({
    super.key,
    required this.type,
    required this.initialBoules,
    required this.onChanged,
  });

  @override
  State<ResultInputForm> createState() => _ResultInputFormState();
}

class _ResultInputFormState extends State<ResultInputForm> {
  late List<TextEditingController> _controllers;

  int get _count => switch (widget.type) {
    TirageType.borlette => 3,
    TirageType.mariage  => 2,
    TirageType.lotto3   => 3,
    TirageType.sel      => 1,
  };

  List<String> get _labels => switch (widget.type) {
    TirageType.borlette => ['1ère boule', '2ème boule', '3ème boule'],
    TirageType.mariage  => ['1ère boule', '2ème boule'],
    TirageType.lotto3   => ['Boule 1', 'Boule 2', 'Boule 3'],
    TirageType.sel      => ['Boule unique'],
  };

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_count, (i) {
      final ctrl = TextEditingController(
        text: i < widget.initialBoules.length
            ? widget.initialBoules[i]
            : '',
      );
      ctrl.addListener(_notify);
      return ctrl;
    });
  }

  void _notify() {
    final boules = _controllers
        .map((c) => c.text.trim())
        .where((b) => b.isNotEmpty)
        .toList();
    widget.onChanged(boules);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_notify);
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéros gagnants — ${_typeLabel(widget.type)}',
          style: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: List.generate(_count, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < _count - 1 ? AppSpacing.md : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color:    Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller:   _controllers[i],
                      keyboardType: TextInputType.number,
                      textAlign:    TextAlign.center,
                      maxLength:    2,
                      style: const TextStyle(
                        fontSize:   28,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.primary,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled:      true,
                        fillColor:   AppColors.primary.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requis';
                        }
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 0 || n > 99) {
                          return '00-99';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _typeLabel(TirageType t) => switch (t) {
    TirageType.borlette => 'Borlette',
    TirageType.mariage  => 'Mariage',
    TirageType.lotto3   => 'Lotto 3',
    TirageType.sel      => 'Sèl',
  };
}