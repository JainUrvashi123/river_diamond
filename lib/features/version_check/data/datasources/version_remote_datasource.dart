import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/utils/constants.dart';
import '../models/version_model.dart';

abstract class VersionRemoteDataSource {
  Future<VersionModel> checkVersion({
    required String version,
    required String platform,
  });
}

class VersionRemoteDataSourceImpl implements VersionRemoteDataSource {
  final Dio _dio;

  VersionRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<VersionModel> checkVersion({
    required String version,
    required String platform,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.apiBaseUrl}/check-app-version',
        data: {
          'version': version,
          'platform': platform,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (responseData == null) {
        throw Exception('Server returned an empty response.');
      }

      Map<String, dynamic> jsonMap;
      if (responseData is Map<String, dynamic>) {
        jsonMap = responseData;
      } else if (responseData is String) {
        jsonMap = json.decode(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected server response format.');
      }

      return VersionModel.fromJson(jsonMap);
    } catch (e) {
      rethrow;
    }
  }
}
