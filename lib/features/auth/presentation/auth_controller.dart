import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_api.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;

  Future<bool> login({required String phone,required String countrycode}) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await AuthApi.login(
        countryCode: countrycode,
        phone: phone,
      );

      final token = response["token"]["refresh"];
     print(token);
      if (token != null) {
        final prefs = await SharedPreferences.getInstance(); 
        await prefs.setString("token", token);
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e'); 
  return false;
    } finally {
    isLoading = false;
    notifyListeners();
  }
  }
}
