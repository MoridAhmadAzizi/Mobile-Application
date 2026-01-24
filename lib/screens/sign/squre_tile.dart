import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SqureTile extends StatelessWidget {
  final Logo icon;
  final Function()? onTap;
  final String text;
  const SqureTile(
      {super.key, required this.icon, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        padding:const  EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(7),
          color: Colors.grey[100],
        ),
        child: Row(
          children: [
            icon,
           const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
