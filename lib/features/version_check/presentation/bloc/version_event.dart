import 'package:equatable/equatable.dart';

abstract class VersionEvent extends Equatable {
  const VersionEvent();

  @override
  List<Object?> get props => [];
}

class CheckVersionStarted extends VersionEvent {
  final String? testVersionOverride;

  const CheckVersionStarted({this.testVersionOverride});

  @override
  List<Object?> get props => [testVersionOverride];
}
