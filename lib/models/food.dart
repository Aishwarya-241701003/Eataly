class Food {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double rating;
  final String image;
  final bool available;
  final bool isVeg;
  final bool isPopular;
  final bool isNew;
  final int preparationTime; // in minutes

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.image,
    required this.available,
    required this.isVeg,
    required this.isPopular,
    required this.isNew,
    required this.preparationTime,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      image: map['image'],
      available: map['available'],
      isVeg: map['isVeg'],
      isPopular: map['isPopular'],
      isNew: map['isNew'],
      preparationTime: map['preparationTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'rating': rating,
      'image': image,
      'available': available,
      'isVeg': isVeg,
      'isPopular': isPopular,
      'isNew': isNew,
      'preparationTime': preparationTime,
    };
  }
}
