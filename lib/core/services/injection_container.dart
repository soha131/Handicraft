import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/check_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_user_stream_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_photo_usecase.dart';
import '../../features/profile/domain/usecases/change_password_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/workshops/data/datasources/workshop_remote_data_source.dart';
import '../../features/workshops/data/repositories/workshop_repository_impl.dart';
import '../../features/workshops/domain/repositories/workshop_repository.dart';
import '../../features/workshops/domain/usecases/workshop_usecases.dart';
import '../../features/workshops/presentation/cubit/workshop_cubit.dart';

import '../../features/bookings/data/datasources/booking_remote_data_source.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/domain/usecases/booking_usecases.dart';
import '../../features/bookings/presentation/cubit/booking_cubit.dart';

import '../../features/reviews/data/datasources/review_remote_data_source.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/reviews/domain/usecases/review_usecases.dart';
import '../../features/reviews/presentation/cubit/review_cubit.dart';

import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/admin_usecases.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // ── External ────────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Firebase singletons
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // ── Data Sources ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      storage: sl(),
    ),
  );
  sl.registerLazySingleton<WorkshopRemoteDataSource>(
    () => WorkshopRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // ── Repositories ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WorkshopRepository>(
    () => WorkshopRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────────
  // Onboarding
  sl.registerLazySingleton(() => CheckOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStreamUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  // Profile
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePhotoUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

  // Workshops
  sl.registerLazySingleton(() => CreateWorkshopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWorkshopUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkshopUseCase(sl()));
  sl.registerLazySingleton(() => GetOwnerWorkshopsUseCase(sl()));
  sl.registerLazySingleton(() => GetAllWorkshopsUseCase(sl()));

  // Bookings
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetUserBookingsUseCase(sl()));

  // Reviews
  sl.registerLazySingleton(() => AddReviewUseCase(sl()));
  sl.registerLazySingleton(() => UpdateReviewUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReviewUseCase(sl()));
  sl.registerLazySingleton(() => GetWorkshopReviewsUseCase(sl()));

  // Admin
  sl.registerLazySingleton(() => GetAdminStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersAdminUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserAdminUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserRoleUseCase(sl()));
  sl.registerLazySingleton(() => GetAllWorkshopsAdminUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWorkshopAdminUseCase(sl()));
  sl.registerLazySingleton(() => GetAllReviewsAdminUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReviewAdminUseCase(sl()));

  // ── Cubits / Blocs ────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => OnboardingCubit(
      checkOnboardingUseCase: sl(),
      completeOnboardingUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      logoutUseCase: sl(),
      getUserStreamUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      updateProfilePhotoUseCase: sl(),
      changePasswordUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => WorkshopCubit(
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
      getOwnerWorkshopsUseCase: sl(),
      getAllWorkshopsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => BookingCubit(
      createUseCase: sl(),
      cancelUseCase: sl(),
      getUserBookingsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ReviewCubit(
      addUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
      getWorkshopReviewsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AdminCubit(
      getStatsUseCase: sl(),
      getUsersUseCase: sl(),
      deleteUserUseCase: sl(),
      updateUserRoleUseCase: sl(),
      getWorkshopsUseCase: sl(),
      deleteWorkshopUseCase: sl(),
      getReviewsUseCase: sl(),
      deleteReviewUseCase: sl(),
    ),
  );
}
