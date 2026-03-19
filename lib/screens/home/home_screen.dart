import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';
import '../../widgets/product_card.dart';
import '../detail/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
// Đảm bảo đường dẫn này khớp với tên file Giỏ hàng của em nhé (thường là cart_screen.dart)
import '../cart/cart_screen.dart';
import '../order/order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _originalBannerHeight = 152;
  static const double _expandedBannerHeight = _originalBannerHeight * 2;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  );

  bool _isScrolled = false;
  int _currentBanner = 0;
  int _selectedCategory = 7;

  List<Product> _allProducts = [];
  List<Product> _visibleProducts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  static const int _pageSize = 10;
  Timer? _bannerTimer;

void _runFilter(String enteredKeyword) {
  List<Product> results = [];
  if (enteredKeyword.isEmpty) {
    // Nếu ô tìm kiếm trống, hiển thị 10 sản phẩm đầu như cũ
    results = _allProducts.take(10).toList();
  } else {
    // Lọc sản phẩm theo tên (không phân biệt hoa thường)
    results = _allProducts
        .where((user) =>
            user.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
        .toList();
  }

  setState(() {
    _visibleProducts = results;
  });
}

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startBannerAutoPlay();
    _loadInitialProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final bool scrolled = offset > 10;
    if (scrolled != _isScrolled) {
      setState(() {
        _isScrolled = scrolled;
      });
    }

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreProducts();
    }
  }

  void _startBannerAutoPlay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) return;
      final next = (_currentBanner + 1) % 3;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentBanner = next;
      });
    });
  }

  Future<void> _loadInitialProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ApiService.fetchProducts();
      _allProducts = products;
      _visibleProducts = products.take(_pageSize).toList();
      _hasMore = _visibleProducts.length < _allProducts.length;
    } catch (e) {
      _errorMessage = 'Không thể tải sản phẩm. Vui lòng thử lại.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadInitialProducts();
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final start = _visibleProducts.length;
    final next = _allProducts.skip(start).take(_pageSize).toList();
    if (next.isEmpty) {
      _hasMore = false;
    } else {
      _visibleProducts.addAll(next);
    }

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(theme),
              SliverToBoxAdapter(child: _buildBannerSection()),
              SliverToBoxAdapter(child: _buildCategorySection()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Gợi ý hôm nay',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(_errorMessage!)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.64,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = _visibleProducts[index];
                      return ProductCard(
    product: product,
    onTap: () {
      // Bổ sung lệnh chuyển trang
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    },
  );
                    }, childCount: _visibleProducts.length),
                  ),
                ),
              SliverToBoxAdapter(
                child: _isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 88,
      backgroundColor: const Color(0xFFFF5722),
      elevation: _isScrolled ? 2 : 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 0, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TH4 - Nhóm 11',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _buildSearchBar(theme),
          ],
        ),
      ),
      centerTitle: false,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      actions: [_buildOrdersIcon(theme), _buildCartIcon(theme), const SizedBox(width: 8)],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: Row(
      children: [
        const Icon(Icons.search, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _searchController, // Gắn bộ điều khiển
            onChanged: (value) => _runFilter(value), // Gọi hàm lọc khi gõ
            decoration: const InputDecoration(
              hintText: 'Tìm sản phẩm',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        // Thêm nút xóa nhanh chữ trong ô tìm kiếm cho tiện nhé
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () {
              _searchController.clear();
              _runFilter('');
            },
          )
      ],
    ),
  );
}

  Widget _buildCartIcon(ThemeData theme) {
    // 1. Dùng context.watch để lắng nghe số lượng thực tế từ CartProvider
    final cartCount = context.watch<CartProvider>().items.length; 
    
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          onPressed: () {
            // 2. Chuyển sang màn hình Giỏ hàng khi bấm vào
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
        // 3. Chỉ hiện cục màu đỏ nếu có sản phẩm trong giỏ (> 0)
        if (cartCount > 0)
          Positioned(
            right: 6,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$cartCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBannerSection() {
    final banners = [
      'https://images.pexels.com/photos/5632371/pexels-photo-5632371.jpeg',
      'https://images.pexels.com/photos/5632375/pexels-photo-5632375.jpeg',
      'https://images.pexels.com/photos/5632402/pexels-photo-5632402.jpeg',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Column(
        children: [
          SizedBox(
            height: _expandedBannerHeight,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() {
                  _currentBanner = index;
                });
              },
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 12 : 4, right: 4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          banners[index],
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(banners.length, (dot) {
                              final bool isActive = dot == _currentBanner;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: isActive ? 10 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersIcon(ThemeData theme) {
    return IconButton(
      icon: const Icon(Icons.receipt_long, color: Colors.white),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        );
      },
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'icon': Icons.storefront_outlined, 'label': 'Tất cả'},
      {'icon': Icons.local_drink_outlined, 'label': 'Nước uống'},
      {'icon': Icons.shopping_basket_outlined, 'label': 'Tạp hóa'},
      {'icon': Icons.checkroom_outlined, 'label': 'Phụ kiện'},
      {'icon': Icons.person_2_outlined, 'label': 'Áo nam'},
      {'icon': Icons.face_retouching_natural_outlined, 'label': 'Làm đẹp'},
      {'icon': Icons.weekend_outlined, 'label': 'Nội thất'},
      {'icon': Icons.laptop_mac_outlined, 'label': 'Laptop'},
      {'icon': Icons.escalator_warning_outlined, 'label': 'Giày nữ'},
      {'icon': Icons.phone_iphone_outlined, 'label': 'Phụ kiện'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: SizedBox(
        height: _originalBannerHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 6, bottom: 4),
                child: Text(
                  'Danh mục',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.92,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                  ),
                  itemBuilder: (context, index) {
                    return _buildCategoryItem(categories[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, Object> data, int index) {
    final icon = data['icon'] as IconData;
    final label = data['label'] as String;
    final bool isActive = index == _selectedCategory;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _selectedCategory = index;
        });
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? const Color(0xFFFF6A46) : Colors.transparent,
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFE8613C), size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF444444)),
          ),
        ],
      ),
    );
  }
}
