import 'package:equatable/equatable.dart';
import '../../data/models/version_model.dart';

abstract class VersionState extends Equatable {
  const VersionState();

  @override
  List<Object?> get props => [];
}

class VersionInitial extends VersionState {}

class VersionCheckInProgress extends VersionState {}

class VersionUpToDate extends VersionState {
  final String currentVersion;

  const VersionUpToDate({required this.currentVersion});

  @override
  List<Object?> get props => [currentVersion];
}

class VersionUpdateAvailable extends VersionState {
  final VersionModel versionInfo;

  const VersionUpdateAvailable({required this.versionInfo});

  @override
  List<Object?> get props => [versionInfo];
}

class VersionCheckFailure extends VersionState {
  final String errorMessage;

  const VersionCheckFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
