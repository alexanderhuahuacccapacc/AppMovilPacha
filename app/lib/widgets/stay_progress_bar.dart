import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class StayProgressBar extends StatelessWidget {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double height;

  const StayProgressBar({
    super.key,
    this.checkIn,
    this.checkOut,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (checkIn == null || checkOut == null) {
      return _emptyState();
    }

    final now = DateTime.now();
    final total = checkOut!.difference(checkIn!).inDays;
    final elapsed = now.difference(checkIn!).inDays;
    final remaining = total - elapsed;

    if (total <= 0) return _emptyState();

    final progress = (elapsed / total).clamp(0.0, 1.0);
    final currentDay = (elapsed + 1).clamp(1, total);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Tiempo de estancia',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted, fontSize: 11),
              ),
              const Spacer(),
              Text(
                'Día $currentDay de $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.creamSoft,
              color: remaining <= 0
                  ? AppColors.danger
                  : remaining <= 1
                      ? AppColors.amber
                      : AppColors.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            remaining <= 0
                ? 'La estancia ha finalizado'
                : remaining == 1
                    ? 'Queda $remaining noche'
                    : 'Quedan $remaining noches',
            style: TextStyle(
              fontSize: 10,
              color: remaining <= 0 ? AppColors.danger : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.creamSoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
          SizedBox(width: 10),
          Text(
            'Selecciona una reserva para ver tu estancia',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
