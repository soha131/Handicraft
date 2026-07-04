import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_service.dart';
import 'core/services/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/workshops/presentation/cubit/workshop_cubit.dart';
import 'features/bookings/presentation/cubit/booking_cubit.dart';
import 'features/reviews/presentation/cubit/review_cubit.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection locator
  await initInjection();

  // Initialize Firebase safely (prevents cold startup crash on missing google-services)
  await FirebaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingCubit>(
          create: (context) => sl<OnboardingCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => sl<ProfileCubit>(),
        ),
        BlocProvider<WorkshopCubit>(
          create: (context) => sl<WorkshopCubit>(),
        ),
        BlocProvider<BookingCubit>(
          create: (context) => sl<BookingCubit>(),
        ),
        BlocProvider<ReviewCubit>(
          create: (context) => sl<ReviewCubit>(),
        ),
        BlocProvider<AdminCubit>(
          create: (context) => sl<AdminCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Handicraft AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
