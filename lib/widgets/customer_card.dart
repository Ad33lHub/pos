import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../config/theme.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    customer.name,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: customer.customerType == CustomerType.regular
                        ? Colors.blue.withOpacity(0.1)
                        : AppTheme.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    customer.customerTypeString,
                    style: TextStyle(
                      color: customer.customerType == CustomerType.regular
                          ? Colors.blue
                          : AppTheme.textGray,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              customer.phone,
              style: const TextStyle(
                color: AppTheme.textGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Orders',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${customer.totalOrders}',
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '\$${customer.totalPurchases.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (customer.hasBalance)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Balance',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '\$${customer.outstandingBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
