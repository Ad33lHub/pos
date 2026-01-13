import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/report_card.dart';
import '../../config/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<ReportsProvider>().loadAllReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                      'Reports',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                   ),
                   const Spacer(),
                   IconButton(
                      icon: const Icon(Icons.refresh, color: AppTheme.textDark),
                      onPressed: () => context.read<ReportsProvider>().refresh(),
                   ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                   color: AppTheme.primaryGreen,
                   borderRadius: BorderRadius.circular(25),
                ),
                labelColor: AppTheme.textDark, // Selected text
                unselectedLabelColor: AppTheme.textGray,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sales'),
                  Tab(text: 'Stock'),
                  Tab(text: 'Customers'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSalesReport(),
                  _buildStockReport(),
                  _buildCustomerReport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesReport() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final todayReport = provider.todayReport;
        final monthlyReport = provider.monthlyReport;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Today\'s Sales'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Revenue',
                      value: '\$${(todayReport?['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Orders',
                      value: '${todayReport?['totalOrders'] ?? 0}',
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Items Sold',
                      value: '${todayReport?['totalItems'] ?? 0}',
                      icon: Icons.inventory,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Avg Order',
                      value: '\$${(todayReport?['averageOrderValue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Top Selling Items Today'),
              const SizedBox(height: 12),
              _buildTopItemsList(todayReport?['topItems'] ?? []),
              const SizedBox(height: 24),

              _buildSectionTitle('This Month'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Monthly Revenue',
                      value: '\$${(monthlyReport?['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.calendar_today,
                      color: Colors.teal,
                      subtitle: '${monthlyReport?['totalOrders'] ?? 0} orders',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Daily Avg',
                      value: '\$${(monthlyReport?['averageDaily'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.show_chart,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockReport() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
          // ... (Existing logic same, simplified for brevity in this step if needed, but I'll write full)
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        final stockValue = provider.stockValueReport;
        final lowStock = provider.lowStockProducts;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Inventory Overview'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReportCard(
                      title: 'Total Value',
                      value: '\$${(stockValue?['totalValue'] ?? 0).toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReportCard(
                      title: 'Products',
                      value: '${stockValue?['totalProducts'] ?? 0}',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                      subtitle: '${stockValue?['totalQuantity'] ?? 0} units',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReportCard(
                title: 'Low Stock Items',
                value: '${lowStock.length}',
                icon: Icons.warning,
                color: lowStock.isEmpty ? Colors.green : Colors.orange,
                subtitle: lowStock.isEmpty ? 'All items stocked' : 'Need attention',
              ),
              const SizedBox(height: 24),

              if (lowStock.isNotEmpty) ...[
                _buildSectionTitle('Low Stock Products'),
                const SizedBox(height: 12),
                ...lowStock.map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLowStockItem(product),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerReport() {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) { 
         // ...
         if (provider.isLoading) return const Center(child: CircularProgressIndicator());
         final topCustomers = provider.topCustomers;
         final outstanding = provider.customerOutstanding;
         final activity = provider.customerActivity;

         return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _buildSectionTitle('Customer Overview'),
                    const SizedBox(height: 12),
                    Row(
                        children: [
                            Expanded(child: ReportCard(
                                title: 'Total Customers',
                                value: '${activity?['totalCustomers'] ?? 0}',
                                icon: Icons.people,
                                color: Colors.blue,
                                subtitle: '${activity?['activeCustomers'] ?? 0} active',
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: ReportCard(
                                title: 'New This Month',
                                value: '${activity?['newCustomersThisMonth'] ?? 0}',
                                icon: Icons.person_add,
                                color: Colors.green,
                            )),
                        ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                        children: [
                            Expanded(child: ReportCard(
                                title: 'Outstanding',
                                value: '\$${(outstanding?['totalOutstanding'] ?? 0).toStringAsFixed(2)}',
                                icon: Icons.account_balance,
                                color: Colors.orange,
                                subtitle: '${outstanding?['customersWithBalance'] ?? 0} customers',
                            )),
                        ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Top Customers'),
                    const SizedBox(height: 12),
                    ...topCustomers.asMap().entries.map((entry) {
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTopCustomerItem(entry.key + 1, entry.value),
                        );
                    }),
                ],
            ),
         );
      }
    );
  }

  Widget _buildSectionTitle(String title) {
      return Text(title, style: const TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildTopItemsList(List<dynamic> items) {
      if (items.isEmpty) {
          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.cardWhite, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('No sales today', style: TextStyle(color: AppTheme.textGray))),
          );
      }
      return Column(
          children: items.map<Widget>((item) {
              return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.cardWhite, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Expanded(child: Text(item.key, style: const TextStyle(color: AppTheme.textDark, fontSize: 14))),
                              Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Text('${item.value} sold', style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                          ],
                      ),
                  ),
              );
          }).toList(),
      );
  }

  Widget _buildLowStockItem(product) {
      return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cardWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gray100)),
          child: Row(
              children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(product.name, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                              Text(product.sku, style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
                          ],
                      ),
                  ),
                  Text('${product.quantity} left', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
          ),
      );
  }

  Widget _buildTopCustomerItem(int rank, Map<String, dynamic> customer) {
      return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cardWhite, borderRadius: BorderRadius.circular(12)),
          child: Row(
              children: [
                  Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                          color: rank <= 3 ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('#$rank', style: TextStyle(color: rank <= 3 ? Colors.amber : Colors.blue, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(customer['name'] ?? '', style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                              Text('${customer['totalOrders']} orders', style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
                          ],
                      ),
                  ),
                  Text('\$${(customer['totalPurchases'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
              ],
          ),
      );
  }
}
