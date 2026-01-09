import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../widgets/cart_item_card.dart';
import '../../widgets/product_quick_card.dart';
import '../../config/theme.dart';
import 'charge_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  // View State: 0 = Cart/Ticket (Default), 1 = Product Grid
  int _currentViewIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

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

  void _toggleView() {
    setState(() {
      _currentViewIndex = _currentViewIndex == 0 ? 1 : 0;
    });
  }

  void _showTicketMenu() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildMenuOption(Icons.edit, 'Edit Ticket', () {}),
              _buildMenuOption(Icons.person_add_outlined, 'Assign Ticket', () {}),
              _buildMenuOption(Icons.call_merge, 'Merge Ticket', () {}),
              _buildMenuOption(Icons.call_split, 'Split Ticket', () {}),
              _buildMenuOption(Icons.sync, 'Sync', () {}),
              const Divider(),
              _buildMenuOption(Icons.delete_outline, 'Clear Ticket', () {
                context.read<CartProvider>().clearCart();
                Navigator.pop(context);
              }, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Icon (Toggle View)
                  GestureDetector(
                    onTap: _toggleView,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _currentViewIndex == 0 ? Icons.grid_view_rounded : Icons.receipt_long_rounded,
                        color: AppTheme.primaryBlack,
                        size: 28,
                      ),
                    ),
                  ),

                  // Center Ticket Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        return Row(
                          children: [
                            const Text(
                              'Ticket',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlack,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),

                  // Right Menu Icon
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: _showTicketMenu,
                    color: AppTheme.primaryBlack,
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: _currentViewIndex == 0 ? _buildCartView() : _buildProductView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartView() {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No items in ticket',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _toggleView,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Add Items'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

        // Bottom Summary Section
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            if (cart.isEmpty) return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSummaryRow('Sub total :', cart.subtotal),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Discount :', cart.cartDiscountAmount + cart.totalItemDiscount),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'total :',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                             // Save functionality
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlack, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: AppTheme.primaryBlack,
                          ),
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (_) => const ChargeScreen()),
                             );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: AppTheme.primaryBlack,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Charge', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductView() {
    return Column(
      children: [
        // Search Bar Area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<ProductProvider>().setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search..',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune_rounded), // Filter icon
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner_rounded), // Scan icon
              ),
            ],
          ),
        ),

        // Categories / All Items header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {}, 
                child: const Text('See All', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),

        // Category Pills (Simplified for now)
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildCategoryPill('All items', true), // TODO: Make dynamic
              _buildCategoryPill('Categories', false),
              _buildCategoryPill('Favorites', false),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, provider, _) {
              final products = provider.filteredProducts;
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductQuickCard(
                    product: product,
                    onTap: () {
                      context.read<CartProvider>().addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added'),
                          duration: const Duration(milliseconds: 500),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryPill(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? Colors.white : Colors.transparent,
        side: isSelected ? null : const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
