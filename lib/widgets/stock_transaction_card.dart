import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_transaction.dart';
import '../config/theme.dart';

class StockTransactionCard extends StatelessWidget {
  final StockTransaction transaction;

  const StockTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isStockIn = transaction.type == TransactionType.stockIn;
    final color = isStockIn ? AppTheme.primaryGreen : AppTheme.error;
    final icon = isStockIn ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      width: double.infinity,
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
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.productName,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isStockIn ? "Stock In" : "Stock Out"} • ${transaction.quantity} units',
                    style: const TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.createdAt),
                    style: TextStyle(
                      color: AppTheme.textLight.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  if (transaction.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      transaction.notes,
                      style: const TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Stock change indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isStockIn ? "+" : "-"}${transaction.quantity}',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.previousStock} → ${transaction.newStock}',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
