import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import '../theme/app_colors.dart';

class ReminderTile extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  const ReminderTile({super.key, required this.reminder, required this.onTap});

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final r = widget.reminder;
    final accentColor = r.isActive ? AppColors.deepBlue : AppColors.textTertiary;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (d) => _ctrl.forward(),
        onTapUp: (d) {
          _ctrl.reverse();
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.cardFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: r.isActive 
                ? AppColors.deepBlue.withValues(alpha: 0.12) 
                : AppColors.cardBorder,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Branded Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  r.isActive ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  color: r.isActive ? AppColors.cyan : AppColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontSize: 16, 
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${r.formattedTime}  ·  ${r.timeAgo}',
                      style: tt.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status & Navigation
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (r.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded, 
                    color: AppColors.textTertiary.withValues(alpha: 0.65), 
                    size: 24
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
