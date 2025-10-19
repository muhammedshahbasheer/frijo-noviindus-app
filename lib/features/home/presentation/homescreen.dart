import 'package:flutter/material.dart';
import 'package:frijo_noviindus_app/features/home/model/feedmodel.dart';
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

  // ✅ Helper to get profile image or fallback
  ImageProvider<Object>? getProfileImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null; // Will show default icon instead
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),backgroundColor: Colors.red,
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F0F0F),
        title: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),

            const SizedBox(width: 10),

            // Greeting texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Hello Maria',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // prevents overflow
                  ),
                  Text(
                    'Welcome back to Section',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis, // prevents overflow
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // AppBar right profile icon
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async {
                await controller.fetchFeeds();
              },
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // 🔹 Category Chips
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
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

                  const SizedBox(height: 10),

                  // 🔹 Feed Cards
                  ...controller.feeds.map((feed) {
                    bool isPlaying =
                        controller.activeController != null &&
                        controller.activeController!.dataSource == feed.video;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Info
                          ListTile(
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: getProfileImage(feed.userImage),
                              child:
                                  feed.userImage == null ||
                                      feed.userImage!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : null,
                            ),
                            title: Text(
                              feed.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: const Text(
                              "5 days ago",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          // Video / Thumbnail
                          GestureDetector(
                            onTap: () => controller.playVideo(feed),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: isPlaying
                                      ? AspectRatio(
                                          aspectRatio: controller
                                              .activeController!
                                              .value
                                              .aspectRatio,
                                          child: VideoPlayer(
                                            controller.activeController!,
                                          ),
                                        )
                                      : Image.network(
                                          feed.image,
                                          height: 240,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 45,
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
                              feed.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
