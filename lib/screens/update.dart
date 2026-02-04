import 'package:flutter/material.dart';
import '../model/product.dart';
import 'add.dart';

class Update extends StatelessWidget {
  final Product product;
  const Update({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Add(initialProduct: product);
  }
}
