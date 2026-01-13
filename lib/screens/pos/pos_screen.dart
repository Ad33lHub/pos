import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/product_quick_card.dart';
import '../../config/theme.dart';
import 'checkout_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _showTicketView = false; // Toggle for Mobile

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Ticket (Cart) View ---
  Widget _buildTicketView(BuildContext context) {
    return Container(
      color: AppTheme.backgroundLight,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppTheme.cardWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Current Sale',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textGray),
                  onPressed: () => setState(() => _showTicketView = false),
                ),
              ],
            ),
          ),
          
          // Cart List
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                if (cart.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, 
                            size: 64, color: AppTheme.textLight),
                        const SizedBox(height: 16),
                        const Text(
                          'Cart is empty',
                          style: TextStyle(color: AppTheme.textGray, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                         ElevatedButton.icon(
                              onPressed: () => setState(() => _showTicketView = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: AppTheme.textDark,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 20),
                              label: const Text("Start Shopping", style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemCard(
                      item: item,
                      onIncrement: () => cart.incrementQuantity(item.product.id),
                      onDecrement: () => cart.decrementQuantity(item.product.id),
                      onRemove: () => cart.removeItem(item.product.id),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Actions
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSummaryRow('Sub total', cart.subtotal),
                      if (cart.cartDiscountAmount > 0)
                        _buildSummaryRow('Discount', -cart.cartDiscountAmount, isDiscount: true),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                 // Save logic
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.gray300),
                                foregroundColor: AppTheme.textDark,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Save Order', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: cart.items.isEmpty 
                                ? null 
                                : () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                                    );
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: AppTheme.textDark,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor: AppTheme.gray100,
                                disabledForegroundColor: AppTheme.textGray,
                              ),
                              child: const Text('Charge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double val, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 16)),
          Text(
            isDiscount ? '-\$${val.abs().toStringAsFixed(2)}' : '\$${val.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: isDiscount ? AppTheme.success : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mobile Toggle View Logic
    if (_showTicketView) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(child: _buildTicketView(context)),
      );
    }
    
    // Main Product Grid View
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('New Sale', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: AppTheme.cardWhite,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
            // Cart Icon for quick toggle
            Consumer<CartProvider>(
                builder: (context, cart, _) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                          IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () => setState(() => _showTicketView = true),
                          ),
                          if (cart.items.isNotEmpty)
                              Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                            '${cart.items.length}',
                                            style: const TextStyle(fontSize: 10, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ),
                              )
                      ],
                  ),
                ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => context.read<ProductProvider>().setSearchQuery(val),
                style: const TextStyle(color: AppTheme.textDark),
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: AppTheme.textLight),
                  prefixIcon: Icon(Icons.search, color: AppTheme.textGray),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          
          // Categories
          SizedBox(
            height: 40,
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ActionChip(
                        label: Text(cat),
                        backgroundColor: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
                        labelStyle: TextStyle(
                            color: isSelected ? AppTheme.textDark : AppTheme.textGray,
                            fontWeight: FontWeight.w600
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () {
                           setState(() => _selectedCategory = cat);
                           provider.setCategory(cat);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Product Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                 final products = provider.filteredProducts;
                 if (provider.isLoading) {
                   return const Center(child: CircularProgressIndicator());
                 }
                 if (products.isEmpty) {
                     return const Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.search_off, size: 60, color: AppTheme.textLight),
                           SizedBox(height: 16),
                           Text('No products found', style: TextStyle(color: AppTheme.textGray)),
                         ],
                       ),
                     );
                 }
                 return GridView.builder(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2, // Mobile 2-column
                     childAspectRatio: 0.75, // Taller cards
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                   ),
                   itemCount: products.length,
                   itemBuilder: (ctx, index) => ProductQuickCard(
                     product: products[index],
                     onTap: () {
                        context.read<CartProvider>().addItem(products[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                               content: Row(
                                 children: [
                                   const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                   const SizedBox(width: 8),
                                   Text('${products[index].name} added'),
                                 ],
                               ),
                               backgroundColor: AppTheme.textDark,
                               behavior: SnackBarBehavior.floating,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                               duration: const Duration(milliseconds: 600),
                               margin: const EdgeInsets.all(20),
                           )
                        );
                     },
                   ),
                 );
              },
            ),
          ),
          
          // Bottom Cart Summary (Floating Bar)
          Consumer<CartProvider>(
              builder: (context, cart, _) {
                  if (cart.isEmpty) return const SizedBox.shrink();
                  return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppTheme.backgroundLight,
                        // gradient: LinearGradient(
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        //   colors: [AppTheme.backgroundLight.withOpacity(0), AppTheme.backgroundLight],
                        // ),
                      ),
                      child: SafeArea(
                        child: ElevatedButton(
                            onPressed: () => setState(() => _showTicketView = true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.textDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${cart.itemCount} Items',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                    ),
                                    Row(
                                      children: [
                                        const Text('View Ticket', style: TextStyle(fontWeight: FontWeight.w500)),
                                        const SizedBox(width: 8),
                                        Text(
                                            '\$${cart.total.toStringAsFixed(2)}', 
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_ios, size: 14),
                                      ],
                                    ),
                                ],
                            ),
                        ),
                      ),
                  );
              }
          )
        ],
      ),
    );
  }
}
