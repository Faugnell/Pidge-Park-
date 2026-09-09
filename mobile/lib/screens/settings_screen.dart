import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.controller,
    required this.onResetProgress,
    required this.onNotificationsChanged,
    super.key,
  });

  final SettingsController controller;
  final Future<void> Function() onResetProgress;
  final Future<void> Function(bool) onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final isFrench = controller.isFrench;

    return ColoredBox(
      color: AppColors.placeholderBackground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Text(
              isFrench ? 'Paramètres' : 'Settings',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _SettingsCard(
              children: [
                _SettingsSwitch(
                  icon: Icons.volume_up_outlined,
                  title: isFrench ? 'Sons' : 'Sounds',
                  value: controller.soundEnabled,
                  onChanged: controller.setSoundEnabled,
                ),
                _SettingsSwitch(
                  icon: Icons.music_note_outlined,
                  title: isFrench ? 'Musique' : 'Music',
                  value: controller.musicEnabled,
                  onChanged: controller.setMusicEnabled,
                ),
                _SettingsSwitch(
                  icon: Icons.vibration,
                  title: isFrench ? 'Vibrations' : 'Vibrations',
                  value: controller.vibrationsEnabled,
                  onChanged: controller.setVibrationsEnabled,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              children: [
                _SettingsSwitch(
                  icon: Icons.notifications_none,
                  title: isFrench ? 'Notifications' : 'Notifications',
                  value: controller.notificationsEnabled,
                  onChanged: onNotificationsChanged,
                ),
                _SettingsTile(
                  key: const ValueKey('language-setting'),
                  icon: Icons.language,
                  title: isFrench ? 'Langue' : 'Language',
                  subtitle: isFrench ? 'Français' : 'English',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _chooseLanguage(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.cloud_outlined,
                  title: isFrench ? 'Sauvegarde' : 'Save data',
                  subtitle: isFrench ? 'Sur cet appareil' : 'On this device',
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: isFrench ? 'Confidentialité' : 'Privacy',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(context),
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: isFrench ? 'Aide & Support' : 'Help & Support',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('reset-progress'),
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.restart_alt),
              label: Text(
                isFrench ? 'Réinitialiser la progression' : 'Reset progress',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB44B42),
                side: const BorderSide(color: Color(0xFFD9A39D)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Pidge Park! · v1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: AppColors.navigationBackground,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: RadioGroup<AppLanguage>(
            groupValue: controller.language,
            onChanged: (value) => Navigator.pop(context, value),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<AppLanguage>(
                  title: Text('Français'),
                  value: AppLanguage.french,
                ),
                RadioListTile<AppLanguage>(
                  title: Text('English'),
                  value: AppLanguage.english,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      await controller.setLanguage(selected);
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final isFrench = controller.isFrench;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isFrench ? 'Réinitialiser la progression ?' : 'Reset progress?',
        ),
        content: Text(
          isFrench
              ? 'Toutes les données locales et les préférences seront effacées.'
              : 'All local data and preferences will be erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isFrench ? 'Annuler' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isFrench ? 'Réinitialiser' : 'Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await controller.resetAllData();
    await onResetProgress();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFrench ? 'Progression réinitialisée.' : 'Progress reset.',
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.isFrench ? 'Bientôt disponible.' : 'Coming soon.',
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navigationBackground,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFD8C9AA)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(height: 1, indent: 52),
          ],
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.selected),
      title: Text(title),
      value: value,
      activeThumbColor: AppColors.navigationBackground,
      activeTrackColor: AppColors.selected,
      onChanged: onChanged,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.selected),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
    );
  }
}
