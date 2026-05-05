// lib/features/tickets/presentation/widgets/ticket_items_table.dart

import 'package:ehbien_lotto_admin/core/extensions/num_ext.dart';
import 'package:ehbien_lotto_admin/features/tickets/domain/entities/ticket_item_entity.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TicketItemsTable extends StatelessWidget {
  final List<TicketItemEntity> items;

  const TicketItemsTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Aucun item',
          style: TextStyle(color: Colors.grey.shade400),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        // En-tête
        TableRow(
          decoration: BoxDecoration(
            color:        Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          children: ['Type', 'Boules', 'Montant', 'Gain potentiel']
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical:   10,
                  ),
                  child: Text(
                    h,
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                      color:      Colors.grey.shade500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // Lignes
        ...items.map(
          (item) => TableRow(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F0F0)),
              ),
            ),
            children: [
              _Cell(child: _TypeBadge(item.typeJeu)),
              _Cell(
                child: Wrap(
                  spacing: 4,
                  children: item.boules
                      .map(
                        (b) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical:   3,
                          ),
                          decoration: BoxDecoration(
                            color:        AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            b,
                            style: const TextStyle(
                              fontSize:   12,
                              fontWeight: FontWeight.w700,
                              color:      AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              _Cell(
                child: Text(
                  item.montant.toCurrency,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Cell(
                child: Text(
                  item.gainPotentiel.toCurrency,
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final Widget child;
  const _Cell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: child,
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final TypeJeu type;
  const _TypeBadge(this.type);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (type) {
      TypeJeu.borlette => (AppColors.primary, 'Borlette'),
      TypeJeu.mariage  => (AppColors.warning,  'Mariage'),
      TypeJeu.lotto3   => (AppColors.success,  'Lotto 3'),
      TypeJeu.sel      => (AppColors.info,     'Sèl'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}