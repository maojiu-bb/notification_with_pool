class NotificationContent {
  final String title;
  final String body;
  final String? image;

  const NotificationContent({
    required this.title,
    required this.body,
    this.image,
  });

  factory NotificationContent.fromJson(Map<String, dynamic> json) {
    return NotificationContent(
      title: json['title'],
      body: json['body'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'image': image,
    };
  }
}
