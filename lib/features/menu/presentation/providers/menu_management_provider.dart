import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/menu_management_model.dart';
import '../../data/repositories/menu_repository.dart';

class MenuManagementState {
  const MenuManagementState({
    required this.model,
    this.searchQuery = '',
    this.isLoading = false,
  });

  final MenuManagementModel model;
  final String searchQuery;
  final bool isLoading;

  List<MenuCategoryItem> get filteredCategories {
    if (searchQuery.trim().isEmpty) {
      return model.categories;
    }
    final query = searchQuery.toLowerCase();
    return model.categories.where((cat) {
      return cat.title.toLowerCase().contains(query);
    }).toList();
  }

  MenuManagementState copyWith({
    MenuManagementModel? model,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MenuManagementState(
      model: model ?? this.model,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MenuManagementNotifier extends Notifier<MenuManagementState> {
  final MenuRepository _menuRepository = MenuRepository();

  @override
  MenuManagementState build() {
    _fetchLiveCategories();
    return const MenuManagementState(
      model: MenuManagementModel.dummy,
      isLoading: true,
    );
  }

  Future<void> _fetchLiveCategories() async {
    try {
      state = state.copyWith(isLoading: true);
      final rawCategories = await _menuRepository.getCategories();
      final mappedCategories = rawCategories.map((cat) {
        final count = cat['itemCount'] ?? cat['itemsCount'] ?? (cat['items'] as List?)?.length ?? 0;
        return MenuCategoryItem(
          id: cat['_id']?.toString() ?? cat['id']?.toString() ?? '',
          title: cat['name']?.toString() ?? cat['title']?.toString() ?? 'Category',
          itemCountText: '$count Items',
          iconEmoji: (cat['emoji'] != null && cat['emoji'].toString().isNotEmpty)
              ? cat['emoji'].toString()
              : '🍲',
          isEnabled: cat['isActive'] != false && cat['status'] != 'inactive',
        );
      }).toList();

      state = state.copyWith(
        model: MenuManagementModel(
          title: state.model.title,
          subtitle: state.model.subtitle,
          searchHint: state.model.searchHint,
          categories: mappedCategories,
        ),
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on fetching categories: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshCategories() async {
    await _fetchLiveCategories();
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleCategory(String id, bool val) {
    final updatedCategories = state.model.categories.map((cat) {
      if (cat.id == id) {
        return cat.copyWith(isEnabled: val);
      }
      return cat;
    }).toList();

    state = state.copyWith(
      model: MenuManagementModel(
        title: state.model.title,
        subtitle: state.model.subtitle,
        searchHint: state.model.searchHint,
        categories: updatedCategories,
      ),
    );
  }
}

final menuManagementProvider =
    NotifierProvider<MenuManagementNotifier, MenuManagementState>(
  MenuManagementNotifier.new,
);
