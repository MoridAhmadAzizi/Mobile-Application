import 'dart:typed_data';

import 'package:objectbox/objectbox.dart';

/// ذخیره‌ی باینری عکس برای حالت آفلاین.
///
/// - `key` می‌تواند URL آنلاین (https://...) یا مسیر محلی (file path) باشد.
/// - `bytes` فایل فشرده‌شده‌ی تصویر
@Entity()
class ProductImageEntity {
  @Id()
  int obId;

  @Index()
  String key;

  Uint8List bytes;

  ProductImageEntity({
    this.obId = 0,
    required this.key,
    required this.bytes,
  });
}
