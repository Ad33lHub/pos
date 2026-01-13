import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/backup_service.dart';
import '../../config/theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> with SingleTickerProviderStateMixin {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _localBackups = [];
  List<Map<String, dynamic>> _driveBackups = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBackups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final local = await _backupService.listLocalBackups();
      final drive = await _backupService.listDriveBackups();
      
      if (mounted) {
        setState(() {
          _localBackups = local;
          _driveBackups = drive;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading backups: $e')),
        );
      }
    }
  }

  Future<void> _createBackup() async {
    bool uploadToDrive = false;
    
    // Ask if user wants to upload to Drive
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a new backup of all inventory and sales data?'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => Row(
                children: [
                   Checkbox(
                    value: uploadToDrive,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) => setState(() => uploadToDrive = val ?? false),
                  ),
                  const Text('Upload to Google Drive'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldUpload != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _backupService.createBackup(uploadToDrive: uploadToDrive);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup created successfully'),
              backgroundColor: AppTheme.success,
            ),
          );
          await _loadBackups();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup failed: ${result['error']}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup(Map<String, dynamic> backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text('This will replace current data with the backup. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> result;
    if (backup['type'] == 'local') {
      result = await _backupService.restoreBackup(backup['filePath']);
    } else {
      result = await _backupService.restoreFromDrive(backup['id']);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] == true 
            ? 'Restored successfully' 
            : 'Restore failed: ${result['error']}'),
          backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBackup(Map<String, dynamic> backup) async {
    if (backup['type'] != 'local') return; // Drive delete not implemented in example

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _backupService.deleteLocalBackup(backup['filePath']);
    await _loadBackups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Backups', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.cardWhite,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadBackups,
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gray200),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryGreen,
              unselectedLabelColor: AppTheme.textGray,
              indicatorColor: AppTheme.primaryGreen,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Local Storage'),
                Tab(text: 'Google Drive'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBackupList(_localBackups),
                _driveBackups.isEmpty 
                  ? _buildEmptyState('No Drive backups found\nSign in required')
                  : _buildBackupList(_driveBackups),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea( // Ensure button is safe on iOS
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createBackup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'Create New Backup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.backup_outlined, size: 60, color: AppTheme.gray300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupList(List<Map<String, dynamic>> backups) {
    if (backups.isEmpty) {
      return _buildEmptyState('No backups found');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: backups.length,
      itemBuilder: (context, index) {
        final backup = backups[index];
        final size = (backup['size'] as int) / 1024; // KB
        final date = backup['created'] as DateTime;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                backup['type'] == 'local' ? Icons.phone_android : Icons.cloud_queue,
                color: AppTheme.primaryGreen,
              ),
            ),
            title: Text(
              DateFormat('MMM dd, yyyy HH:mm').format(date),
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${size.toStringAsFixed(1)} KB',
              style: const TextStyle(color: AppTheme.textLight),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore, color: AppTheme.primaryGreen),
                  onPressed: () => _restoreBackup(backup),
                ),
                if (backup['type'] == 'local')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                    onPressed: () => _deleteBackup(backup),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
