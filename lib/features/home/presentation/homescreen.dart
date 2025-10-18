import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'home_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final controller = Provider.of<HomeController>(context, listen: false);
    controller.fetchCategories();
    controller.fetchFeeds();
  });
}


  @override
  void dispose() {
    Provider.of<HomeController>(context, listen: false).disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Categories
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            controller.categories[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Feed List
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.feeds.length,
                    itemBuilder: (context, index) {
                      final feed = controller.feeds[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video / Thumbnail
                            GestureDetector(
                              onTap: () => controller.playVideo(feed),
                              child: controller.activeController != null &&
                                      controller.activeController!.dataSource == feed.video
                                  ? AspectRatio(
                                      aspectRatio: controller.activeController!.value.aspectRatio,
                                      child: VideoPlayer(controller.activeController!),
                                    )
                                  : Image.network(
                                      feed.image,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            // Description + user
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: feed.userImage != null
                                        ? NetworkImage(feed.userImage!)
                                        : const AssetImage('assets/default_user.png')
                                            as ImageProvider,
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      feed.username,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text(feed.description),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
