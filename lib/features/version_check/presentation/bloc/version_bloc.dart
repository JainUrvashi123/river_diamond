import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/repositories/version_repository.dart';
import 'version_event.dart';
import 'version_state.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  final VersionRepository versionRepository;

  VersionBloc({required this.versionRepository}) : super(VersionInitial()) {
    on<CheckVersionStarted>(_onCheckVersionStarted);
  }

  Future<void> _onCheckVersionStarted(
    CheckVersionStarted event,
    Emitter<VersionState> emit,
  ) async {
    emit(VersionCheckInProgress());
    try {
      String currentVersion = '1.0.0';
      
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
      } catch (e) {
        // Fallback to default if package info fails
      }

      // If testVersionOverride is provided, use it
      if (event.testVersionOverride != null && event.testVersionOverride!.isNotEmpty) {
        currentVersion = event.testVersionOverride!;
      }

      final platform = Platform.isIOS ? 'ios' : 'android';

      final versionInfo = await versionRepository.checkVersion(
        version: currentVersion,
        platform: platform,
      );

      if (versionInfo.updateRequired) {
        emit(VersionUpdateAvailable(versionInfo: versionInfo));
      } else {
        emit(VersionUpToDate(currentVersion: currentVersion));
      }
    } catch (e) {
      emit(VersionCheckFailure(errorMessage: e.toString()));
    }
  }
}
