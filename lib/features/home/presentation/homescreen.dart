import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:frijo_noviindus_app/features/feed/presentation/add_feed.dart';
import 'package:frijo_noviindus_app/features/feed/presentation/feed_controller.dart';
import 'package:frijo_noviindus_app/features/feed/presentation/my_feed.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int? _currentlyPlayingIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<HomeController>(context, listen: false);
      controller.fetchFeeds();
    });
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
    _currentlyPlayingIndex = null;
  }

  Future<void> _playVideo(String url, int index) async {
    // Stop any currently playing video
    if (_currentlyPlayingIndex != index) {
      _disposePlayer();

      final controller = VideoPlayerController.network(url);
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
        _currentlyPlayingIndex = index;
      });
    } else {
      // If same video tapped, toggle play/pause
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
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        title: const Text('Feeds', style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => FeedController(),
                    child: const MyFeedScreen(),
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => FeedController(),
                child: const AddFeedScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : RefreshIndicator(
              onRefresh: () async => controller.fetchFeeds(),
              child: ListView.builder(
                itemCount: controller.feeds.length,
                itemBuilder: (context, index) {
                  final feed = controller.feeds[index];
                  final isPlaying = _currentlyPlayingIndex == index;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            backgroundImage: (feed.userImage != null &&
                                    feed.userImage!.isNotEmpty)
                                ? NetworkImage(feed.userImage!)
                                : null,
                            child: (feed.userImage == null ||
                                    feed.userImage!.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            feed.username,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "5 days ago",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),

                        // Thumbnail / Video Player
                        GestureDetector(
                          onTap: () => _playVideo(feed.video, index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                                          feed.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  color: Colors.white54),
                                            ),
                                          ),
                                        ),
                                        const Center(
                                          child: Icon(Icons.play_circle_fill,
                                              size: 60, color: Colors.white70),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        // Description
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            feed.description,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
