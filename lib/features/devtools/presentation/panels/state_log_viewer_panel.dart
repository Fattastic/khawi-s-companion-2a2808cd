/// State & Log Viewer Panel - Network calls and provider states.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/debug/logging/trace_logger.dart';

/// State and log viewer panel.
class StateLogViewerPanel extends ConsumerStatefulWidget {
  const StateLogViewerPanel({super.key});

  @override
  ConsumerState<StateLogViewerPanel> createState() =>
      _StateLogViewerPanelState();
}

class _StateLogViewerPanelState extends ConsumerState<StateLogViewerPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Network Calls'),
            Tab(text: 'Errors'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNetworkTab(),
              _buildErrorsTab(),
            ],
          ),
        ),
        _buildActions(),
      ],
    );
  }

  Widget _buildNetworkTab() {
    final entries = traceLogger.recentEntries;

    if (entries.isEmpty) {
      return const Center(child: Text('No network calls logged'));
    }

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[entries.length - 1 - index]; // Reverse order
        return _buildEntryTile(entry);
      },
    );
  }

  Widget _buildErrorsTab() {
    final errors = traceLogger.recentErrors;

    if (errors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 8),
            Text('No recent errors'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final entry = errors[errors.length - 1 - index];
        return _buildEntryTile(entry, isError: true);
      },
    );
  }

  Widget _buildEntryTile(TraceEntry entry, {bool isError = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isError ? Colors.red.shade50 : null,
      child: ExpansionTile(
        dense: true,
        leading: Icon(
          entry.isSuccess ? Icons.check_circle : Icons.error,
          color: entry.isSuccess ? Colors.green : Colors.red,
          size: 20,
        ),
        title: Text(
          entry.functionName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            _chip(
              '${entry.statusCode}',
              entry.isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            _chip('${entry.durationMs}ms', Colors.blue),
            const SizedBox(width: 4),
            Text(
              _formatTime(entry.timestamp),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Trace ID', entry.traceId),
                if (entry.payloadSummary != null)
                  _detailRow('Payload', entry.payloadSummary!),
                if (entry.errorMessage != null)
                  _detailRow('Error', entry.errorMessage!, isError: true),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(entry.traceId),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Trace ID'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isError ? Colors.red : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isError ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: () {
              traceLogger.clear();
              setState(() {});
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
          ),
          ElevatedButton.icon(
            onPressed: _exportDiagnostics,
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _exportDiagnostics() {
    final json = const JsonEncoder.withIndent('  ')
        .convert(traceLogger.exportDiagnostics());
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied to clipboard')),
    );
  }
}
