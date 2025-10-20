import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'feed_controller.dart';

class MyFeedScreen extends StatefulWidget {
  const MyFeedScreen({super.key});

  @override
  State<MyFeedScreen> createState() => _MyFeedScreenState();
}

class _MyFeedScreenState extends State<MyFeedScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int? _currentPlayingIndex;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<FeedController>(context, listen: false).fetchMyFeeds());
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _currentPlayingIndex = null;
  }

  Future<void> _playVideo(String videoUrl, int index) async {
    // Stop any currently playing video
    if (_currentPlayingIndex != index) {
      _disposePlayer();

      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        aspectRatio: controller.value.aspectRatio,
        allowMuting: true,
        showControls: true,
        showOptions: false,
      );

      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _currentPlayingIndex = index;
      });
    } else {
      // Toggle play/pause for the same video
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FeedController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('My Feeds',style: TextStyle(color: Colors.white),),
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
                    final createdAt = feed["created_at"] ?? '';

                    final isPlaying = _currentPlayingIndex == index;

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
                            onTap: () => _playVideo(videoUrl, index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: isPlaying && _videoController != null
                                    ? _videoController!.value.aspectRatio
                                    : 16 / 9,
                                child: isPlaying && _chewieController != null
                                    ? Chewie(controller: _chewieController!)
                                    : Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            imageUrl ?? '',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              color: Colors.grey[800],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Center(
                                            child: Icon(
                                              Icons.play_circle_fill,
                                              size: 60,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  desc,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  createdAt.toString().substring(0, 10),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
