import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frijo_noviindus_app/features/feed/presentation/feed_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


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
    if (picked != null) {
      controller.setVideo(File(picked.path));
    }
  }

  Future<void> pickImage(FeedController controller) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      controller.setImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FeedController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Add Feed'),
        backgroundColor: const Color(0xFF0F0F0F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter description...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => pickImage(controller),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    image: controller.imageFile != null
                        ? DecorationImage(
                            image: FileImage(controller.imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.imageFile == null
                      ? const Center(
                          child: Text('Tap to pick thumbnail image',
                              style: TextStyle(color: Colors.white54)))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => pickVideo(controller),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: controller.videoFile == null
                      ? const Center(
                          child: Text('Tap to pick video (MP4 < 5 mins)',
                              style: TextStyle(color: Colors.white54)))
                      : Center(
                          child: Text(
                            'Video selected: ${controller.videoFile!.path.split('/').last}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload progress
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
                    const SizedBox(height: 16),
                  ],
                ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isUploading
                    ? null
                    : () {
                        controller.uploadFeed(
                          desc: _descController.text.trim(),
                          categories: selectedCategories,
                          context: context,
                        );
                      },
                child: const Text(
                  'Upload Feed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
