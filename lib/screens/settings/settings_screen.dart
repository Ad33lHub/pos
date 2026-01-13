import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/sync_provider.dart';
import '../../config/theme.dart';
import '../backup/backup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.cardWhite,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            _buildSectionHeader('Connection'),
            const SizedBox(height: 12),
            Consumer<ConnectivityProvider>(
              builder: (context, connectivity, _) {
                return _buildStatusCard(
                  connectivity.isOnline ? 'Online' : 'Offline',
                  connectivity.isOnline
                      ? 'Connected to internet'
                      : 'No internet connection',
                  connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                  connectivity.isOnline ? AppTheme.success : AppTheme.error,
                  subtitle2: connectivity.lastOnlineTime != null
                      ? 'Last online: ${DateFormat('MMM dd, hh:mm a').format(connectivity.lastOnlineTime!)}'
                      : null,
                );
              },
            ),
            const SizedBox(height: 24),

            // Sync Status
            _buildSectionHeader('Sync Status'),
            const SizedBox(height: 12),
            Consumer<SyncProvider>(
              builder: (context, sync, _) {
                return _buildStatusCard(
                  sync.isSyncing ? 'Syncing' : 'Ready',
                  sync.syncMessage ?? (sync.lastSyncTime != null
                      ? 'Last synced: ${DateFormat('MMM dd, hh:mm a').format(sync.lastSyncTime!)}'
                      : 'Not synced yet'),
                  sync.isSyncing ? Icons.sync : Icons.check_circle,
                  sync.isSyncing ? Colors.blue : AppTheme.success,
                  subtitle2: sync.pendingCount > 0
                      ? '${sync.pendingCount} items pending'
                      : null,
                );
              },
            ),
            const SizedBox(height: 24),

            // App Info
            _buildSectionHeader('App Information'),
            const SizedBox(height: 12),
            Container(
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
                    _buildInfoTile('Version', '1.0.0', Icons.info),
                    const Divider(height: 1),
                    _buildInfoTile('Build', '1', Icons.build),
                    const Divider(height: 1),
                    _buildInfoTile('Database', 'SQLite + Firestore', Icons.storage),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            _buildSectionHeader('Actions'),
            const SizedBox(height: 12),
            Consumer<SyncProvider>(
              builder: (context, sync, _) {
                return _buildActionButton(
                  sync.isSyncing ? 'Syncing...' : 'Sync Now',
                  Icons.sync,
                  Colors.blue,
                  sync.isSyncing ? () {} : () => sync.syncNow(),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Backup & Restore',
              Icons.backup,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BackupScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Clear Cache',
              Icons.delete_sweep,
              Colors.orange,
              () {
                _showConfirmDialog(
                  context,
                  'Clear Cache',
                  'This will clear all locally cached data. Are you sure?',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared'), backgroundColor: AppTheme.success),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusCard(String title, String subtitle, IconData icon, Color color, {String? subtitle2}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 12,
                  ),
                ),
                if (subtitle2 != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle2,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textGray, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
         decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 5,
               offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textLight, size: 16),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardWhite,
        title: Text(title, style: const TextStyle(color: AppTheme.textDark)),
        content: Text(message, style: const TextStyle(color: AppTheme.textGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }
}
