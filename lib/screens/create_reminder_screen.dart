import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/reminder_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/section_header.dart';

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _showSuccess = false;
  List<Reminder> _reminders = [];

  late final AnimationController _entryAnim;
  late final Animation<double> _headerOp, _cardOp, _listOp;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _checkPendingPayload();

    _entryAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _headerOp = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entryAnim, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _cardOp = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entryAnim, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));
    _cardSlide = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _entryAnim, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)));
    _listOp = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entryAnim, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _entryAnim.forward();
  }

  @override
  void dispose() { 
    _controller.dispose(); 
    _focusNode.dispose(); 
    _entryAnim.dispose(); 
    super.dispose(); 
  }

  void _checkPendingPayload() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payload = NotificationService.instance.pendingPayload;
      if (payload != null && payload.isNotEmpty) {
        NotificationService.instance.clearPendingPayload();
        Navigator.of(context).pushNamed('/reminder-details', arguments: payload);
      }
    });
  }

  Future<void> _loadReminders() async {
    final list = await ReminderStorage.getReminders();
    if (mounted) setState(() => _reminders = list);
  }

  Future<void> _setReminder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    _focusNode.unfocus();

    final message = _controller.text.trim();
    final now = DateTime.now();
    final reminder = Reminder(
      id: now.millisecondsSinceEpoch.toString(),
      message: message,
      createdAt: now,
      scheduledFor: now.add(const Duration(seconds: 30)),
    );
    await ReminderStorage.saveReminder(reminder);

    final ns = NotificationService.instance;
    await ns.showImmediateNotification(id: 0, title: 'Reminder Set', body: 'Your reminder has been set successfully.');
    await ns.scheduleNotification(id: 1, title: 'Reminder', body: 'You have a reminder. Click to view it.', delay: const Duration(seconds: 30), payload: message);

    _controller.clear();
    await _loadReminders();
    setState(() { _isSubmitting = false; _showSuccess = true; });
    Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _showSuccess = false); });
  }

  void _openDetails(Reminder r) {
    Navigator.of(context).pushNamed(
      '/reminder-details', 
      arguments: {'message': r.message, 'id': r.id}
    ).then((_) => _loadReminders());
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPadding + 28)),

              // Header Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerOp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceLight,
                                border: Border.all(color: AppColors.cardBorder, width: 1.5),
                              ),
                              child: ClipOval(
                                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text('REMINDER APP', style: tt.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('Create\nReminder', style: tt.headlineLarge),
                        const SizedBox(height: 12),
                        Text('We\'ll make sure you don\'t forget.', style: tt.bodyLarge),
                      ],
                    ),
                  ),
                ),
              ),

              // Interaction Card
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _cardSlide,
                  child: FadeTransition(
                    opacity: _cardOp,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                      child: GlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('WHAT\'S ON YOUR MIND?', style: tt.labelSmall),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _controller,
                                focusNode: _focusNode,
                                maxLines: 2,
                                maxLength: 200,
                                style: tt.bodyLarge?.copyWith(
                                  color: AppColors.textPrimary, 
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                                keyboardAppearance: Brightness.dark,
                                decoration: InputDecoration(
                                  hintText: 'e.g., Call mom at 5 PM…',
                                  hintStyle: tt.bodyLarge?.copyWith(color: AppColors.textMuted.withValues(alpha: 0.8)),
                                  counterStyle: tt.bodySmall?.copyWith(color: AppColors.textMuted),
                                  filled: true,
                                  fillColor: AppColors.background.withValues(alpha: 0.4),
                                  contentPadding: const EdgeInsets.all(20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide(color: AppColors.cardBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide(color: AppColors.cardBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: BorderSide(color: AppColors.cyan.withValues(alpha: 0.4), width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: const BorderSide(color: AppColors.destructive, width: 1.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18), 
                                    borderSide: const BorderSide(color: AppColors.destructive, width: 1.5),
                                  ),
                                  errorStyle: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13, height: 1.2),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Message is required' : null,
                              ),
                              const SizedBox(height: 18),
                              GradientButton(
                                text: 'Set Reminder', 
                                icon: Icons.alarm_add_rounded, 
                                isLoading: _isSubmitting, 
                                onPressed: _isSubmitting ? null : _setReminder
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Feedback State
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim, 
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, -0.05), end: Offset.zero).animate(anim),
                      child: child,
                    )
                  ),
                  child: _showSuccess
                      ? Padding(
                          key: const ValueKey('success'),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.success.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Reminder scheduled successfully', 
                                    style: tt.bodyMedium?.copyWith(
                                      color: AppColors.success, 
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),

              // Recent Reminders Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _listOp,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 56, 32, 20),
                    child: SectionHeader(
                      title: 'Recent Reminders', 
                      trailing: _reminders.isNotEmpty ? '${_reminders.length}' : null
                    ),
                  ),
                ),
              ),

              // List View
              _reminders.isEmpty
                  ? SliverToBoxAdapter(child: FadeTransition(opacity: _listOp, child: _emptyState(tt)))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList.separated(
                        itemCount: _reminders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final r = _reminders[index];
                          return FadeTransition(
                            opacity: _listOp, 
                            child: ReminderTile(reminder: r, onTap: () => _openDetails(r))
                          );
                        },
                      ),
                    ),
              
              SliverToBoxAdapter(child: SizedBox(height: bottomPadding + 60)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(TextTheme tt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.inbox_rounded, color: AppColors.textTertiary, size: 36),
          ),
          const SizedBox(height: 24),
          Text(
            'No reminders yet', 
            style: tt.titleMedium?.copyWith(color: AppColors.textSecondary)
          ),
          const SizedBox(height: 10),
          Text(
            'Your upcoming notifications will appear here once scheduled.', 
            style: tt.bodySmall?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
