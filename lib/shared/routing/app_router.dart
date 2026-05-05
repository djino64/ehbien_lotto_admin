import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ehbien_lotto_admin/core/providers/firebase_providers.dart';
import 'package:ehbien_lotto_admin/shared/routing/route_names.dart';
import 'package:ehbien_lotto_admin/shared/routing/router_guards.dart';
import 'package:ehbien_lotto_admin/shared/layout/admin_scaffold.dart';
import 'package:ehbien_lotto_admin/features/auth/presentation/pages/login_page.dart';
import 'package:ehbien_lotto_admin/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/pages/agents_list_page.dart';
import 'package:ehbien_lotto_admin/features/agents/presentation/pages/agent_form_page.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/pages/succursales_list_page.dart';
import 'package:ehbien_lotto_admin/features/succursales/presentation/pages/succursale_form_page.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/pages/tirages_list_page.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/pages/tirage_form_page.dart';
import 'package:ehbien_lotto_admin/features/tirages/presentation/pages/publish_result_page.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/pages/tickets_list_page.dart';
import 'package:ehbien_lotto_admin/features/tickets/presentation/pages/ticket_detail_page.dart';
import 'package:ehbien_lotto_admin/features/ventes/presentation/pages/ventes_page.dart';
import 'package:ehbien_lotto_admin/features/blocages/presentation/pages/blocages_page.dart';
import 'package:ehbien_lotto_admin/features/limits/presentation/pages/limits_page.dart';
import 'package:ehbien_lotto_admin/features/primes/presentation/pages/primes_page.dart';
import 'package:ehbien_lotto_admin/features/rapports/presentation/pages/rapports_page.dart';
import 'package:ehbien_lotto_admin/features/notifications/presentation/pages/notifications_page.dart';
import 'package:ehbien_lotto_admin/features/settings/presentation/pages/settings_page.dart';
import 'package:ehbien_lotto_admin/features/audit_logs/presentation/pages/audit_logs_page.dart';
import 'package:ehbien_lotto_admin/features/users/presentation/pages/users_list_page.dart';
import 'package:ehbien_lotto_admin/features/users/presentation/pages/user_detail_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = GoRouterRefreshStream(
    ref.watch(firebaseAuthProvider).authStateChanges(),
  );
  return GoRouter(
    initialLocation: RouteNames.dashboard,
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final isLoggedIn = user != null;
      final isLogin = state.matchedLocation == RouteNames.login;
      if (!isLoggedIn && !isLogin) return RouteNames.login;
      if (isLoggedIn && isLogin)   return RouteNames.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(path: RouteNames.dashboard,      builder: (_, __) => const DashboardPage()),
          GoRoute(path: RouteNames.usersList,      builder: (_, __) => const UsersListPage(),
            routes: [GoRoute(path: ':id', builder: (_, s) => UserDetailPage(userId: s.pathParameters['id']!))]),
          GoRoute(path: RouteNames.agentsList,     builder: (_, __) => const AgentsListPage(),
            routes: [
              GoRoute(path: 'form',     builder: (_, __) => const AgentFormPage()),
              GoRoute(path: ':id/edit', builder: (_, s)  => AgentFormPage(agentId: s.pathParameters['id'])),
            ]),
          GoRoute(path: RouteNames.succursalesList, builder: (_, __) => const SuccursalesListPage(),
            routes: [
              GoRoute(path: 'form',     builder: (_, __) => const SuccursaleFormPage()),
              GoRoute(path: ':id/edit', builder: (_, s)  => SuccursaleFormPage(succursaleId: s.pathParameters['id'])),
            ]),
          GoRoute(path: RouteNames.tiragesList,    builder: (_, __) => const TiragesListPage(),
            routes: [
              GoRoute(path: 'form',       builder: (_, __) => const TirageFormPage()),
              GoRoute(path: ':id/edit',   builder: (_, s)  => TirageFormPage(tirageId: s.pathParameters['id'])),
              GoRoute(path: ':id/publish',builder: (_, s)  => PublishResultPage(tirageId: s.pathParameters['id']!)),
            ]),
          GoRoute(path: RouteNames.ticketsList,    builder: (_, __) => const TicketsListPage(),
            routes: [GoRoute(path: ':id', builder: (_, s) => TicketDetailPage(ticketId: s.pathParameters['id']!))]),
          GoRoute(path: RouteNames.ventes,        builder: (_, __) => const VentesPage()),
          GoRoute(path: RouteNames.blocages,      builder: (_, __) => const BlocagesPage()),
          GoRoute(path: RouteNames.limits,        builder: (_, __) => const LimitsPage()),
          GoRoute(path: RouteNames.primes,        builder: (_, __) => const PrimesPage()),
          GoRoute(path: RouteNames.rapports,      builder: (_, __) => const RapportsPage()),
          GoRoute(path: RouteNames.notifications, builder: (_, __) => const NotificationsPage()),
          GoRoute(path: RouteNames.settings,      builder: (_, __) => const SettingsPage()),
          GoRoute(path: RouteNames.auditLogs,     builder: (_, __) => const AuditLogsPage()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable : ${state.error}')),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() { _sub.cancel(); super.dispose(); }
}
