import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'product_models.dart';

class ProductsState {
  final bool isLoading;
  final List<Product> products;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;

  const ProductsState({
    this.isLoading = false,
    this.products = const [],
    this.errorMessage,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  ProductsState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesCategory = selectedCategory == 'All' ||
          p.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get allCategories {
    final set = <String>{'All'};
    for (final p in products) {
      if (p.category.isNotEmpty) set.add(p.category);
    }
    return set.toList();
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ApiClient _apiClient;

  ProductsNotifier(this._apiClient) : super(const ProductsState()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.get('/api/v1/products', requiresAuth: true);
      if (res is List) {
        final list = res.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        state = state.copyWith(isLoading: false, products: list);
      } else {
        state = state.copyWith(isLoading: false, products: const []);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    try {
      await _apiClient.post('/api/v1/products', body: data, requiresAuth: true);
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.put('/api/v1/products/$id', body: data, requiresAuth: true);
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _apiClient.delete('/api/v1/products/$id', requiresAuth: true);
      await fetchProducts();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> importCsv(String csvText) async {
    try {
      final res = await _apiClient.post(
        '/api/v1/products/import',
        body: {'csv_text': csvText},
        requiresAuth: true,
      );
      await fetchProducts();
      if (res is Map<String, dynamic>) {
        return res;
      }
      return {'created': 0, 'errors': ['Invalid server response']};
    } catch (e) {
      return {'created': 0, 'errors': [e.toString()]};
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final api = ref.watch(apiClientProvider);
  return ProductsNotifier(api);
});

final productStatsProvider =
    FutureProvider.family<ProductDetailedStats?, int>((ref, productId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.get('/api/v1/products/$productId/stats', requiresAuth: true);
    if (res is Map<String, dynamic>) {
      return ProductDetailedStats.fromJson(res);
    }
    return null;
  } catch (_) {
    return null;
  }
});
