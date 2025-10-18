import 'package:flutter/material.dart';
import 'package:frijo_noviindus_app/features/home/model/feedmodel.dart';
import 'package:video_player/video_player.dart';

import '../data/home_api.dart';

class HomeController extends ChangeNotifier {
  List<String> categories = [];
  List<Feed> feeds = [];
  bool isLoading = false;

  VideoPlayerController? activeController;

  Future<void> fetchCategories() async {
    categories = await HomeApi.fetchCategories();
    notifyListeners();
  }

  Future<void> fetchFeeds() async {
    isLoading = true;
    notifyListeners();

    feeds = await HomeApi.fetchFeeds();

    isLoading = false;
    notifyListeners();
  }
void playVideo(Feed feed) async {
  try {
    // Dispose previous controller if exists
    if (activeController != null) {
      await activeController!.pause();
      await activeController!.dispose();
    }

    // Create a new controller
    activeController = VideoPlayerController.network(feed.video);
    await activeController!.initialize(); // wait for it

    // Start playing after initialized
    await activeController!.play();

    notifyListeners(); // rebuild UI after ready
  } catch (e) {
    print('Error playing video: $e');
  }
}

  void disposeController() {
    activeController?.dispose();
  }
}
