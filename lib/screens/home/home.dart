import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, String>> _allProducts = [
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number one',
      'group': 'Group A'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number two',
      'group': 'Group A'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number three',
      'group': 'Group A'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number four',
      'group': 'Group A'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number five',
      'group': 'Group A'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number six',
      'group': 'Group A'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number seven',
      'group': 'Group B'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number eight',
      'group': 'Group B'
    },
    {
      'image': 'assets/images/bg1.png',
      'title': 'Product Number nine',
      'group': 'Group B'
    },
  ];

  List<Map<String, String>> _filteredProducts = [];

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
  }

  void _searchProducts(String query) {
    setState(() {
      _searchText = query;

      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final title = product['title']!.toLowerCase();
          final group = product['group']!.toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) || group.contains(searchQuery);
        }).toList();
      }
    });
  }

  List<Map<String, String>> _getProductsByTab(int tabIndex) {
    if (_searchText.isNotEmpty) {
      return _filteredProducts.where((product) {
        if (tabIndex == 0) return product['group'] == 'Group A';
        if (tabIndex == 1) return product['group'] == 'Group B';
        return true;
      }).toList();
    } else {
      if (tabIndex == 0) {
        return _allProducts.where((p) => p['group'] == 'Group A').toList();
      } else if (tabIndex == 1) {
        return _allProducts.where((p) => p['group'] == 'Group B').toList();
      } else {
        return _allProducts; 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue[500],
          title: const Text('Application Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          centerTitle: true,
        ),
        drawer: const NavigationDrawer(),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 228, 243, 255),
                borderRadius: BorderRadius.circular(10.0),
                border: BoxBorder.all(
                  color: Colors.blue[100]!,
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
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy,",
                    style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600),
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
                placeholder: 'Search...',
                placeholderStyle: TextStyle(
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
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add New',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(0),
                  _buildTabContent(1),
                  _buildTabContent(2),
                ],
              ),
            ),

            TabBar(
            tabs: [
                Tab(text: 'Group A'),
                Tab(text: 'Group B'),
                Tab(text: 'All'),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.blue[300]!,
              indicatorWeight: 4,


            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final products = _getProductsByTab(tabIndex);

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
              '"$_searchText" not found',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Try different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: products.map((product) {
          return _ImageCard(
            product['image']!,
            product['title']!,
            product['group']!,
          );
        }).toList(),
      ),
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  @override
  Widget build(BuildContext context) => Drawer(        
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child:
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeaderItems(context),
              buildMenuItems(context)
            ],
          ),
        ),
      );
}

Widget buildHeaderItems(BuildContext context) => SafeArea(
      child: Container(
        color: Colors.blue,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: const Column(
          children: [
            SizedBox(height: 10),
            CircleAvatar(
              radius: 52,
              backgroundImage: AssetImage('assets/images/bg1.png'),
            ),
            SizedBox(height: 6),
            Text(
              'Morid Ahmad Azizi',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            Text(
              'moridahmad.876@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.white),
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
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log out', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );

Widget _ImageCard(String imagePath, String title, String description) {
  return Container(
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
                child: Image.asset(
                  imagePath,
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
  );
}
