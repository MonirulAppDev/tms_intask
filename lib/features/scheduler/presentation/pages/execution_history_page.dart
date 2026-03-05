import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/history_notifier.dart';

class ExecutionHistoryPage extends ConsumerWidget {
  const ExecutionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyNotifierProvider);

    return Column(
      children: [
        if (state.history.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text(
                        'Are you sure you want to clear all history logs?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    ref.read(historyNotifierProvider.notifier).clearHistory();
                  }
                },
                icon: const Icon(Icons.clear_all, color: Colors.red),
                label: const Text(
                  'Clear History',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        Expanded(child: _buildBody(state)),
      ],
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isLoading && state.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.history.isEmpty) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.history.isEmpty) {
      return const Center(child: Text('No execution history yet.'));
    }

    return ListView.builder(
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final log = state.history[index];
        final timeFormatted = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).format(log.scheduledTime);
        final success =
            log.isEnabled; // isEnabled is reused as success boolean in history

        return ListTile(
          leading: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 32,
          ),
          title: Text(
            log.appName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Executed at: $timeFormatted'),
          trailing: log.label != null && log.label!.isNotEmpty
              ? Chip(label: Text(log.label!))
              : null,
        );
      },
    );
  }
}
