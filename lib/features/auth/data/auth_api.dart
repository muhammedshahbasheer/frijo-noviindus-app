import 'package:frijo_noviindus_app/core/network/api_endpoints.dart';

import '../../../core/network/api_client.dart';

class AuthApi {
  static Future<dynamic> login({
    required String countryCode,
    required String phone,
  }) async {
    return await ApiClient.post(
      ApiEndpoints.otpVerify,
      auth: false,
      isFormData: true,
      body: {
        "country_code": countryCode,
        "phone": phone,
      },
    );
  }
}