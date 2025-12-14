import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/allergen.dart';
import 'product_detail_screen.dart';

/// 제품 목록을 표시하는 메인 화면
class ProductListScreen extends StatefulWidget {
  /// 사용자가 선택한 알레르기 목록
  final List<String> userAllergens;

  const ProductListScreen({
    super.key,
    required this.userAllergens,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  /// 선택된 카테고리 (전체 보기 또는 특정 카테고리)
  String _selectedCategory = '전체';
  
  /// 안전한 제품만 보기 필터
  bool _showSafeOnly = false;

  /// 검색어
  String _searchQuery = '';

  /// 사용 가능한 모든 카테고리 목록 가져오기
  List<String> get _categories {
    final categories = Product.sampleProducts
        .map((product) => product.category)
        .toSet()
        .toList();
    return ['전체', ...categories];
  }

  /// 필터링된 제품 목록 가져오기
  List<Product> get _filteredProducts {
    return Product.sampleProducts.where((product) {
      // 카테고리 필터
      final categoryMatch = _selectedCategory == '전체' || 
                           product.category == _selectedCategory;
      
      // 안전한 제품만 보기 필터
      final safetyMatch = !_showSafeOnly || 
                         product.isSafeFor(widget.userAllergens);
      
      // 검색어 필터
      final searchMatch = _searchQuery.isEmpty ||
                         product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return categoryMatch && safetyMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 검색바
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '제품 검색...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        /// 카테고리 필터
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: Colors.orange[700],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        /// 안전한 제품만 보기 스위치
        if (widget.userAllergens.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  '안전한 제품만 보기',
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Switch(
                  value: _showSafeOnly,
                  onChanged: (value) {
                    setState(() {
                      _showSafeOnly = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),

        /// 제품 개수 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '총 ${_filteredProducts.length}개 제품',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),

        /// 제품 목록
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_basket_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '해당하는 제품이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final isSafe = product.isSafeFor(widget.userAllergens);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 2,
                      child: ListTile(
                        /// 제품 이미지 (이모지)
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              product.imageUrl,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        
                        /// 제품 정보
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // 안전 상태 표시
                            if (widget.userAllergens.isNotEmpty)
                              Icon(
                                isSafe ? Icons.check_circle : Icons.warning,
                                color: isSafe ? Colors.green : Colors.red,
                                size: 20,
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(product.category),
                            const SizedBox(height: 4),
                            Text(
                              '${product.price.toStringAsFixed(0)}원',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        
                        /// 오른쪽 화살표
                        trailing: const Icon(Icons.chevron_right),
                        
                        /// 탭하면 상세 화면으로 이동
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                                userAllergens: widget.userAllergens,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
