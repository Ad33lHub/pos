import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/customer_card.dart';
import '../../models/customer.dart';
import '../../config/theme.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Customers',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  onChanged: (value) {
                    context.read<CustomerProvider>().setSearchQuery(value);
                  },
                  style: const TextStyle(color: AppTheme.textDark),
                  decoration: const InputDecoration(
                    hintText: 'Search by name or phone...',
                    hintStyle: TextStyle(color: AppTheme.textLight),
                    prefixIcon: Icon(Icons.search, color: AppTheme.textGray),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Type filters
            Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip('All', null, provider),
                      const SizedBox(width: 12),
                      _buildFilterChip('Regular', CustomerType.regular, provider),
                      const SizedBox(width: 12),
                      _buildFilterChip('Walk-in', CustomerType.walkIn, provider),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Customers list
            Expanded(
              child: Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  final customers = provider.filteredCustomers;

                  if (customers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 60, color: AppTheme.textLight),
                          SizedBox(height: 16),
                          Text(
                            'No customers found',
                            style: TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(customer: customer),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: AppTheme.textDark,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildFilterChip(String label, CustomerType? type, CustomerProvider provider) {
    final isSelected = provider.filterType == type;
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.textDark : AppTheme.textGray,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () => provider.setFilterType(type),
    );
  }
}
