import 'package:flutter/widgets.dart';

import 'qa_nav_debug.dart';

class QaNavObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    QaNavDebug.updateNavEvent(_fmt('PUSH', route, previousRoute));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    QaNavDebug.updateNavEvent(_fmt('POP', route, previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    QaNavDebug.updateNavEvent(_fmt('REPLACE', newRoute, oldRoute));
  }

  String _fmt(String op, Route<dynamic>? a, Route<dynamic>? b) {
    final aName = a?.settings.name ?? a.runtimeType.toString();
    final bName = b?.settings.name ?? b.runtimeType.toString();
    return '$op: $bName -> $aName';
  }
}
