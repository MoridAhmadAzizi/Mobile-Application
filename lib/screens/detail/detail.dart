import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:wahab/data/product_data.dart';
import 'package:wahab/model/product.dart';
import 'package:wahab/model/tools.dart';
import 'package:go_router/go_router.dart';
import 'package:wahab/services/product_repo.dart';
import 'dart:io';
import 'package:get/get.dart';

class Detail extends StatefulWidget {
  final Product product;
  const Detail({super.key, required this.product});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late Product _product;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    if (_product.imageURL.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_pageController.hasClients && _product.imageURL.isNotEmpty) {
        if (_currentPage < _product.imageURL.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(0);
        }
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = _product.imageURL.isNotEmpty
        ? _product.imageURL
        : ['assets/images/placeholder.png'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'توضیحات محصول',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey[500],
          elevation: 0),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Slider
              Container(
                width: MediaQuery.of(context).size.width,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final imagePath = images[index];
                          final isAsset = imagePath.startsWith('assets/');
                          return isAsset
                              ? Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                );
                        },
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white.withAlpha(70),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Text(
                _product.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _product.group,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'توضیحات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                child: Text(
                  _product.desc,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'ابزارات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              if (_product.tool.isNotEmpty)
                SizedBox(
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 12,
                    children: _product.tool.map((tool) {
                      return CardProduct(title: tool);
                    }).toList(),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No tools specified',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                final online = ProductRepo.instance.isOnline.value;

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (!online) {
                      ProductRepo.instance.showOfflineMassage();
                      return;
                    }

                    final result = await context.push('/add',
                        extra: _product); 
                    if (result == 'updated') {
                      setState(() {
                        try {
                          _product =
                              products.firstWhere((p) => p.id == _product.id);
                        } catch (_) {}
                      });
                      if (mounted) {
                        context.pop('updated_from_detail');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.edit, color: Colors.white, size: 22),
                  label: Text(
                    online ? 'ویرایش محصول' : 'حالت خوانیش',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
