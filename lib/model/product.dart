class Product {
  final String id;
  final String title;
  final String group;
  final String desc;
  final List<String> tool;
  final List<String> imageURL;

  Product(
      {required this.id,
      required this.title,
      required this.group,
      required this.desc,
      required this.tool,
      required this.imageURL});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        group: map['group'] ?? '',
        desc: map['desc'] ?? '',
        tool: List<String>.from(map['tool']) ?? [],
        imageURL: List<String>.from(map['imageURL']) ?? []);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'group': group,
      'desc': desc,
      'tool': tool,
      'imageURL': imageURL,
    };
  }
}
