import 'package:flutter/material.dart';

class CanteenMenu extends StatelessWidget {
  final String canteenName;

  const CanteenMenu({
    super.key,
    required this.canteenName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          canteenName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip('All'),
                  _categoryChip('Meals'),
                  _categoryChip('Snacks'),
                  _categoryChip('Pizza'),
                  _categoryChip('Drinks'),
                  _categoryChip('Desserts'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Recommended',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _foodCard(
              name: 'Chicken Rice',
              price: '₹120',
              rating: '4.6',
              available: true,
              imageUrl:
                  'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
            ),

            _foodCard(
              name: 'Paneer Pizza',
              price: '₹150',
              rating: '4.5',
              available: true,
              imageUrl:
                  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
            ),

            _foodCard(
              name: 'Fresh Lime Juice',
              price: '₹60',
              rating: '4.4',
              available: true,
              imageUrl:
                  'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800',
            ),

            _foodCard(
              name: 'Veg Sandwich',
              price: '₹80',
              rating: '4.3',
              available: false,
              imageUrl:
                  'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800',
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Cart'),
      ),
    );
  }

  Widget _categoryChip(String name) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(name),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
      ),
    );
  }

  Widget _foodCard({
    required String name,
    required String price,
    required String rating,
    required bool available,
    required String imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Food image
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 60,
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(rating),

                    const SizedBox(width: 14),

                    Text(
                      available
                          ? 'Available'
                          : 'Unavailable',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: available
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: available ? () {} : null,
                    icon: const Icon(
                      Icons.add_shopping_cart,
                    ),
                    label: Text(
                      available
                          ? 'Add to cart'
                          : 'Unavailable',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}