import 'package:objectbox/objectbox.dart';

@Entity()
class EventModel {
  /// DB id (uuid). For offline drafts, we use ids like `local_<millis>_<rand>`.
  @Id()
  int id;

  final String title;

  /// `group` column in Supabase (quoted in SQL).
  final String group;

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
    required this.title,
    required this.group,
    required this.desc,
    required this.tools,
    required this.imagePaths,
    this.createdAt,
    this.updatedAt,
  });

  EventModel copyWith({
    int? id,
    String? title,
    String? group,
    String? desc,
    List<String>? tools,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      group: group ?? this.group,
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
  factory EventModel.fromDb(Map<String, dynamic> row) {
    return EventModel(
      id: row['id'],
      title: (row['title'] ?? '').toString(),
      group: (row['group'] ?? '').toString(),
      desc: (row['description'] ?? '').toString(),
      tools: List<String>.from(row['tools'] ?? const <String>[]),
      imagePaths: List<String>.from(row['image_paths'] ?? const <String>[]),
      createdAt: _parseDate(row['created_at']),
      updatedAt: _parseDate(row['updated_at']),
    );
  }

  /// Map for Supabase insert/update.
  /// NOTE: do NOT send owner_id; triggers set/lock it.
  Map<String, dynamic> toDb() {
    return {
      'title': title,
      'description': desc,
      'group': group,
      'tools': tools,
      'image_paths': imagePaths,
    };
  }
}
