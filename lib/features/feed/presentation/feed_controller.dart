import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frijo_noviindus_app/features/feed/feed_api.dart';


class FeedController extends ChangeNotifier {
  File? videoFile;
  File? imageFile;
  bool isUploading = false;
  double uploadProgress = 0.0;

  void setVideo(File file) {
    videoFile = file;
    notifyListeners();
  }

  void setImage(File file) {
    imageFile = file;
    notifyListeners();
  }

  Future<void> uploadFeed({
    required String desc,
    required List<int> categories,
    required BuildContext context,
  }) async {
    if (videoFile == null || imageFile == null || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    isUploading = true;
    notifyListeners();

    try {
      await FeedApi.uploadFeed(
        video: videoFile!,
        image: imageFile!,
        desc: desc,
        categoryIds: categories,
        onProgress: (sent, total) {
          uploadProgress = sent / total;
          notifyListeners();
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feed uploaded successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload feed')),
      );
    }

    isUploading = false;
    uploadProgress = 0.0;
    notifyListeners();
  }
}
