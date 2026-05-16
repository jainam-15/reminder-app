import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/reminder_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_chip.dart';

class ReminderDetailScreen extends StatefulWidget {
  final String reminderMessage;
  final String? reminderId;

  const ReminderDetailScreen({super.key, required this.reminderMessage, this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  String? _resolvedId;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _anim, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
    _resolvedId = widget.reminderId;
    _resolveReminder();
  }

  Future<void> _resolveReminder() async {
    if (_resolvedId == null) {
      final found = await ReminderStorage.findByMessage(widget.reminderMessage);
      if (found != null && mounted) {
        setState(() { _resolvedId = found.id; _isActive = found.isActive; });
      }
    }
    if (_resolvedId != null) {
      final list = await ReminderStorage.getReminders();
      for (final r in list) {
        if (r.id == _resolvedId) { 
          if (mounted) setState(() => _isActive = r.isActive); 
          break; 
        }
      }
    }
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  Future<void> _deleteReminder() async {
    final tt = Theme.of(context).textTheme;
    
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6 * curved.value, sigmaY: 6 * curved.value),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(curved),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                contentPadding: EdgeInsets.zero,
                content: GlassCard(
                  padding: const EdgeInsets.all(32),
                  borderRadius: 32,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.destructive, size: 36),
                      ),
                      const SizedBox(height: 28),
                      Text('Delete reminder?', style: tt.titleLarge?.copyWith(fontSize: 24)),
                      const SizedBox(height: 14),
                      Text(
                        'This action cannot be undone. This reminder will be permanently removed.',
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.destructive,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true && _resolvedId != null) {
      HapticFeedback.mediumImpact();
      await ReminderStorage.deleteReminder(_resolvedId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.destructive.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_sweep_rounded, color: AppColors.destructive, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    'Reminder removed successfully',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Premium Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 28, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.cardFill,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.cardBorder, width: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text('Reminder Details', style: tt.titleLarge?.copyWith(fontSize: 20)),
                    const Spacer(),
                    StatusChip(isActive: _isActive),
                  ],
                ),
              ),

              // Detailed Content
              Expanded(
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 60),
                      child: Column(
                        children: [
                          // App Branding Element
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepBlue.withValues(alpha: 0.3), 
                                  blurRadius: 35, 
                                  spreadRadius: 3
                                ),
                              ],
                            ),
                            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 44),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'UPCOMING REMINDER', 
                            style: tt.labelSmall?.copyWith(letterSpacing: 2.2, color: AppColors.textSecondary)
                          ),
                          const SizedBox(height: 28),

                          // Core Message Card
                          GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                            borderRadius: 32,
                            border: Border.all(
                              color: AppColors.cyan.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                                  child: const Icon(Icons.format_quote_rounded, color: Colors.white, size: 40),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  widget.reminderMessage, 
                                  textAlign: TextAlign.center, 
                                  style: tt.headlineMedium?.copyWith(
                                    fontSize: 24, 
                                    height: 1.45,
                                    letterSpacing: -0.3,
                                    color: AppColors.textPrimary,
                                  )
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  width: 54, 
                                  height: 3, 
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2), 
                                    gradient: AppColors.primaryGradient
                                  )
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center, 
                                  children: [
                                    const Icon(Icons.verified_rounded, color: AppColors.cyan, size: 18),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Verified notification', 
                                      style: tt.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 13)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 56),

                          // Interaction Controls
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              borderRadius: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [
                                  const Icon(Icons.arrow_back_rounded, size: 22, color: AppColors.textSecondary),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Back to Home', 
                                    style: tt.labelLarge?.copyWith(color: AppColors.textSecondary, fontSize: 15)
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (_resolvedId != null)
                            TextButton(
                              onPressed: _deleteReminder,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.destructive,
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [
                                  const Icon(Icons.delete_outline_rounded, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete Reminder', 
                                    style: tt.labelLarge?.copyWith(
                                      color: AppColors.destructive,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    )
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
