import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel eventModel;
  const EventDetailScreen({super.key, required this.eventModel});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final PageController _pageCtrl;
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  bool _isUserInteracting = false;

  final _slideDuration = const Duration(seconds: 4);
  final _animationDuration = const Duration(milliseconds: 550);

  bool _isRemote(String s) => s.startsWith('http://') || s.startsWith('https://');

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController(
      viewportFraction: 1.0,
      keepPage: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();

    final images = widget.eventModel.imagePaths;
    if (images.length <= 1) return;

    _autoSlideTimer = Timer.periodic(_slideDuration, (_) {
      if (!_pageCtrl.hasClients || !mounted) return;
      if (_isUserInteracting) return;

      final next = (_currentPage + 1) % images.length;
      _pageCtrl.animateToPage(
        next,
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseAutoSlide() {
    _isUserInteracting = true;
    _autoSlideTimer?.cancel();
  }

  void _resumeAutoSlide() {
    _isUserInteracting = false;
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  String getEventType(int type) {
    if (EventType.isForKids(type)) {
      return EventType.kids.name;
    }
    return EventType.teens.name;
  }

  @override
  Widget build(BuildContext context) {
    // final pc = Get.find<EventController>();

    final created = widget.eventModel.createdAt;
    final updated = widget.eventModel.updatedAt;
    final showEdited = updated != null && (created == null || updated.isAfter(created));

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات برنامه'),
        actions: const [Icon(Icons.edit_rounded)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImageSlider(),
          const SizedBox(height: 12),
          Text(
            widget.eventModel.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _chip(context, 'بخش: ${getEventType(widget.eventModel.type)}'),
              const SizedBox(height: 7),
              // if (created != null) _chip(context, 'ایجاد: ${DateUtilsFa.dateYmd(created)} - ${DateUtilsFa.timeHm(created)}'),
              if (showEdited) ...[
                const SizedBox(height: 7),
                // _chip(context, 'آخرین ویرایش: ${DateUtilsFa.dateYmd(updated)} - ${DateUtilsFa.timeHm(updated)}'),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text('توضحیات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (widget.eventModel.desc.isEmpty)
            Center(child: _chip(context, 'توضیحاتی درباره این محصول وجود ندارد!'))
          else
            Text(widget.eventModel.desc, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 18),
          Text('ابزارها', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final text in widget.eventModel.tools) _chip(context, text),
              if (widget.eventModel.tools.isEmpty) Center(child: _chip(context, 'هیچ کدام ابزاری هنوز اضافه نشده!')),
            ],
          ),
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
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          )),
    );
  }

  Widget _buildImageSlider() {
    final images = widget.eventModel.imagePaths;

    if (images.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: Icon(Icons.image, color: Colors.red, size: 60)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              // ✅ وقتی کاربر اسکرول می‌کند، اتو-اسلاید را موقتاً قطع کن
              if (n is ScrollStartNotification) _pauseAutoSlide();
              if (n is ScrollEndNotification) _resumeAutoSlide();
              return false;
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                // controller: _pageCtrl,
                itemCount: images.length,
                onPageChanged: (index) {
                  if (!mounted) return;
                  setState(() => _currentPage = index);
                },
                itemBuilder: (_, index) {
                  return _ImageItem(
                    key: ValueKey(images[index]), // ✅ key پایدار
                    imagePath: images[index],
                    isRemote: _isRemote,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(images.length),
      ],
    );
  }

  Widget _buildPageIndicator(int length) {
    if (length <= 1) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

class _ImageItem extends StatelessWidget {
  const _ImageItem({
    super.key,
    required this.imagePath,
    required this.isRemote,
  });

  final String imagePath;
  final bool Function(String) isRemote;

  @override
  Widget build(BuildContext context) {
    // ✅ gaplessPlayback جلو چشمک هنگام تغییر تصویر را می‌گیرد
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      );
    }

    if (isRemote(imagePath)) {
      // final cached = pc.cachedBytes(imagePath);
      // if (cached != null) {
      //   return Image.memory(
      //     cached,
      //     fit: BoxFit.cover,
      //     width: double.infinity,
      //     height: double.infinity,
      //     gaplessPlayback: true,
      //   );
      // }
      return CachedNetworkImage(
        imageUrl: imagePath,
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
      );
      // return Image.network(
      //   imagePath,
      //   fit: BoxFit.cover,
      //   width: double.infinity,
      //   height: double.infinity,
      //   gaplessPlayback: true,
      //   loadingBuilder: (context, child, progress) {
      //     if (progress == null) return child;
      //     return _loading();
      //   },
      //   errorBuilder: (_, __, ___) => _error(),
      // );
    }

    final normalized = imagePath.startsWith('file://') ? imagePath.replaceFirst('file://', '') : imagePath;
    final file = File(normalized);

    // if (!file.existsSync()) {
    //   final cached = pc.cachedBytes(imagePath);
    //   if (cached != null) {
    //     return Image.memory(
    //       cached,
    //       fit: BoxFit.cover,
    //       width: double.infinity,
    //       height: double.infinity,
    //       gaplessPlayback: true,
    //     );
    //   }
    //   return _error();
    // }

    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _error(),
    );
  }

  Widget _error() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
    );
  }
}
