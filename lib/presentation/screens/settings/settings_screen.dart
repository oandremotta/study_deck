import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../router/app_router.dart';

/// Keys for notification settings in SharedPreferences.
class NotificationSettings {
  static const String enabledKey = 'notifications_enabled';
  static const String reminderHourKey = 'reminder_hour';
  static const String reminderMinuteKey = 'reminder_minute';
  static const String streakReminderKey = 'streak_reminder_enabled';
  static const String goalReminderKey = 'goal_reminder_enabled';
}

/// Provider for notification settings.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsState {
  final bool isLoading;
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;
  final bool streakReminderEnabled;
  final bool goalReminderEnabled;

  const NotificationSettingsState({
    this.isLoading = true,
    this.notificationsEnabled = true,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.streakReminderEnabled = true,
    this.goalReminderEnabled = true,
  });

  NotificationSettingsState copyWith({
    bool? isLoading,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? streakReminderEnabled,
    bool? goalReminderEnabled,
  }) {
    return NotificationSettingsState(
      isLoading: isLoading ?? this.isLoading,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      streakReminderEnabled: streakReminderEnabled ?? this.streakReminderEnabled,
      goalReminderEnabled: goalReminderEnabled ?? this.goalReminderEnabled,
    );
  }

  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier() : super(const NotificationSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        isLoading: false,
        notificationsEnabled: prefs.getBool(NotificationSettings.enabledKey) ?? true,
        reminderHour: prefs.getInt(NotificationSettings.reminderHourKey) ?? 19,
        reminderMinute: prefs.getInt(NotificationSettings.reminderMinuteKey) ?? 0,
        streakReminderEnabled: prefs.getBool(NotificationSettings.streakReminderKey) ?? true,
        goalReminderEnabled: prefs.getBool(NotificationSettings.goalReminderKey) ?? true,
      );
    } catch (e) {
      // SharedPreferences might fail on web after clean, use defaults
      debugPrint('Failed to load settings: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(NotificationSettings.enabledKey, enabled);
    } catch (e) {
      debugPrint('Failed to save setting: $e');
    }
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(NotificationSettings.reminderHourKey, time.hour);
      await prefs.setInt(NotificationSettings.reminderMinuteKey, time.minute);
    } catch (e) {
      debugPrint('Failed to save setting: $e');
    }
    state = state.copyWith(reminderHour: time.hour, reminderMinute: time.minute);
  }

  Future<void> setStreakReminder(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(NotificationSettings.streakReminderKey, enabled);
    } catch (e) {
      debugPrint('Failed to save setting: $e');
    }
    state = state.copyWith(streakReminderEnabled: enabled);
  }

  Future<void> setGoalReminder(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(NotificationSettings.goalReminderKey, enabled);
    } catch (e) {
      debugPrint('Failed to save setting: $e');
    }
    state = state.copyWith(goalReminderEnabled: enabled);
  }
}

/// Settings screen for notification preferences (UC35, UC36).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: settings.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Notifications Section
                _SectionHeader(title: 'Notificações'),
                SwitchListTile(
                  title: const Text('Ativar notificações'),
                  subtitle: const Text('Receba lembretes para estudar'),
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref.read(notificationSettingsProvider.notifier).setNotificationsEnabled(value);
                  },
                ),
                if (settings.notificationsEnabled) ...[
                  ListTile(
                    title: const Text('Horário do lembrete'),
                    subtitle: Text(_formatTime(settings.reminderTime)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showTimePicker(context, ref, settings.reminderTime),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Lembrete de sequência'),
                    subtitle: const Text('Notificar quando a sequência estiver em risco'),
                    value: settings.streakReminderEnabled,
                    onChanged: (value) {
                      ref.read(notificationSettingsProvider.notifier).setStreakReminder(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Lembrete de meta'),
                    subtitle: const Text('Notificar quando a meta diária não foi atingida'),
                    value: settings.goalReminderEnabled,
                    onChanged: (value) {
                      ref.read(notificationSettingsProvider.notifier).setGoalReminder(value);
                    },
                  ),
                ],
                const Divider(height: 32),

                // Preferences Section
                _SectionHeader(title: 'Preferências'),
                ListTile(
                  title: const Text('Idioma'),
                  subtitle: const Text('Idioma do app e conteúdo IA'),
                  leading: const Icon(Icons.language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.settingsLanguage),
                ),
                ListTile(
                  title: const Text('Acessibilidade'),
                  subtitle: const Text('Tamanho de texto, contraste, animações'),
                  leading: const Icon(Icons.accessibility),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.settingsAccessibility),
                ),
                const Divider(height: 32),

                // Account Section
                _SectionHeader(title: 'Conta'),
                ListTile(
                  title: const Text('Assinatura'),
                  subtitle: const Text('Gerenciar plano e créditos IA'),
                  leading: const Icon(Icons.workspace_premium),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.subscriptionSettings),
                ),
                ListTile(
                  title: const Text('Backup e Sincronização'),
                  subtitle: const Text('Fazer backup e restaurar dados'),
                  leading: const Icon(Icons.backup),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.backupManagement),
                ),
                ListTile(
                  title: const Text('Privacidade'),
                  subtitle: const Text('Consentimentos e dados pessoais'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.privacySettings),
                ),
                const Divider(height: 32),

                // Info Section
                _SectionHeader(title: 'Sobre'),
                ListTile(
                  title: const Text('Versão'),
                  subtitle: const Text('1.0.0'),
                  leading: const Icon(Icons.info_outline),
                ),
                ListTile(
                  title: const Text('Study Deck'),
                  subtitle: const Text('Aplicativo de flashcards com repetição espaçada'),
                  leading: const Icon(Icons.school),
                ),
              ],
            ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay currentTime,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: 'Escolha o horário do lembrete',
    );

    if (picked != null) {
      ref.read(notificationSettingsProvider.notifier).setReminderTime(picked);
      if (context.mounted) {
        context.showSnackBar('Horário atualizado para ${_formatTimeOfDay(picked)}');
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
