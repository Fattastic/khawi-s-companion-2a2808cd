import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:khawi_flutter/core/env/env.dart';
import 'package:khawi_flutter/core/backend/backend_diagnostics.dart';
import 'package:khawi_flutter/state/providers.dart';

class BackendHealthPanel extends ConsumerStatefulWidget {
  const BackendHealthPanel({super.key});

  @override
  ConsumerState<BackendHealthPanel> createState() => _BackendHealthPanelState();
}

class _BackendHealthPanelState extends ConsumerState<BackendHealthPanel> {
  bool _busy = false;
  final List<String> _log = <String>[];

  void _add(String line) {
    if (!mounted) return;
    setState(
      () => _log.insert(0, '[${DateTime.now().toIso8601String()}] $line'),
    );
  }

  Map<String, String> _anonHeaders() {
    return {
      'apikey': Env.supabaseAnonKey,
      'Authorization': 'Bearer ${Env.supabaseAnonKey}',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    _add('▶ $label');
    try {
      await action();
      _add('✅ $label');
    } catch (e) {
      _add('❌ $label: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Uri _authUrl(String path) {
    final base = Uri.parse(Env.supabaseUrl);
    return base.replace(path: '/auth/v1/$path');
  }

  Uri _restUrl(String path, [Map<String, String>? query]) {
    final base = Uri.parse(Env.supabaseUrl);
    return base.replace(path: '/rest/v1/$path', queryParameters: query);
  }

  Future<void> _checkHealth() async {
    final res = await http.get(_authUrl('health'));
    _add('GET /auth/v1/health -> ${res.statusCode}');
    if (res.body.isNotEmpty) {
      _add(
        'body: ${res.body.length > 500 ? res.body.substring(0, 500) : res.body}',
      );
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'Health check failed (${res.statusCode})';
    }
  }

  Future<void> _fetchAuthSettings() async {
    final res = await http.get(_authUrl('settings'), headers: _anonHeaders());
    _add('GET /auth/v1/settings -> ${res.statusCode}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'settings failed (${res.statusCode}): ${res.body}';
    }

    final decoded = jsonDecode(res.body);
    final external = (decoded is Map) ? decoded['external'] : null;
    _add('external providers: ${jsonEncode(external)}');
  }

  Future<void> _signInAnonymously() async {
    final auth = ref.read(authRepoProvider);
    final user = await auth.signInAnonymously();
    _add('anon user id: ${user?.id}');
  }

  Future<void> _emailSignupAndLogin() async {
    final auth = ref.read(authRepoProvider);
    final rand = DateTime.now().millisecondsSinceEpoch % 1000000;
    final email = 'test+$rand@khawi.local';
    const password = 'Passw0rd!123';
    final user = await auth.signUp(email, password);
    _add('signup/login user=${user?.id} email=$email');
  }

  Future<void> _dbProfilesSelect() async {
    final res = await http.get(
      _restUrl('profiles', {'select': 'id', 'limit': '1'}),
      headers: _anonHeaders(),
    );
    _add('GET /rest/v1/profiles?select=id&limit=1 -> ${res.statusCode}');
    _add('body: ${res.body}');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'profiles select failed (${res.statusCode})';
    }
  }

  Future<void> _signOut() async {
    final auth = ref.read(authRepoProvider);
    await auth.signOut();
    _add('signed out');
  }

  // ─────────────────────────────────────────────────────────────────────
  // EDGE FUNCTION HEALTH CHECKS
  // ─────────────────────────────────────────────────────────────────────

  Future<void> _pingVerifyIdentity() async {
    final diagnostics = ref.read(backendDiagnosticsProvider);
    final result = await diagnostics.pingVerifyIdentity();
    if (result.success) {
      _add('✅ Identity/Auth OK (${result.latency?.inMilliseconds ?? 0}ms)');
    } else {
      throw 'Status ${result.statusCode}: ${result.error}';
    }
  }

  Future<void> _pingSmartMatch() async {
    final diagnostics = ref.read(backendDiagnosticsProvider);
    final result = await diagnostics.pingSmartMatch();
    if (result.success) {
      _add('✅ SmartMatch OK (${result.latency?.inMilliseconds ?? 0}ms)');
    } else {
      throw 'Status ${result.statusCode}: ${result.error}';
    }
  }

  Future<void> _pingXpCalculate() async {
    final diagnostics = ref.read(backendDiagnosticsProvider);
    final result = await diagnostics.pingXpCalculate();
    if (result.success) {
      _add('✅ XP Calculate OK (${result.latency?.inMilliseconds ?? 0}ms)');
    } else {
      throw 'Status ${result.statusCode}: ${result.error}';
    }
  }

  Future<void> _runAllEdgeFunctionChecks() async {
    final diagnostics = ref.read(backendDiagnosticsProvider);
    final results = await diagnostics.runAllChecks();
    for (final entry in results.entries) {
      final value = entry.value;
      if (value is PingResult) {
        if (value.success) {
          _add('✅ ${entry.key} OK (${value.latency?.inMilliseconds ?? 0}ms)');
        } else {
          _add('❌ ${entry.key} FAILED: ${value.error}');
        }
      } else if (value is List<String>) {
        if (value.isEmpty) {
          _add('✅ ${entry.key} OK');
        } else {
          for (final e in value) {
            _add('❌ ${entry.key}: $e');
          }
        }
      } else {
        _add('❓ ${entry.key}: Unknown result type');
      }
    }

    final passed = results.entries.where((e) {
      final v = e.value;
      if (v is PingResult) return v.success;
      if (v is List<String>) return v.isEmpty;
      return false;
    }).length;
    final total = results.length;
    if (passed == total) {
      _add('🎉 All $total checks passed!');
    } else {
      throw '$passed/$total checks passed';
    }
  }

  @override
  Widget build(BuildContext context) {
    const url = Env.supabaseUrl;
    final anonKeyMasked = Env.supabaseAnonKey.isEmpty
        ? '(empty)'
        : '${Env.supabaseAnonKey.substring(0, 16)}…${Env.supabaseAnonKey.substring(Env.supabaseAnonKey.length - 6)}';

    const spacing = 8.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Supabase URL: $url'),
          const SizedBox(height: 6),
          Text('Anon key: $anonKeyMasked'),
          const SizedBox(height: 6),
          const Text(
            'Build: ${kReleaseMode ? 'release' : 'debug/profile'}',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              FilledButton.tonal(
                onPressed:
                    _busy ? null : () => _run('Auth health', _checkHealth),
                child: const Text('Auth Health'),
              ),
              FilledButton.tonal(
                onPressed: _busy
                    ? null
                    : () => _run('Auth settings', _fetchAuthSettings),
                child: const Text('Auth Settings'),
              ),
              FilledButton.tonal(
                onPressed: _busy
                    ? null
                    : () => _run('Anon sign-in', _signInAnonymously),
                child: const Text('Anon Sign-In'),
              ),
              FilledButton.tonal(
                onPressed: _busy
                    ? null
                    : () => _run('Email signup+login', _emailSignupAndLogin),
                child: const Text('Email Signup+Login'),
              ),
              FilledButton.tonal(
                onPressed: _busy
                    ? null
                    : () => _run('DB: profiles select', _dbProfilesSelect),
                child: const Text('DB Select'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _run('Sign out', _signOut),
                child: const Text('Sign out'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Edge Function Health Checks',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run(
                          'All Edge Functions',
                          _runAllEdgeFunctionChecks,
                        ),
                child: const Text('🔍 Run All'),
              ),
              FilledButton.tonal(
                onPressed: _busy
                    ? null
                    : () => _run('Verify Identity', _pingVerifyIdentity),
                child: const Text('Identity'),
              ),
              FilledButton.tonal(
                onPressed:
                    _busy ? null : () => _run('Smart Match', _pingSmartMatch),
                child: const Text('SmartMatch'),
              ),
              FilledButton.tonal(
                onPressed:
                    _busy ? null : () => _run('XP Calculate', _pingXpCalculate),
                child: const Text('XP Calc'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _log.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, i) => Text(
                  _log[i],
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
