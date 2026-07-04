import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/workshops/presentation/pages/owner_workshops_page.dart';
import '../../features/workshops/presentation/pages/workshop_form_page.dart';
import '../../features/workshops/presentation/pages/browse_workshops_page.dart';
import '../../features/workshops/presentation/pages/workshop_details_page.dart';
import '../../features/workshops/data/models/workshop_model.dart';
import '../../features/bookings/presentation/pages/my_bookings_page.dart';
import '../../features/admin/presentation/pages/admin_panel_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String ownerWorkshops = '/workshops/owner';
  static const String workshopForm = '/workshops/form';
  static const String browseWorkshops = '/workshops/browse';
  static const String workshopDetails = '/workshops/details';
  static const String myBookings = '/bookings/my';
  static const String adminPanel = '/admin';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return RegisterPage(preSelectedRole: role);
        },
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      // Profile routes — now uses the global ProfileCubit from main.dart
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: ownerWorkshops,
        builder: (context, state) => const OwnerWorkshopsPage(),
      ),
      GoRoute(
        path: workshopForm,
        builder: (context, state) {
          final workshop = state.extra as WorkshopModel?;
          return WorkshopFormPage(existingWorkshop: workshop);
        },
      ),
      GoRoute(
        path: browseWorkshops,
        builder: (context, state) => const BrowseWorkshopsPage(),
      ),
      GoRoute(
        path: workshopDetails,
        builder: (context, state) {
          final workshop = state.extra as WorkshopModel;
          return WorkshopDetailsPage(workshop: workshop);
        },
      ),
      GoRoute(
        path: myBookings,
        builder: (context, state) => const MyBookingsPage(),
      ),
      GoRoute(
        path: adminPanel,
        builder: (context, state) => const AdminPanelPage(),
      ),
    ],
  );
}
