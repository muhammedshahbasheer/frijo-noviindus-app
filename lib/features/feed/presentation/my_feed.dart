import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'feed_controller.dart'; 

class MyFeedScreen extends StatefulWidget {
  const MyFeedScreen({super.key});

  @override
  State<MyFeedScreen> createState() => _MyFeedScreenState();
}

class _MyFeedScreenState extends State<MyFeedScreen> {
  VideoPlayerController? _activeController;
  String? _activeVideoUrl;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<FeedController>(context, listen: false).fetchMyFeeds());
  }

  @override
  void dispose() {
    _activeController?.dispose();
    super.dispose();
  }

  Future<void> _playVideo(String videoUrl) async {
    if (_activeVideoUrl == videoUrl) {
      // Toggle play/pause
      if (_activeController!.value.isPlaying) {
        _activeController!.pause();
      } else {
        _activeController!.play();
      }
      setState(() {});
      return;
    }

    // Dispose previous controller
    _activeController?.dispose();

    final controller = VideoPlayerController.network(videoUrl);
    await controller.initialize();
    controller.play();

    setState(() {
      _activeController = controller;
      _activeVideoUrl = videoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FeedController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('My Feeds'),
        backgroundColor: const Color(0xFF0F0F0F),
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : controller.myFeeds.isEmpty
              ? const Center(
                  child: Text(
                    "No feeds uploaded yet.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.myFeeds.length,
                  itemBuilder: (context, index) {
                    final feed = controller.myFeeds[index];
                    final imageUrl = feed["image"];
                    final videoUrl = feed["video"];
                    final desc = feed["description"] ?? "No description";

                    final isPlaying = _activeVideoUrl == videoUrl &&
                        _activeController != null &&
                        _activeController!.value.isPlaying;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _playVideo(videoUrl),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _activeVideoUrl == videoUrl &&
                                          _activeController != null &&
                                          _activeController!
                                              .value.isInitialized
                                      ? AspectRatio(
                                          aspectRatio: _activeController!
                                              .value.aspectRatio,
                                          child:
                                              VideoPlayer(_activeController!),
                                        )
                                      : Image.network(
                                          imageUrl ?? '',
                                          height: 220,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            height: 220,
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Description
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              desc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Created Date
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              feed["created_at"]
                                  ?.toString()
                                  .substring(0, 10) ?? '',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
