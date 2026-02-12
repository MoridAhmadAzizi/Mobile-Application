import 'package:flutter/material.dart';

class ButtonSection extends StatelessWidget {
  const ButtonSection({this.isEditing = false, this.onReset, this.onSubmit, this.isPosting = false, super.key});
  final bool isEditing;
  final VoidCallback? onReset;
  final VoidCallback? onSubmit;
  final bool isPosting;

  @override
  Widget build(BuildContext context) {
    final isSaving = isPosting;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withAlpha(80), blurRadius: 10, offset: const Offset(0, -1)),
        ],
      ),
      child: isSaving
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onReset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('پاک کردن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isSaving) {
                        onSubmit?.call();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? 'آپدیت محصول' : 'افزودن محصول',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
