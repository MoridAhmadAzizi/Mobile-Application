import 'dart:io';

import 'package:events/features/add_new_event/cubit/add_event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget(this.imagePaths, {super.key});
  final List<String> imagePaths;

  bool _isRemote(String s) => s.startsWith('http://') || s.startsWith('https://');

  Widget _buildImageThumb(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }

    if (_isRemote(path)) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    final normalized = path.startsWith('file://') ? path.replaceFirst('file://', '') : path;

    if (!File(normalized).existsSync()) {
      return const Icon(Icons.broken_image);
    }

    return Image.file(
      File(normalized),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addEventCubit = context.read<AddEventCubit>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'عکس ها',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const Spacer(),
              Text('${imagePaths.length}/10', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: (imagePaths.length >= 10) ? null : addEventCubit.pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18, color: Colors.white),
                label: Text(imagePaths.isEmpty ? 'انتخاب' : 'افزودن', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (imagePaths.isEmpty)
            GestureDetector(
              onTap: addEventCubit.pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 42, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('حد مجاز برای انتخاب عکس الی 10 عدد.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 0),
                itemBuilder: (context, index) {
                  final path = imagePaths[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Colors.grey.shade100,
                              child: SizedBox.expand(child: _buildImageThumb(path)),
                            ),
                          ),
                          Positioned(
                            top: -10,
                            right: -10,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => addEventCubit.removeImageFroList(index),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.black.withAlpha(150), shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
