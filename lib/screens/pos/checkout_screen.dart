import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/ledger_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/sales_service.dart';
import '../../services/database_helper.dart';
import '../../models/sale.dart';
import '../../models/cart_item.dart';
import 'receipt_screen.dart';
import '../../config/theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _amountController = TextEditingController();
  final SalesService _salesService = SalesService();
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _completeSale() async {
    final cart = context.read<CartProvider>();
    final customer = context.read<CustomerProvider>().selectedCustomer;
    final isOffline = context.read<ConnectivityProvider>().isOffline;

    // Validate payment
    if (_selectedMethod == PaymentMethod.cash) {
      final amountReceived = double.tryParse(_amountController.text) ?? 0;
      if (amountReceived < cart.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient amount received'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedMethod == PaymentMethod.credit && !isOffline) {
      // Offline credit sales are restricted for safety
      if (customer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer for credit payment'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      // Generate sale number (use timestamp if offline)
      final saleNumber = isOffline
          ? 'OFF-${DateTime.now().millisecondsSinceEpoch}'
          : await _salesService.generateSaleNumber();

      // Calculate change
      final amountReceived = _selectedMethod == PaymentMethod.cash
          ? double.tryParse(_amountController.text) ?? cart.total
          : cart.total;
      final change = amountReceived - cart.total;

      // Create sale
      final sale = Sale(
        id: isOffline ? 'temp_${DateTime.now().millisecondsSinceEpoch}' : '',
        saleNumber: saleNumber,
        items: cart.items,
        subtotal: cart.subtotal,
        taxRate: cart.taxRate,
        taxAmount: cart.taxAmount,
        cartDiscount: cart.cartDiscount,
        cartDiscountType: cart.cartDiscountType,
        totalAmount: cart.total,
        paymentMethod: _selectedMethod,
        amountReceived: amountReceived,
        changeGiven: change,
        customerId: customer?.id,
        customerName: customer?.name,
        isPaid: _selectedMethod != PaymentMethod.credit,
        createdAt: DateTime.now(),
        createdBy: FirebaseAuth.instance.currentUser?.uid ?? 'offline_user',
      );

      if (isOffline) {
        // SAVE OFFLINE
        final saleMap = sale.toMap();
        saleMap['items'] = cart.items.map((item) => item.toMap()).toList();
        
        await DatabaseHelper.instance.insertOfflineSale(
          sale.id,
          jsonEncode(saleMap),
        );
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offline: Sale saved. Will sync when online.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // ONLINE
        await _salesService.completeSale(sale);

        // If credit payment, create ledger debit entry
        if (_selectedMethod == PaymentMethod.credit && customer != null) {
          await context.read<LedgerProvider>().createCreditSale(
            customerId: customer.id,
            customerName: customer.name,
            amount: cart.total,
            saleId: saleNumber,
          );
        }
      }

      setState(() => _isProcessing = false);

      if (mounted) {
        // Navigate to receipt
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(sale: sale),
          ),
        );

        // Clear cart
        context.read<CartProvider>().clearCart();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete sale: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.cardWhite,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Order Summary Card
                        Container(
                          padding: const EdgeInsets.all(24),
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
                          child: Column(
                            children: [
                              _buildRow('Total Items', '${cart.totalQuantity}'),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                              _buildRow('Total Amount', '\$${cart.total.toStringAsFixed(2)}', 
                                        isBold: true, valueColor: AppTheme.primaryGreen, valueSize: 24),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Payment Method
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildPaymentMethodCard(
                                PaymentMethod.cash,
                                Icons.payments_outlined,
                                'Cash',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPaymentMethodCard(
                                PaymentMethod.card,
                                Icons.credit_card,
                                'Card',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPaymentMethodCard(
                                PaymentMethod.credit,
                                Icons.person_outline,
                                'Credit',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Amount Received (for cash)
                        if (_selectedMethod == PaymentMethod.cash) ...[
                          const Text(
                            'Amount Received',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.cardWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primaryGreen, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              style: const TextStyle(
                                color: AppTheme.textDark, 
                                fontSize: 24, 
                                fontWeight: FontWeight.bold
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(color: AppTheme.primaryGreen, fontSize: 24, fontWeight: FontWeight.bold),
                                hintText: '0.00',
                                hintStyle: TextStyle(color: AppTheme.textLight),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Change Display
                          if (_amountController.text.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.textDark,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Change Due',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '\$${((double.tryParse(_amountController.text) ?? 0) - cart.total).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    align: Alignment.topCenter,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _completeSale,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.textDark,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Complete Sale',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, IconData icon, String label) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.gray200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.primaryGreen.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.textDark : AppTheme.textGray,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textDark : AppTheme.textGray,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor, double? valueSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textGray,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textDark,
            fontSize: valueSize ?? (isBold ? 18 : 16),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
