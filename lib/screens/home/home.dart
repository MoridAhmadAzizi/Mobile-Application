import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:wahab/services/product_repo.dart';
import 'dart:io';
import '../../model/product.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _searchText = '';

  void _searchProducts(String query) {
    setState(() {
      _searchText = query.trim();
    });
  }

  List<Product> _applySearch(List<Product> list) {
    if (_searchText.isEmpty) return list;

    final q = _searchText.toLowerCase();
    return list.where((product) {
      final title = product.title.toLowerCase();
      final group = product.group.toLowerCase();
      return title.contains(q) || group.contains(q);
    }).toList();
  }

  List<Product> _getProductsByTab(List<Product> list, int tabIndex) {
    final searched = _applySearch(list);

    if (tabIndex == 0) {
      return searched.where((p) => p.group == 'گروپ اول').toList();
    } else if (tabIndex == 1) {
      return searched.where((p) => p.group == 'گروپ دوم').toList();
    } else {
      return searched;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black87,
          title: const Text(
            'لیست محصولات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        drawer: const NavigationDrawer(),
        body: Column(
          children: [
            Container(
            
              margin: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
              decoration: BoxDecoration(

                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child:
               Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center
                (  child:
                   Text(
                    "این برنامه برای ثبت و ویرایش محصولات می باشد که معلومات به شکل محلی داخل سیستم ذخیره می شوند",
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CupertinoSearchTextField(
                onChanged: _searchProducts,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2.0,
                  ),
                ),
                placeholder: 'جستجو.....',
                placeholderStyle: TextStyle(
                  fontFamily: 'Vazirmatn',
                  color: Colors.grey.shade500,
                  fontSize: 18.0,
                ),
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: Colors.grey,
                  size: 30.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 14.0,
                ),
                autofocus: false,
                autocorrect: true,
              ),
            ),
            Obx(() {
              final online = ProductRepo.instance.isOnline.value;

              return ElevatedButton.icon(
                onPressed: () async {
                  if (!online) {
                    ProductRepo.instance.showOfflineMassage();
                    return;
                  }

                  final result = await context.push('/add');
                  if (result == 'added' || result == 'updated') {
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                
                icon:
                online ? 
                const Icon(Icons.add, size: 20) : 
                const Icon(Icons.book , size: 20),
                label: Text(
                  online ? 'اضافه کردن' : 'حالت خوانیش',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
              );
            }),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: ProductRepo.instance.watchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
            
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
            
                  final allProducts = snapshot.data ?? [];
            
                  return TabBarView(
                    children: [
                      _buildTabContent(0, allProducts),
                      _buildTabContent(1, allProducts),
                      _buildTabContent(2, allProducts),
                    ],
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(2),
              height: kToolbarHeight - 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TabBar(
                tabs: const [
                  Tab(text: 'گروپ اول'),
                  Tab(text: 'گروپ دوم'),
                  Tab(text: 'همه'),
                ],
                labelColor: Colors.white,
                indicatorColor: Colors.grey,
                labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.black87,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex, List<Product> allProducts) {
    final products = _getProductsByTab(allProducts, tabIndex);

    if (_searchText.isNotEmpty && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            Text(
              '"$_searchText"پیدا نشد',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'کلمه دیگری را امتحان کنید!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text(
          "پیدا نشد",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: products.map((product) {
          String imagePath;
          if (product.imageURL.isNotEmpty && product.imageURL[0].isNotEmpty) {
            imagePath = product.imageURL[0];
          } else {
            imagePath = 'assets/images/bg1.png';
          }

          bool isAsset = imagePath.startsWith('assets/');

          return _imageCard(
            imagePath: imagePath,
            isAsset: isAsset,
            title: product.title,
            description: product.group,
            product: product,
          );
        }).toList(),
      ),
    );
  }

  Widget _imageCard({
    required String imagePath,
    required bool isAsset,
    required String title,
    required String description,
    required Product product,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await context.push('/detail', extra: product);
        if (result == 'updated_from_detail') {
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: isAsset
                        ? Image.asset(
                            imagePath,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(imagePath),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_outlined, size: 25),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeaderItems(context, user),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }
}

Widget buildHeaderItems(BuildContext context, User? user) => SafeArea(
      child: Container(
        color: Colors.grey,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 52,
              backgroundImage: AssetImage('assets/images/bg1.png'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Morid Ahmad Azizi',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            Text(
              '${user?.email ?? ""}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );

Widget buildMenuItems(BuildContext context) => Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('پروفایل'),
            onTap: () {},
          ),
          const ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('خارج شدن', style: TextStyle(color: Colors.red)),
            onTap: signUserout,
          ),
        ],
      ),
    );

void signUserout() {
  FirebaseAuth.instance.signOut();
}
