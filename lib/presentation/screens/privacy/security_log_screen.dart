import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/privacy_settings.dart';
import '../../providers/privacy_providers.dart';

/// UC272, UC273: Security log screen.
class SecurityLogScreen extends ConsumerStatefulWidget {
  const SecurityLogScreen({super.key});

  @override
  ConsumerState<SecurityLogScreen> createState() => _SecurityLogScreenState();
}

class _SecurityLogScreenState extends ConsumerState<SecurityLogScreen> {
  List<SecurityEvent>? _events;
  bool _isLoading = true;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(privacyServiceProvider);
      final events = await getSecurityEventsDirect(
        service,
        _userId,
        limit: 50,
      );
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log de Segurança'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events == null || _events!.isEmpty
              ? _buildEmptyState(theme)
              : _buildEventList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum evento registrado',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Atividades de segurança aparecerão aqui',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events!.length,
        itemBuilder: (context, index) {
          final event = _events![index];
          return _EventCard(event: event);
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SecurityEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(event.type, theme).withValues(alpha: 0.2),
          child: Icon(
            _getEventIcon(event.type),
            color: _getEventColor(event.type, theme),
          ),
        ),
        title: Text(
          event.type.displayName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(event.occurredAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (event.location != null)
              Text(
                event.location!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            if (event.ipAddress != null)
              Text(
                'IP: ${event.ipAddress}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            if (event.blocked)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Bloqueado',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getEventIcon(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.loginSuccess:
        return Icons.login;
      case SecurityEventType.loginFailed:
        return Icons.login;
      case SecurityEventType.loginBlocked:
        return Icons.block;
      case SecurityEventType.passwordChanged:
        return Icons.password;
      case SecurityEventType.passwordResetRequested:
        return Icons.lock_reset;
      case SecurityEventType.accountLocked:
        return Icons.lock;
      case SecurityEventType.accountUnlocked:
        return Icons.lock_open;
      case SecurityEventType.suspiciousActivity:
        return Icons.warning;
      case SecurityEventType.newDevice:
        return Icons.devices;
      case SecurityEventType.newLocation:
        return Icons.location_on;
    }
  }

  Color _getEventColor(SecurityEventType type, ThemeData theme) {
    switch (type) {
      case SecurityEventType.loginSuccess:
      case SecurityEventType.accountUnlocked:
        return Colors.green;
      case SecurityEventType.loginFailed:
      case SecurityEventType.loginBlocked:
      case SecurityEventType.accountLocked:
      case SecurityEventType.suspiciousActivity:
        return theme.colorScheme.error;
      case SecurityEventType.passwordChanged:
      case SecurityEventType.passwordResetRequested:
      case SecurityEventType.newDevice:
      case SecurityEventType.newLocation:
        return Colors.orange;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';

    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
