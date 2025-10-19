import 'dart:convert';
import 'dart:io';
import 'package:frijo_noviindus_app/core/constants/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // --------------------------
  // Token Handling
  // --------------------------
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // --------------------------
  // GET
  // --------------------------
  static Future<dynamic> get(String endpoint, {bool auth = false}) async {
    final token = auth ? await _getToken() : null;

    final response = await http.get(
      Uri.parse(AppConstants.baseUrl + endpoint),
      headers: auth ? {'Authorization': 'Bearer $token'} : {},
    );

    return _processResponse(response);
  }

  // --------------------------
  // POST (JSON / FormData)
  // --------------------------
  static Future<dynamic> post(
    String endpoint, {
    Map<String, String>? body,
    bool auth = false,
    bool isFormData = false,
  }) async {
    final token = auth ? await _getToken() : null;

    final response = await http.post(
      Uri.parse(AppConstants.baseUrl + endpoint),
      headers: {
        if (auth) 'Authorization': 'Bearer $token',
        if (!isFormData) 'Content-Type': 'application/json',
      },
      body: isFormData ? body : jsonEncode(body),
    );

    return _processResponse(response);
  }

  // --------------------------
  // NEW: Multipart POST (for file upload)
  // --------------------------
  static Future<dynamic> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    bool auth = false,
    Function(int, int)? onProgress,
  }) async {
    final token = auth ? await _getToken() : null;

    final uri = Uri.parse(AppConstants.baseUrl + endpoint);
    final request = http.MultipartRequest('POST', uri);

    if (auth && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add normal fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add files
    if (files != null) {
      for (final entry in files.entries) {
        final key = entry.key;
        final file = entry.value;
        final fileName = file.path.split(Platform.pathSeparator).last;
        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();
        final multipartFile =
            http.MultipartFile(key, fileStream, fileLength, filename: fileName);
        request.files.add(multipartFile);
      }
    }

    // Send request
    final streamedResponse = await request.send();

    // Optional upload progress (approximate)
    if (onProgress != null) {
      int total = 0;
      streamedResponse.stream.listen(
        (chunk) {
          total += chunk.length;
          onProgress(total, streamedResponse.contentLength ?? total);
        },
      );
    }

    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  // --------------------------
  // Response Handler
  // --------------------------
  static dynamic _processResponse(http.Response response) {
    final jsonResponse = jsonDecode(response.body);
    print('STATUS: ${response.statusCode}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonResponse;
    } else {
      throw Exception(jsonResponse["message"] ?? "Something went wrong");
    }
  }
}
