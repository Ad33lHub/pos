import 'package:flutter/material.dart';
import '../config/theme.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppTheme.backgroundLight,
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, color: AppTheme.textDark),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sprinta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Menu Items
          _buildMenuItem(0, Icons.dashboard_outlined, 'Dashboard'),
          _buildMenuItem(1, Icons.point_of_sale, 'POS System'),
          _buildMenuItem(2, Icons.inventory_2_outlined, 'Products'),
          _buildMenuItem(3, Icons.people_outline, 'Customers'),
          _buildMenuItem(4, Icons.bar_chart_outlined, 'Reports'),
          _buildMenuItem(5, Icons.settings_outlined, 'Settings'),
          
          const Spacer(),
          
          // Logout
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildMenuItem(99, Icons.logout, 'Logout', isLogout: true),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {bool isLogout = false}) {
    final isSelected = selectedIndex == index;
    
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.textDark : AppTheme.textLight,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.textDark : AppTheme.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
