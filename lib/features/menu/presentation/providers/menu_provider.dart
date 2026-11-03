import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuItemModel {
  const MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.isAvailable,
    required this.isVeg,
    this.prepTime = '15',
  });

  final String id;
  final String name;
  final String category;
  final String price;
  final String description;
  final bool isAvailable;
  final bool isVeg;
  final String prepTime;

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? price,
    String? description,
    bool? isAvailable,
    bool? isVeg,
    String? prepTime,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      isVeg: isVeg ?? this.isVeg,
      prepTime: prepTime ?? this.prepTime,
    );
  }
}

class MenuNotifier extends Notifier<List<MenuItemModel>> {
  @override
  List<MenuItemModel> build() {
    return const [];
  }

  void toggleAvailability(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(isAvailable: !item.isAvailable)
        else
          item,
    ];
  }

  void addMenuItem(MenuItemModel item) {
    state = [item, ...state];
  }

  void updateMenuItem(MenuItemModel updatedItem) {
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item,
    ];
  }
}

final menuProvider = NotifierProvider<MenuNotifier, List<MenuItemModel>>(
  MenuNotifier.new,
);

class MenuCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) => state = category;
}

final menuCategoryFilterProvider =
    NotifierProvider<MenuCategoryFilterNotifier, String>(
  MenuCategoryFilterNotifier.new,
);

class MenuVegFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void reset() => state = false;
}

final menuVegFilterProvider =
    NotifierProvider<MenuVegFilterNotifier, bool>(
  MenuVegFilterNotifier.new,
);

class MenuSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final menuSearchQueryProvider =
    NotifierProvider<MenuSearchQueryNotifier, String>(
  MenuSearchQueryNotifier.new,
);

final filteredMenuItemsProvider = Provider<List<MenuItemModel>>((ref) {
  final items = ref.watch(menuProvider);
  final category = ref.watch(menuCategoryFilterProvider);
  final onlyVeg = ref.watch(menuVegFilterProvider);
  final search = ref.watch(menuSearchQueryProvider).toLowerCase().trim();

  return items.where((item) {
    if (category != 'All' && item.category != category) {
      return false;
    }
    if (onlyVeg && !item.isVeg) {
      return false;
    }
    if (search.isNotEmpty) {
      final name = item.name.toLowerCase();
      final desc = item.description.toLowerCase();
      return name.contains(search) || desc.contains(search);
    }
    return true;
  }).toList();
});
