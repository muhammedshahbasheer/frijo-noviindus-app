import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'feed_controller.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

  @override
  State<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  final _descController = TextEditingController();
  final picker = ImagePicker();
  List<int> selectedCategories = [];

  Future<void> pickVideo(FeedController controller) async {
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) controller.setVideo(File(picked.path));
  }

  Future<void> pickImage(FeedController controller) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) controller.setImage(File(picked.path));
  }

  bool allFieldsFilled(FeedController controller) {
    return _descController.text.trim().isNotEmpty &&
        controller.imageFile != null &&
        controller.videoFile != null &&
        selectedCategories.isNotEmpty &&
        !controller.isUploading;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FeedController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                        ),
                        const Text(
                          "Add Feeds",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: allFieldsFilled(controller)
                          ? () {
                              controller.uploadFeed(
                                desc: _descController.text.trim(),
                                categories: selectedCategories,
                                context: context,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Share Post",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Video Picker
                GestureDetector(
                  onTap: () => pickVideo(controller),
                  child: DottedContainer(
                    height: 160,
                    child: controller.videoFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload_rounded,
                                  color: Colors.white54, size: 36),
                              SizedBox(height: 8),
                              Text(
                                "Select a video from Gallery",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              "Selected: ${controller.videoFile!.path.split('/').last}",
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Thumbnail Picker
                GestureDetector(
                  onTap: () => pickImage(controller),
                  child: DottedContainer(
                    height: 150,
                    child: controller.imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.image_outlined,
                                  color: Colors.white54, size: 36),
                              SizedBox(height: 8),
                              Text(
                                "Add a Thumbnail",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              controller.imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Description Field
                const Text(
                  "Add Description",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type something...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 25),

                // 🔹 Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Categories This Project",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: List.generate(6, (index) {
                    final categoryId = 23 + index;
                    final isSelected =
                        selectedCategories.contains(categoryId);
                    return ChoiceChip(
                      label: Text(
                        ["Physics", "AI", "Mathematics", "Chemistry", "Biology", "Data Science"][index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey[800],
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(categoryId);
                          } else {
                            selectedCategories.remove(categoryId);
                          }
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // 🔹 Upload Progress
                if (controller.isUploading)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: controller.uploadProgress,
                        color: Colors.redAccent,
                        backgroundColor: Colors.grey[800],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading ${(controller.uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🧩 Reusable Dashed Container Widget
class DottedContainer extends StatelessWidget {
  final double height;
  final Widget child;

  const DottedContainer({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
