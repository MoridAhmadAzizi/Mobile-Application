import 'package:objectbox/objectbox.dart';
import 'package:wahab/model/product.dart';

@Entity()
class ProductEntity {
  @Id()
  int obId;

  @Unique()
  String firebaseId;

  String title;
  String group;
  String desc;

  List<String> tool;
  List<String> imageURL;

  ProductEntity({
    this.obId = 0,
    required this.firebaseId,
    required this.title,
    required this.group,
    required this.desc,
    required this.tool,
    required this.imageURL,
  });

  factory ProductEntity.fromProduct(Product p) => ProductEntity(
        firebaseId: p.id,
        title: p.title,
        group: p.group,
        desc: p.desc,
        tool: p.tool,
        imageURL: p.imageURL,
      );

  Product toProduct() => Product(
        id: firebaseId,
        title: title,
        group: group,
        desc: desc,
        tool: tool,
        imageURL: imageURL,
      );
}
