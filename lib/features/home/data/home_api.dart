import 'package:frijo_noviindus_app/core/network/api_endpoints.dart';
import 'package:frijo_noviindus_app/features/home/model/feedmodel.dart';

import '../../../core/network/api_client.dart';

class HomeApi {
  static Future<List<String>> fetchCategories() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.home);
      // category_dict → extract titles
      final List data = res['category_dict'] ?? [];
      return List<String>.from(data.map((e) => e['title'] ?? ''));
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
  static Future<List<Feed>> fetchFeeds() async {
    try {
      final res = await ApiClient.get(ApiEndpoints.home);
      final List data = res['results'] ?? [];
      return List<Feed>.from(data.map((e) => Feed.fromJson(e)));
    } catch (e) {
      print('Error fetching feeds: $e');
      return [];
    }
  }
}
