class MemorialHero {
  final String id;
  final String name;
  final String rank;
  final String regiment;
  final String warOrOperation;
  final String dateOfMartyrdom;
  final String nativePlace;
  final String gallantryAward;
  final String citation;
  final String photoUrl;
  int tributesCount;

  MemorialHero({
    required this.id,
    required this.name,
    required this.rank,
    required this.regiment,
    required this.warOrOperation,
    required this.dateOfMartyrdom,
    required this.nativePlace,
    required this.gallantryAward,
    required this.citation,
    required this.photoUrl,
    this.tributesCount = 1250,
  });
}

class HeroTributeMessage {
  final String id;
  final String heroId;
  final String heroName;
  final String authorName;
  final String city;
  final String message;
  final DateTime timestamp;

  HeroTributeMessage({
    required this.id,
    required this.heroId,
    required this.heroName,
    required this.authorName,
    required this.city,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
