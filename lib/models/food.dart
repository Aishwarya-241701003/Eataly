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
  final String? canteen;
  // Intelligent features
  final int remainingCount;
  final String nextBatchTime;
  final bool isTrending;
  final int salesCount;

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
    this.canteen,
    this.remainingCount = 12,
    this.nextBatchTime = 'Ready in 8 mins',
    this.isTrending = false,
    this.salesCount = 24,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Meals',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      image: map['image'] ?? '',
      available: map['available'] ?? true,
      isVeg: map['isVeg'] ?? true,
      isPopular: map['isPopular'] ?? false,
      isNew: map['isNew'] ?? false,
      preparationTime: map['preparationTime'] ?? 10,
      canteen: map['canteen'],
      remainingCount: map['remainingCount'] ?? 12,
      nextBatchTime: map['nextBatchTime'] ?? 'Ready in 8 mins',
      isTrending: map['isTrending'] ?? false,
      salesCount: map['salesCount'] ?? 24,
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
      if (canteen != null) 'canteen': canteen,
      'remainingCount': remainingCount,
      'nextBatchTime': nextBatchTime,
      'isTrending': isTrending,
      'salesCount': salesCount,
    };
  }

  Food copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    double? rating,
    String? image,
    bool? available,
    bool? isVeg,
    bool? isPopular,
    bool? isNew,
    int? preparationTime,
    String? canteen,
    int? remainingCount,
    String? nextBatchTime,
    bool? isTrending,
    int? salesCount,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      available: available ?? this.available,
      isVeg: isVeg ?? this.isVeg,
      isPopular: isPopular ?? this.isPopular,
      isNew: isNew ?? this.isNew,
      preparationTime: preparationTime ?? this.preparationTime,
      canteen: canteen ?? this.canteen,
      remainingCount: remainingCount ?? this.remainingCount,
      nextBatchTime: nextBatchTime ?? this.nextBatchTime,
      isTrending: isTrending ?? this.isTrending,
      salesCount: salesCount ?? this.salesCount,
    );
  }
}
