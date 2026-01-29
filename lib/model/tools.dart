import 'package:flutter/material.dart';

class CardProduct extends StatelessWidget {
  final String title;

  const CardProduct({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60, maxWidth: 200),
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(7),
          
          
          ),
          
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
