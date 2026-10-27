import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:river_diamond/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:river_diamond/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:river_diamond/features/diamond/data/datasources/diamond_remote_datasource.dart';
import 'package:river_diamond/features/diamond/data/repositories/diamond_repository.dart';
import 'package:river_diamond/features/auth/domain/usecases/login_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/signup_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/submit_contact_usecase.dart';
import 'package:river_diamond/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:river_diamond/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:river_diamond/features/cart/data/repositories/cart_repository.dart';
import 'package:river_diamond/features/version_check/data/datasources/version_remote_datasource.dart';
import 'package:river_diamond/features/version_check/data/repositories/version_repository.dart';
import 'package:river_diamond/main.dart';

void main() {
  testWidgets('River Diamond Auth Flow Render Smoke Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
    });

    // Instantiate test environment services
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);
    final loginUseCase = LoginUseCase(repository);
    final signUpUseCase = SignUpUseCase(repository);
    final forgotPasswordUseCase = ForgotPasswordUseCase(repository);
    final getProfileUseCase = GetProfileUseCase(repository);
    final updateProfileUseCase = UpdateProfileUseCase(repository);
    final updatePasswordUseCase = UpdatePasswordUseCase(repository);
    final submitContactUseCase = SubmitContactUseCase(repository);
    final deleteAccountUseCase = DeleteAccountUseCase(repository);

    final diamondRemoteDataSource = DiamondRemoteDataSourceImpl();
    final diamondRepository = DiamondRepositoryImpl(remoteDataSource: diamondRemoteDataSource);

    final cartRemoteDataSource = CartRemoteDataSourceImpl();
    final cartRepository = CartRepositoryImpl(remoteDataSource: cartRemoteDataSource);

    final versionRemoteDataSource = VersionRemoteDataSourceImpl();
    final versionRepository = VersionRepositoryImpl(remoteDataSource: versionRemoteDataSource);

    // Build the app
    await tester.pumpWidget(
      MyApp(
        loginUseCase: loginUseCase,
        signUpUseCase: signUpUseCase,
        forgotPasswordUseCase: forgotPasswordUseCase,
        getProfileUseCase: getProfileUseCase,
        updateProfileUseCase: updateProfileUseCase,
        updatePasswordUseCase: updatePasswordUseCase,
        submitContactUseCase: submitContactUseCase,
        deleteAccountUseCase: deleteAccountUseCase,
        diamondRepository: diamondRepository,
        cartRepository: cartRepository,
        versionRepository: versionRepository,
      ),
    );

    // Wait for the fonts or initialization to complete
    await tester.pumpAndSettle();

    // Verify that the River Diamond logo and Login interface elements are displayed
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
