import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:frijo_noviindus_app/features/feed/feed_api.dart';

class FeedController extends ChangeNotifier {
  File? videoFile;
  File? imageFile;
  bool isUploading = false;
  double uploadProgress = 0.0;

  // ✅ For "My Feeds"
  bool isLoading = false;
  List<dynamic> myFeeds = [];

  void setVideo(File file) {
    videoFile = file;
    notifyListeners();
  }

  void setImage(File file) {
    imageFile = file;
    notifyListeners();
  }

  Future<String?> validateVideo(File file) async {
    if (!file.path.toLowerCase().endsWith('.mp4')) {
      return 'Only MP4 videos allowed';
    }

    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();

    if (duration.inMinutes > 5) {
      return 'Video must be less than 5 minutes';
    }
    return null;
  }

  // ✅ Fetch My Feeds
  Future<void> fetchMyFeeds() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';
      if (accessToken.isEmpty) throw Exception("User not authenticated");

      final feeds = await FeedApi.getMyFeeds(accessToken);
      myFeeds = feeds;
    } catch (e) {
      debugPrint("❌ Error fetching feeds: $e");
      myFeeds = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Upload Feed
  Future<void> uploadFeed({
    required String desc,
    required List<int> categories,
    required BuildContext context,
  }) async {
    if (videoFile == null || imageFile == null || desc.isEmpty || categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final validationError = await validateVideo(videoFile!);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';
    if (accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Please log in again.'),
        ),
      );
      return;
    }

    isUploading = true;
    uploadProgress = 0.0;
    notifyListeners();

    try {
      final response = await FeedApi.uploadFeed(
        video: videoFile!,
        image: imageFile!,
        desc: desc,
        categoryIds: categories,
        accessToken: accessToken,
        onProgress: (sent, total) {
          uploadProgress = total > 0 ? sent / total : 0.0;
          notifyListeners();
        },
      );

      uploadProgress = 1.0;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Feed uploaded successfully!')),
      );

      // Reset
      videoFile = null;
      imageFile = null;
      isUploading = false;
      uploadProgress = 0.0;
      notifyListeners();

      Navigator.pop(context);
    } catch (e) {
      isUploading = false;
      uploadProgress = 0.0;
      notifyListeners();

      debugPrint('❌ Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }
}
