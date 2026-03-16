import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/absent/presentation/pages/absent_add_page.dart';
import '../../features/absent/presentation/pages/absent_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/check_in_page.dart';
import '../../features/dashboard/presentation/pages/check_out_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/leave/presentation/pages/leave_add_page.dart';
import '../../features/leave/presentation/pages/leave_page.dart';
import '../../features/main/presentation/pages/main_shell_page.dart';
import '../../features/master/presentation/models/master_action_data.dart';
import '../../features/master/presentation/models/master_company_data.dart';
import '../../features/master/presentation/models/master_employee_data.dart';
import '../../features/master/presentation/models/master_form_data.dart';
import '../../features/master/presentation/models/master_plant_data.dart';
import '../../features/master/presentation/models/master_position_data.dart';
import '../../features/master/presentation/models/master_user_data.dart';
import '../../features/master/presentation/pages/master_action_detail_page.dart';
import '../../features/master/presentation/pages/master_action_form_page.dart';
import '../../features/master/presentation/pages/master_action_page.dart';
import '../../features/master/presentation/pages/master_company_detail_page.dart';
import '../../features/master/presentation/pages/master_company_form_page.dart';
import '../../features/master/presentation/pages/master_company_page.dart';
import '../../features/master/presentation/pages/master_employee_detail_page.dart';
import '../../features/master/presentation/pages/master_employee_form_page.dart';
import '../../features/master/presentation/pages/master_employee_page.dart';
import '../../features/master/presentation/pages/master_form_detail_page.dart';
import '../../features/master/presentation/pages/master_form_form_page.dart';
import '../../features/master/presentation/pages/master_form_page.dart';
import '../../features/master/presentation/pages/master_page.dart';
import '../../features/master/presentation/pages/master_plant_detail_page.dart';
import '../../features/master/presentation/pages/master_plant_form_page.dart';
import '../../features/master/presentation/pages/master_plant_page.dart';
import '../../features/master/presentation/pages/master_position_detail_page.dart';
import '../../features/master/presentation/pages/master_position_form_page.dart';
import '../../features/master/presentation/pages/master_position_page.dart';
import '../../features/master/presentation/pages/master_user_detail_page.dart';
import '../../features/master/presentation/pages/master_user_form_page.dart';
import '../../features/master/presentation/pages/master_user_page.dart';
import '../../features/overtime/presentation/pages/overtime_add_page.dart';
import '../../features/overtime/presentation/pages/overtime_page.dart';
import '../../features/reimbursement/presentation/pages/reimbursement_add_page.dart';
import '../../features/reimbursement/presentation/pages/reimbursement_page.dart';
import '../../features/report/presentation/pages/report_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/system/presentation/pages/system_page.dart';
import '../../features/transaction/presentation/pages/transaction_page.dart';

/// All named route paths as constants so they can be
/// referenced type-safely throughout the codebase.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String transaction = '/transaction';
  static const String master = '/master';
  static const String system = '/system';
  static const String report = '/report';
  static const String checkIn = '/check-in';
  static const String checkOut = '/check-out';
  static const String forgotPassword = '/forgot-password';
  static const String reimbursement = '/reimbursement';
  static const String reimbursementAdd = '/reimbursement/add';
  static const String absent = '/absent';
  static const String absentAdd = '/absent/add';
  static const String leave = '/leave';
  static const String leaveAdd = '/leave/add';
  static const String overtime = '/overtime';
  static const String overtimeAdd = '/overtime/add';
  static const String masterCompany = '/master/company';
  static const String masterCompanyAdd = '/master/company/add';
  static const String masterCompanyDetail = '/master/company/detail';
  static const String masterPlant = '/master/plant';
  static const String masterPlantAdd = '/master/plant/add';
  static const String masterPlantDetail = '/master/plant/detail';
  static const String masterPosition = '/master/position';
  static const String masterPositionAdd = '/master/position/add';
  static const String masterPositionDetail = '/master/position/detail';
  static const String masterUser = '/master/user';
  static const String masterUserAdd = '/master/user/add';
  static const String masterUserDetail = '/master/user/detail';
  static const String masterAction = '/master/action';
  static const String masterActionAdd = '/master/action/add';
  static const String masterActionDetail = '/master/action/detail';
  static const String masterEmployee = '/master/employee';
  static const String masterEmployeeAdd = '/master/employee/add';
  static const String masterEmployeeDetail = '/master/employee/detail';
  static const String masterForm = '/master/form';
  static const String masterFormAdd = '/master/form/add';
  static const String masterFormDetail = '/master/form/detail';
}

/// A [Listenable] that notifies GoRouter when the auth state
/// changes, so `redirect` is re-evaluated without recreating
/// the entire router.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) {
      notifyListeners();
    });
  }
}

/// Provides the application [GoRouter] as a Riverpod provider.
///
/// Uses [refreshListenable] so that auth-state changes
/// trigger `redirect` re-evaluation without rebuilding the
/// router from scratch (which would reset to initialLocation).
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthNotifierListenable(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,

    // ── Global redirect ───────────────────────────────
    redirect: (context, state) {
      // Read (not watch) the CURRENT auth state each time
      // redirect is evaluated.
      final authState = ref.read(authProvider);

      final currentPath = state.uri.path;
      final isSplash = currentPath == RoutePaths.splash;
      final isLogin = currentPath == RoutePaths.login;
      final isForgotPassword = currentPath == RoutePaths.forgotPassword;

      // Still determining auth status — stay on splash.
      if (authState is AuthInitial) {
        return isSplash ? null : RoutePaths.splash;
      }

      // Loading → don't redirect; stay on current page.
      if (authState is AuthLoading) {
        return null;
      }

      // Authenticated → leave splash/login, go to dashboard.
      if (authState is AuthAuthenticated) {
        if (isSplash || isLogin || isForgotPassword) {
          return RoutePaths.dashboard;
        }
        return null;
      }

      // Unauthenticated / error → leave splash, go to login.
      if (isSplash || !(isLogin || isForgotPassword)) {
        return RoutePaths.login;
      }
      return null;
    },

    // ── Routes ────────────────────────────────────────
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: RoutePaths.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(path: RoutePaths.checkIn, builder: (_, _) => const CheckInPage()),
      GoRoute(
        path: RoutePaths.checkOut,
        builder: (_, _) => const CheckOutPage(),
      ),
      GoRoute(
        path: RoutePaths.reimbursement,
        builder: (_, _) => const ReimbursementPage(),
      ),
      GoRoute(
        path: RoutePaths.reimbursementAdd,
        builder: (_, _) => const ReimbursementAddPage(),
      ),
      GoRoute(path: RoutePaths.absent, builder: (_, _) => const AbsentPage()),
      GoRoute(
        path: RoutePaths.absentAdd,
        builder: (_, _) => const AbsentAddPage(),
      ),
      GoRoute(path: RoutePaths.leave, builder: (_, _) => const LeavePage()),
      GoRoute(
        path: RoutePaths.leaveAdd,
        builder: (_, _) => const LeaveAddPage(),
      ),
      GoRoute(
        path: RoutePaths.overtime,
        builder: (_, _) => const OvertimePage(),
      ),
      GoRoute(
        path: RoutePaths.overtimeAdd,
        builder: (_, _) => const OvertimeAddPage(),
      ),
      GoRoute(
        path: RoutePaths.masterCompany,
        builder: (_, _) => const MasterCompanyPage(),
      ),
      GoRoute(
        path: RoutePaths.masterCompanyAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterCompanyFormPage(
            initialData: extra is MasterCompanyData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterCompanyDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterCompanyData) {
            return const MasterCompanyPage();
          }

          return MasterCompanyDetailPage(company: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.masterPlant,
        builder: (_, _) => const MasterPlantPage(),
      ),
      GoRoute(
        path: RoutePaths.masterPlantAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterPlantFormPage(
            initialData: extra is MasterPlantData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterPlantDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterPlantData) {
            return const MasterPlantPage();
          }

          return MasterPlantDetailPage(plant: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.masterPosition,
        builder: (_, _) => const MasterPositionPage(),
      ),
      GoRoute(
        path: RoutePaths.masterPositionAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterPositionFormPage(
            initialData: extra is MasterPositionData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterPositionDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterPositionData) {
            return const MasterPositionPage();
          }

          return MasterPositionDetailPage(position: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.masterUser,
        builder: (_, _) => const MasterUserPage(),
      ),
      GoRoute(
        path: RoutePaths.masterUserAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterUserFormPage(
            initialData: extra is MasterUserData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterUserDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterUserData) {
            return const MasterUserPage();
          }

          return MasterUserDetailPage(user: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.masterAction,
        builder: (_, _) => const MasterActionPage(),
      ),
      GoRoute(
        path: RoutePaths.masterActionAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterActionFormPage(
            initialData: extra is MasterActionData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterActionDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterActionData) {
            return const MasterActionPage();
          }

          return MasterActionDetailPage(action: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.masterEmployee,
        builder: (_, _) => const MasterEmployeePage(),
      ),
      GoRoute(
        path: RoutePaths.masterEmployeeAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterEmployeeFormPage(
            initialData: extra is MasterEmployeeData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterEmployeeDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterEmployeeData) {
            return const MasterEmployeePage();
          }

          return MasterEmployeeDetailPage(employee: extra);
        },
      ),
      GoRoute(
        path: RoutePaths.masterForm,
        builder: (_, _) => const MasterFormPage(),
      ),
      GoRoute(
        path: RoutePaths.masterFormAdd,
        builder: (_, state) {
          final extra = state.extra;
          return MasterFormFormPage(
            initialData: extra is MasterFormData ? extra : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.masterFormDetail,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! MasterFormData) {
            return const MasterFormPage();
          }

          return MasterFormDetailPage(formData: extra);
        },
      ),

      // Main shell with 5 tabs
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            MainShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (_, _) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.transaction,
                builder: (_, _) => const TransactionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.master,
                builder: (_, _) => const MasterPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.report,
                builder: (_, _) => const ReportPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.system,
                builder: (_, _) => const SystemPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
