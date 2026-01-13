import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/theme.dart';
import '../providers/product_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/side_menu.dart';
import 'products/products_screen.dart';
import 'products/add_product_screen.dart';
import 'inventory/stock_in_screen.dart';
import 'inventory/stock_out_screen.dart';
import 'inventory/stock_history_screen.dart';
import 'pos/pos_screen.dart';
import 'customers/customers_screen.dart';
import 'ledger/ledger_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Load dashboard data
    Future.microtask(() {
      final context = this.context;
      context.read<ProductProvider>().loadProducts();
      context.read<CustomerProvider>().loadCustomers();
      context.read<ReportsProvider>().loadTodayReport();
    });
  }

  void _onMenuSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic
    switch (index) {
      case 0:
        // Already on Dashboard
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const POSScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      case 99:
        _signOut(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Dashboard', style: TextStyle(color: AppTheme.textDark)),
              backgroundColor: AppTheme.cardWhite,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppTheme.textDark),
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: SideMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  Navigator.pop(context); // Close drawer
                  _onMenuSelected(index);
                },
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Desktop Sidebar
          if (isDesktop)
            SideMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: _onMenuSelected,
            ),

          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Welcome back, Admin',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textLight.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      
                      // Connectivity Status
                      Consumer<ConnectivityProvider>(
                        builder: (context, connectivity, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (connectivity.isOnline ? Colors.green : Colors.orange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: connectivity.isOnline ? Colors.green : Colors.orange,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                                  color: connectivity.isOnline ? Colors.green : Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  connectivity.isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: connectivity.isOnline ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Statistics Cards Section
                  if (!isDesktop)
                    SizedBox(
                      height: 160,
                      child: Consumer3<ReportsProvider, ProductProvider, CustomerProvider>(
                        builder: (context, reports, products, customers, _) {
                          // Ensure data is loaded
                          // Data loading is handled in initState
                          
                          final sales = reports.todayReport?['totalSales'] ?? 0.0;
                          final productCount = products.products.length;
                          final customerCount = customers.customers.length;
                          
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: 280,
                                child: DashboardStatsCard(
                                  title: 'Sales Today',
                                  value: '\$${sales.toStringAsFixed(2)}',
                                  icon: Icons.attach_money,
                                  iconColor: AppTheme.primaryGreen,
                                  trend: 'Daily',
                                  isTrendPositive: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 280,
                                child: DashboardStatsCard(
                                  title: 'Total Products',
                                  value: '$productCount',
                                  icon: Icons.inventory_2_outlined,
                                  iconColor: Colors.blue,
                                  trend: 'Items',
                                  isTrendPositive: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 280,
                                child: DashboardStatsCard(
                                  title: 'Total Customers',
                                  value: '$customerCount',
                                  icon: Icons.people_outline,
                                  iconColor: Colors.purple,
                                  trend: 'Active',
                                  isTrendPositive: true,
                                ),
                              ),
                              const SizedBox(width: 24),
                            ],
                          );
                        },
                      ),
                    )
                  else
                    // Desktop Grid Row
                    SizedBox(
                      height: 160,
                      child: Consumer3<ReportsProvider, ProductProvider, CustomerProvider>(
                        builder: (context, reports, products, customers, _) {
                           final sales = reports.todayReport?['totalSales'] ?? 0.0;
                           final productCount = products.products.length;
                           final customerCount = customers.customers.length;

                          return Row(
                            children: [
                              Expanded(
                                child: DashboardStatsCard(
                                  title: 'Sales Today',
                                  value: '\$${sales.toStringAsFixed(2)}',
                                  icon: Icons.attach_money,
                                  iconColor: AppTheme.primaryGreen,
                                  trend: 'Daily',
                                  isTrendPositive: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardStatsCard(
                                  title: 'Total Products',
                                  value: '$productCount',
                                  icon: Icons.inventory_2_outlined,
                                  iconColor: Colors.blue,
                                  trend: 'Items',
                                  isTrendPositive: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardStatsCard(
                                  title: 'Total Customers',
                                  value: '$customerCount',
                                  icon: Icons.people_outline,
                                  iconColor: Colors.purple,
                                  trend: 'Active',
                                  isTrendPositive: true,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 32),
                  
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions Grid (Restored partial functionality from old grid)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildQuickActionCard(
                        'New Sale',
                        Icons.add_shopping_cart,
                        AppTheme.primaryGreen,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const POSScreen())),
                      ),
                      _buildQuickActionCard(
                        'New Product',
                        Icons.add_box_outlined,
                        Colors.blue,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen())),
                      ),
                      _buildQuickActionCard(
                        'Customers',
                        Icons.people_outline,
                        Colors.orange,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen())),
                      ),
                      _buildQuickActionCard(
                        'Stock In',
                        Icons.inventory_2_outlined,
                        Colors.purple,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockInScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


