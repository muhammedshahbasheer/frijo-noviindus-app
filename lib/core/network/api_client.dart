import 'dart:convert';
import 'package:frijo_noviindus_app/core/constants/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ApiClient {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
  static Future<dynamic> get(String endpoint, {bool auth = false}) async {
    final token = auth ? await _getToken() : null;

    final response = await http.get(
      Uri.parse(AppConstants.baseUrl + endpoint),
      headers: auth ? {'Authorization': 'Bearer $token'} : {},
    );

    return _processResponse(response);
  }
  static Future<dynamic> post(String endpoint,
      {Map<String, String>? body,
      bool auth = false,
      bool isFormData = false}) async {
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
  static dynamic _processResponse(http.Response response) {
    final jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if (response.statusCode >= 200) {
      return jsonResponse;
    } else {
      throw Exception(jsonResponse["message"] ?? "Something went wrong");
    }
  }
}