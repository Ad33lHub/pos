import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../config/theme.dart';
import 'receipt_screen.dart';

class ChargeScreen extends StatelessWidget {
  const ChargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Charge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Amount Due Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount Due',
                        style: TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),

            // Order Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('ID order:', '#31192758643252A23'), // Placeholder ID
                  const SizedBox(height: 12),
                  _buildInfoRow('Date:', 'Dec 17, 2024'), // Placeholder Date
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            const Text(
              'Amount Received',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            // Amount Input
            TextField(
              decoration: const InputDecoration(
                hintText: '\$54.00',
              ),
              keyboardType: TextInputType.number,
              // Setup controller if needed
            ),

            const Spacer(),

            // Payment Buttons
            ElevatedButton.icon(
              onPressed: () {
                // Process Cash Payment
                _processPayment(context, 'Cash');
              },
              icon: const Icon(Icons.money),
              label: const Text('Cash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.primaryBlack,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                // Process Card Payment
                _processPayment(context, 'Card');
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlack,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlack,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _processPayment(BuildContext context, String method) {
    // Show success or navigate to receipt
    // For now, just show a Success Dialog or SnackBar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 40, color: AppTheme.primaryBlack),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Success!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Payment successfully completed using $method.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.pop(context); // Close dialog
                   Navigator.pop(context); // Close Charge Screen
                   context.read<CartProvider>().clearCart(); // Clear cart
                }, 
                child: const Text('Done'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
