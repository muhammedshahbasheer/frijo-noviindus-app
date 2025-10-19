import 'dart:convert';
import 'dart:io';
import 'package:frijo_noviindus_app/core/constants/app_constant.dart';
import 'package:http/http.dart' as http;

class FeedApi {
  static Future<dynamic> uploadFeed({
    required File video,
    required File image,
    required String desc,
    required List<int> categoryIds,
    required String accessToken,
    Function(int, int)? onProgress,
  }) async {
    final uri = Uri.parse("${AppConstants.baseUrl}my_feed");

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['desc'] = desc;
    request.fields['category'] = '[${categoryIds.join(',')}]';

    request.files.add(await http.MultipartFile.fromPath('video', video.path));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    print("Uploading to: ${uri.toString()}");
    print("Headers: ${request.headers}");
    print("Fields: ${request.fields}");

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      print("Status: ${streamedResponse.statusCode}");
      print("Response: $responseBody");

      
      if (streamedResponse.statusCode < 200 ||
          streamedResponse.statusCode >= 300) {
        throw Exception('Upload failed: $responseBody');
      }

      return jsonDecode(responseBody);
    } catch (e) {
      print("Upload error: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getMyFeeds(String accessToken) async {
    final uri = Uri.parse("${AppConstants.baseUrl}my_feed");

    print("📡 Fetching My Feeds from: $uri");
    print("🔑 Using Token: $accessToken");

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map &&
            jsonResponse.containsKey("results") &&
            jsonResponse["results"] is List) {
          print("Parsed Feeds Count: ${jsonResponse["results"].length}");
          return List<Map<String, dynamic>>.from(jsonResponse["results"]);
        } else {
          print("Unexpected response format, returning empty list");
          return [];
        }
      } else {
        throw Exception('Failed to load feeds: ${response.body}');
      }
    } catch (e) {
      print("Error fetching feeds: $e");
      rethrow;
    }
  }
}
