import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';
import '../providers/schedule_notifier.dart';
import 'schedule_creation_page.dart';

class ScheduleManagementPage extends ConsumerWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleNotifierProvider);

    if (state.isLoading && state.schedules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.schedules.isEmpty) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.schedules.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming schedules.\nGo to "New" to create one.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'App Scheduler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to App Discovery Tab
                  DefaultTabController.of(context).animateTo(1);
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'New',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: state.schedules.isEmpty
              ? const Center(
                  child: Text(
                    'No upcoming schedules.\nGo to "New" to create one.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.schedules.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 32, thickness: 1),
                  itemBuilder: (context, index) {
                    final schedule = state.schedules[index];
                    return _ScheduleItem(schedule: schedule);
                  },
                ),
        ),
      ],
    );
  }
}

class _ScheduleItem extends ConsumerWidget {
  final Schedule schedule;

  const _ScheduleItem({required this.schedule});

  String _getNextExecutionText() {
    final now = DateTime.now();
    var next = schedule.scheduledTime;

    if (schedule.frequency == ScheduleFrequency.daily) {
      if (next.isBefore(now)) {
        next = DateTime(
          now.year,
          now.month,
          now.day,
          schedule.scheduledTime.hour,
          schedule.scheduledTime.minute,
        );
        if (next.isBefore(now)) {
          next = next.add(const Duration(days: 1));
        }
      }
    }

    final diff = next.difference(now);
    if (diff.isNegative) return 'Expired';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    String diffText = '';
    if (days > 0) diffText += '${days}d ';
    if (hours > 0) diffText += '${hours}h ';
    if (minutes > 0 || (days == 0 && hours == 0)) diffText += '${minutes}m';

    final isToday =
        next.year == now.year && next.month == now.month && next.day == now.day;
    final isTomorrow =
        next.year == now.year &&
        next.month == now.month &&
        next.day == now.day + 1;

    String dayLabel = DateFormat('MMM dd').format(next);
    if (isToday) dayLabel = 'Today';
    if (isTomorrow) dayLabel = 'Tomorrow';

    final timeLabel = DateFormat('hh:mm a').format(next);

    return 'Next: $dayLabel, $timeLabel ($diffText)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.android, size: 24, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Text(
              schedule.appName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          schedule.frequency == ScheduleFrequency.daily
              ? 'Everyday at ${DateFormat('hh:mm a').format(schedule.scheduledTime)}'
              : 'One-time: ${DateFormat('MMM dd, hh:mm a').format(schedule.scheduledTime)}',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.alarm, size: 16, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              _getNextExecutionText(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionButton(
              label: 'Edit',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScheduleCreationPage(existingSchedule: schedule),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            _ActionButton(
              label: 'Delete',
              color: Colors.red,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Schedule'),
                    content: const Text(
                      'Are you sure you want to delete this schedule?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  ref
                      .read(scheduleNotifierProvider.notifier)
                      .deleteSchedule(schedule.id);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
