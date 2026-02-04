// lib/screens/detail.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';
import '../model/product.dart';
import '../utils/date_utils.dart';
import 'add.dart';

class Detail extends StatefulWidget {
  final Product product;
  const Detail({super.key, required this.product});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final PageController _pageCtrl = PageController();
  Timer? _timer;
  int _page = 0;

  bool _isRemote(String s) => s.startsWith('http://') || s.startsWith('https://');

  void _showOfflineMsg() {
    Get.snackbar(
      'آفلاین هستید',
      'شما افلاین هستید ، اتصال خود را بررسی کنید',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();

    // ✅ اتومات هر 3 ثانیه
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final images = widget.product.imagePaths;
      if (images.length <= 1) return;

      _page = (_page + 1) % images.length;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          _page,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProductController>();

    final created = widget.product.createdAt;
    final updated = widget.product.updatedAt;
    final showEdited = updated != null && (created == null || updated.isAfter(created));

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات محصول'),
        actions: [
          // ✅ وقتی آفلاین هستیم، قلم نمایش داده نمی‌شود
          Obx(() {
            final online = pc.isOnline.value;
            if (!online) return const SizedBox.shrink();

            return IconButton(
              onPressed: () => Get.to(() => Add(initialProduct: widget.product)),
              icon: const Icon(Icons.edit),
            );
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImages(context, pc),
          const SizedBox(height: 12),
          Text(
            widget.product.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
          _chip(context, 'گروه: ${widget.product.group}'),
          if (created != null) _chip(context, 'ایجاد: ${DateUtilsFa.dateYmd(created)} - ${DateUtilsFa.timeHm(created)}'),
          if (showEdited) _chip(context, 'آخرین ویرایش: ${DateUtilsFa.dateYmd(updated)} - ${DateUtilsFa.timeHm(updated)}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.product.desc, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 18),
          Text('ابزارها', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final t in widget.product.tools) _chip(context, t),
              if (widget.product.tools.isEmpty) _chip(context, '—'),
            ],
          ),

          Obx(() => pc.isOnline.value ? const SizedBox() : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('شما افلاین هستید ، اتصال خود را بررسی کنید', style: TextStyle(color: Colors.red)),
          )),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildImages(BuildContext context, ProductController pc) {
    final images = widget.product.imagePaths;

    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: Icon(Icons.image, size: 60)),
      );
    }

    Widget buildOne(String src) {
      if (src.startsWith('assets/')) {
        return Image.asset(src, fit: BoxFit.cover);
      }

      if (_isRemote(src)) {
        final cached = pc.cachedBytes(src);
        if (cached != null) return Image.memory(cached, fit: BoxFit.cover);
        return Image.network(src, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
      }

      final normalized = src.startsWith('file://') ? src.replaceFirst('file://', '') : src;

      if (!File(normalized).existsSync()) {
        final cached = pc.cachedBytes(src);
        if (cached != null) return Image.memory(cached, fit: BoxFit.cover);
        return const Icon(Icons.broken_image);
      }

      return Image.file(File(normalized), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final src = images[i];
                return Container(
                  color: Colors.grey.shade100,
                  child: buildOne(src),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? Colors.grey.shade900 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
