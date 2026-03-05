import 'package:app_scheduler/features/scheduler/domain/entities/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_notifier.dart';

class ScheduleCreationPage extends ConsumerStatefulWidget {
  final Application? app;
  final Schedule? existingSchedule;

  const ScheduleCreationPage({super.key, this.app, this.existingSchedule})
    : assert(app != null || existingSchedule != null);

  @override
  ConsumerState<ScheduleCreationPage> createState() =>
      _ScheduleCreationPageState();
}

class _ScheduleCreationPageState extends ConsumerState<ScheduleCreationPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _labelController = TextEditingController();
  ScheduleFrequency _frequency = ScheduleFrequency.once;

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      _selectedDate = widget.existingSchedule!.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(
        widget.existingSchedule!.scheduledTime,
      );
      _labelController.text = widget.existingSchedule!.label ?? '';
      _frequency = widget.existingSchedule!.frequency;
    }
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveSchedule() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date and Time')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now()) &&
        _frequency == ScheduleFrequency.once) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scheduled time must be in the future')),
      );
      return;
    }

    final schedule =
        widget.existingSchedule?.copyWith(
          scheduledTime: scheduledDateTime,
          label: _labelController.text,
          frequency: _frequency,
        ) ??
        Schedule(
          id: const Uuid().v4(),
          appName: widget.app!.appName,
          packageName: widget.app!.packageName,
          scheduledTime: scheduledDateTime,
          label: _labelController.text,
          frequency: _frequency,
        );

    final success = await ref
        .read(scheduleNotifierProvider.notifier)
        .addSchedule(schedule);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingSchedule != null ? 'Updated!' : 'Scheduled!',
          ),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final error = ref.read(scheduleNotifierProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Failed to save')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleNotifierProvider);
    final appName = widget.app?.appName ?? widget.existingSchedule!.appName;
    final packageName =
        widget.app?.packageName ?? widget.existingSchedule!.packageName;
    final isEditing = widget.existingSchedule != null;

    final hasConflict = scheduleState.error?.contains('Conflict') ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Schedule' : 'New Schedule',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Info Row
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.app is ApplicationWithIcon
                            ? Image.memory(
                                (widget.app as ApplicationWithIcon).icon,
                              )
                            : const Icon(Icons.android),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            packageName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Label Section
                  const Text(
                    'Label (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Daily Standup',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Frequency Section
                  const Text(
                    'Frequency',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFrequencyChip('Once', ScheduleFrequency.once),
                      const SizedBox(width: 12),
                      _buildFrequencyChip('Daily', ScheduleFrequency.daily),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Date & Time Section
                  const Text(
                    'Date & Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPickerTrigger(
                        icon: Icons.calendar_today_outlined,
                        label: _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('MMM d, yyyy').format(_selectedDate!),
                        onTap: _pickDate,
                        iconColor: Colors.red[400]!,
                      ),
                      const SizedBox(width: 24),
                      _buildPickerTrigger(
                        icon: Icons.access_time,
                        label: _selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context),
                        onTap: _pickTime,
                        iconColor: Colors.blue[400]!,
                      ),
                    ],
                  ),

                  if (hasConflict) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber[800],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Conflict Warning!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  scheduleState.error!,
                                  style: TextStyle(color: Colors.amber[900]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: scheduleState.isLoading ? null : _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      scheduleState.isLoading ? 'SAVING...' : 'SAVE',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(String label, ScheduleFrequency value) {
    final isSelected = _frequency == value;
    return GestureDetector(
      onTap: () => setState(() => _frequency = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTrigger({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
