class Feed {
  final String id;
  final String description;
  final String image;
  final String video;
  final String username;
  final String? userImage;
  final bool follow;

  Feed({
    required this.id,
    required this.description,
    required this.image,
    required this.video,
    required this.username,
    required this.userImage,
    required this.follow,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return Feed(
      id: json['id'].toString(),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      video: json['video'] ?? '',
      username: user['name'] ?? '',
      userImage: user['image'],
      follow: json['follow'] ?? false,
    );
  }
}
