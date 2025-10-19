import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_api.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> login({
    required String phone,
    required String countrycode,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthApi.login(
        countryCode: countrycode,
        phone: phone,
      );

      // ✅ Get both tokens safely
      final accessToken = response["token"]?["access"];
      final refreshToken = response["token"]?["refresh"];

      if (accessToken != null && refreshToken != null) {
        final prefs = await SharedPreferences.getInstance();

        // ✅ Save tokens correctly
        await prefs.setString("access_token", accessToken);
        await prefs.setString("refresh_token", refreshToken);

        debugPrint("✅ Access Token saved successfully");
        debugPrint("✅ Refresh Token saved successfully");

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("❌ Login failed: tokens missing in response");
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
