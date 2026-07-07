/// نماذج البيانات — تطابق مفاتيح JSON القادمة من الباك-إند (Go).
library;

class Paper {
  final int id;
  final String title;
  final String authors;
  final String abs;
  final String journal;
  final String url;
  final String region; // saudi | arab | global
  final String topic; // clinical | genetic | treatment | diagnosis
  final String type; // sts | rms | bone
  final int year;

  Paper({
    required this.id,
    required this.title,
    required this.authors,
    required this.abs,
    required this.journal,
    required this.url,
    required this.region,
    required this.topic,
    required this.type,
    required this.year,
  });

  factory Paper.fromJson(Map<String, dynamic> j) => Paper(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        authors: j['authors'] ?? '',
        abs: j['abs'] ?? '',
        journal: j['journal'] ?? '',
        url: j['url'] ?? '',
        region: j['region'] ?? '',
        topic: j['topic'] ?? '',
        type: j['type'] ?? '',
        year: j['year'] ?? 0,
      );
}

class SarcomaType {
  final int id;
  final String category; // soft | bone | child
  final String tag;
  final String name; // h
  final String description; // p

  SarcomaType({
    required this.id,
    required this.category,
    required this.tag,
    required this.name,
    required this.description,
  });

  factory SarcomaType.fromJson(Map<String, dynamic> j) => SarcomaType(
        id: j['id'] ?? 0,
        category: j['category'] ?? '',
        tag: j['tag'] ?? '',
        name: j['h'] ?? '',
        description: j['p'] ?? '',
      );
}

class Story {
  final int id;
  final String initial;
  final String body;
  final String who;

  Story({
    required this.id,
    required this.initial,
    required this.body,
    required this.who,
  });

  factory Story.fromJson(Map<String, dynamic> j) => Story(
        id: j['id'] ?? 0,
        initial: j['initial'] ?? '؟',
        body: j['body'] ?? '',
        who: j['who'] ?? '',
      );
}
