import 'dart:io';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class FeedApi {
  static Future<dynamic> uploadFeed({
    required File video,
    required File image,
    required String desc,
    required List<int> categoryIds,
    Function(int, int)? onProgress,
  }) async {
    final fields = {
      'desc': desc,
      'category': categoryIds.join(','), // send as CSV or adjust per backend
    };

    final files = {
      'video': video,
      'image': image,
    };

    return await ApiClient.postMultipart(
      ApiEndpoints.myFeed,
      fields: fields,
      files: files,
      auth: true, // sends Bearer token automatically
      onProgress: onProgress,
    );
  }
}
