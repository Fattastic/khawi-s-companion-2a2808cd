import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Handles deep links that arrive while the app is already running (warm start).
///
/// GoRouter already handles **cold-start** links automatically by reading the
/// initial URI from the platform. This service covers the complementary
/// **warm-start** case where the app is foregrounded by tapping a link.
///
/// Usage: call [init] once after the [GoRouter] is available, typically in
/// [State.initState] of the root widget. Call [dispose] in [State.dispose].
///
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   final router = ref.read(routerProvider);
///   _deepLinkService = DeepLinkService()..init(router);
/// }
///
/// @override
/// void dispose() {
///   _deepLinkService.dispose();
///   super.dispose();
/// }
/// ```
class DeepLinkService {
  DeepLinkService();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  static const Set<String> _allowedUniversalHosts = {
    'khawi.app',
    'www.khawi.app',
  };

  /// Starts listening for incoming URI links.
  ///
  /// [router] is used to navigate to the resolved path when a link arrives.
  void init(GoRouter router) {
    _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, router),
      onError: (Object err) {
        if (kDebugMode) {
          debugPrint('[DeepLink] stream error: $err');
        }
      },
    );
    if (kDebugMode) {
      debugPrint('[DeepLink] listening for warm-start links');
    }
  }

  /// Stops listening and releases resources.
  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  // ─── private ───────────────────────────────────────────────────────────────

  void _handleUri(Uri uri, GoRouter router) {
    if (kDebugMode) {
      debugPrint('[DeepLink] received: ${_summarizeUri(uri)}');
    }

    // Handle our custom scheme: khawi://invite/CODE, khawi://trip/ID etc.
    // The Supabase custom scheme (io.supabase.khawi) is handled by Supabase
    // Flutter's built-in auth listener — ignore it here.
    if (uri.scheme == 'io.supabase.khawi') return;

    // For the custom `khawi://` scheme the path starts after the host.
    // e.g. khawi://invite/KHAWI50 → host=invite, pathSegments=[KHAWI50]
    // We reconstruct the GoRouter path from host + path.
    String target;
    if (uri.scheme == 'khawi') {
      final segments =
          [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty).join('/');
      final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
      if (segments.isEmpty) {
        if (kDebugMode) {
          debugPrint('[DeepLink] ignoring empty khawi:// target');
        }
        return;
      }
      target = '/$segments$query';
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      // Future: HTTPS universal links when a domain is available.
      if (!_allowedUniversalHosts.contains(uri.host.toLowerCase())) {
        if (kDebugMode) {
          debugPrint('[DeepLink] ignoring external host: ${uri.host}');
        }
        return;
      }
      final path = uri.path.isEmpty ? '/' : uri.path;
      final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
      target = '$path$query';
    } else {
      if (kDebugMode) {
        debugPrint('[DeepLink] ignoring unknown scheme: ${uri.scheme}');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[DeepLink] navigating to ${_redactQuery(target)}');
    }
    try {
      router.go(target);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DeepLink] navigation error: $e');
      }
    }
  }

  String _summarizeUri(Uri uri) {
    final path = _redactPath(uri.path.isEmpty ? '/' : uri.path);
    final hasQuery = uri.hasQuery ? '?…' : '';
    final host = uri.host.isEmpty ? '' : uri.host;
    return '${uri.scheme}://$host$path$hasQuery';
  }

  String _redactQuery(String target) {
    final qIndex = target.indexOf('?');
    final pathOnly = qIndex == -1 ? target : target.substring(0, qIndex);
    final redactedPath = _redactPath(pathOnly);
    if (qIndex == -1) return redactedPath;
    return '$redactedPath?…';
  }

  String _redactPath(String path) {
    final parts =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (parts.isEmpty) return '/';
    if (parts.length == 1) return '/${parts.first}';
    return '/${parts.first}/${List.filled(parts.length - 1, ':arg').join('/')}';
  }
}
