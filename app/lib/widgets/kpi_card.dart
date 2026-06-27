import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Dashboard KPI tile: icon chip, big value and a label.
class KpiCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String value;
  final String label;
  final int? badgeCount;

  const KpiCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.value,
    required this.label,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12), // ← reducido de 16 a 12
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ← no ocupa más de lo necesario
          children: [
            Row(
              children: [
                Container(
                  height: 36, // ← reducido de 44 a 36
                  width: 36,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const Spacer(),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10), // ← reducido de 14 a 10
            FittedBox( // ← se encoge si el valor es muy largo
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24, // ← reducido de 26 a 24
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12, // ← reducido de 13 a 12
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // ← por si el label es largo
            ),
          ],
        ),
      ),
    );
  }
}