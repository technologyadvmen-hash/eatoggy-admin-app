class CategoryFoodItem {
  const CategoryFoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isVeg,
    required this.isAvailable,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String price;
  final bool isVeg;
  final bool isAvailable;
  final String imageAsset;

  CategoryFoodItem copyWith({
    String? id,
    String? name,
    String? price,
    bool? isVeg,
    bool? isAvailable,
    String? imageAsset,
  }) {
    return CategoryFoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}

class CategoryItemsModel {
  const CategoryItemsModel({
    required this.categoryId,
    required this.categoryName,
    required this.itemsCountSubtitle,
    required this.allOnlineStatus,
    required this.items,
  });

  final String categoryId;
  final String categoryName;
  final String itemsCountSubtitle;
  final bool allOnlineStatus;
  final List<CategoryFoodItem> items;

  static const dummy = CategoryItemsModel(
    categoryId: '1',
    categoryName: 'Category Items',
    itemsCountSubtitle: '0 Items available',
    allOnlineStatus: false,
    items: [],
  );
}
