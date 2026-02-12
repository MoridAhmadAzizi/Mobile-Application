import 'package:objectbox/objectbox.dart';

enum EventType {
  kids('نونهالان', 0),
  teens('نوجوانان', 1);

  const EventType(
    this.name,
    this.type,
  );
  final String name;
  final int type;
  static bool isForKids(int type) => type == EventType.kids.type;
  static bool isForTeens(int type) => type == EventType.teens.type;
}

@Entity()
class EventModel {
  @Id(assignable: true)
  int id;

  final String title;

  final int type;

  /// `description` column in Supabase.
  final String desc;

  /// `tools` column in Supabase.
  final List<String> tools;

  /// Public URLs (online) or local file paths (offline drafts).
  /// In Supabase the column is `image_paths`.
  final List<String> imagePaths;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventModel({
    this.id = 0,
    this.title = '',
    this.type = 0,
    this.desc = '',
    this.tools = const [],
    this.imagePaths = const [],
    this.createdAt,
    this.updatedAt,
  });
  static EventModel get empty => EventModel();
  EventModel copyWith({
    int? id,
    String? title,
    String? group,
    String? desc,
    int? type,
    List<String>? tools,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      desc: desc ?? this.desc,
      tools: tools ?? this.tools,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  /// Map from Supabase row -> Product.
  factory EventModel.formJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: (json['title'] ?? '').toString(),
      type: (json['type'] ?? 0) as int,
      desc: (json['description'] ?? '').toString(),
      tools: List<String>.from(json['tools'] ?? const <String>[]),
      imagePaths: List<String>.from(json['image_paths'] ?? const <String>[]),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Map for Supabase insert/update.
  /// NOTE: do NOT send owner_id; triggers set/lock it.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': desc,
      'type': type,
      'tools': tools,
      'image_paths': imagePaths,
    };
  }
}
