import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import 'package:wahab/model/product.dart' as m;

import 'product_image_entity.dart';

@Entity()
class ProductEntity {
  @Id()
  int obId;

  @Unique()
  String id;

  String title;
  String group;
  String description;

  String toolsJson;
  String imagePathsJson;

  int? createdAtMs;
  int? updatedAtMs;

  bool isDirty;

  final ToMany<ProductImageEntity> images = ToMany<ProductImageEntity>();

  ProductEntity({
    this.obId = 0,
    required this.id,
    required this.title,
    required this.group,
    required this.description,
    this.toolsJson = '[]',
    this.imagePathsJson = '[]',
    this.createdAtMs,
    this.updatedAtMs,
    this.isDirty = false,
  });

  List<String> get tools {
    try {
      final v = jsonDecode(toolsJson);
      return (v as List).map((e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  set tools(List<String> v) => toolsJson = jsonEncode(v);

  List<String> get imagePaths {
    try {
      final v = jsonDecode(imagePathsJson);
      return (v as List).map((e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  set imagePaths(List<String> v) => imagePathsJson = jsonEncode(v);

  // ✅ اینجا فیلدهای درست Product استفاده می‌شود: tools / imagePaths
  factory ProductEntity.fromProduct(m.Product p, {bool isDirty = false}) {
    final e = ProductEntity(
      id: p.id,
      title: p.title,
      group: p.group,
      description: p.desc,
      createdAtMs: p.createdAt?.millisecondsSinceEpoch,
      updatedAtMs: p.updatedAt?.millisecondsSinceEpoch,
      isDirty: isDirty,
    );

    e.tools = p.tools;               // ✅ درست
    e.imagePaths = p.imagePaths;     // ✅ درست
    return e;
  }

  // ✅ اینجا هم پارامترهای درست کانستراکتور Product: tools / imagePaths
  m.Product toProduct() {
    return m.Product(
      id: id,
      title: title,
      group: group,
      desc: description,
      tools: tools,                 // ✅ درست
      imagePaths: imagePaths,       // ✅ درست
      createdAt: createdAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(createdAtMs!),
      updatedAt: updatedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(updatedAtMs!),
    );
  }
}
