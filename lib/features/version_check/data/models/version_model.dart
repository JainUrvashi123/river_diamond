class VersionModel {
  final bool status;
  final bool updateRequired;
  final String currentVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? playStoreUrl;
  final String? appStoreUrl;

  VersionModel({
    required this.status,
    required this.updateRequired,
    required this.currentVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.playStoreUrl,
    this.appStoreUrl,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      status: json['status'] == true || json['status'] == 1 || json['status'] == 'true',
      updateRequired: json['update_required'] == true || json['update_required'] == 1 || json['update_required'] == 'true',
      currentVersion: json['current_version']?.toString() ?? '',
      latestVersion: json['latest_version']?.toString() ?? '',
      forceUpdate: json['force_update'] == true || json['force_update'] == 1 || json['force_update'] == 'true',
      playStoreUrl: json['playstore_url']?.toString(),
      appStoreUrl: json['appstore_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'update_required': updateRequired,
      'current_version': currentVersion,
      'latest_version': latestVersion,
      'force_update': forceUpdate,
      'playstore_url': playStoreUrl,
      'appstore_url': appStoreUrl,
    };
  }
}
