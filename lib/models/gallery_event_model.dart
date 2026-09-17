class EventModel {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;
  final String imagePath;
  final String category; // 'Memorial', 'Welfare Drive', 'Education Aid', 'Healthcare'

  const EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.imagePath,
    required this.category,
  });
}

class GalleryItem {
  final String id;
  final String title;
  final String imagePath;
  final String tag;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.tag,
  });
}
