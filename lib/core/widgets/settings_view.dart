import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/language_switch_button.dart';
import '../l10n/app_localizations.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.settings),
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sección de Apariencia
            _buildSection(
              title: appLocalizations.appearance,
              icon: Icons.palette,
              children: [
                _buildSettingItem(
                  title: appLocalizations.darkMode,
                  subtitle: appLocalizations.darkModeDescription,
                  trailing: const ThemeSwitchButton(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sección de Idioma
            _buildSection(
              title: appLocalizations.language,
              icon: Icons.language,
              children: [
                _buildSettingItem(
                  title: appLocalizations.appLanguage,
                  subtitle: appLocalizations.languageDescription,
                  trailing: const LanguageSwitchButton(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Sección de Información
            _buildSection(
              title: appLocalizations.information,
              icon: Icons.info,
              children: [
                _buildInfoItem(
                  title: 'Versión',
                  value: '1.0.0',
                ),
                _buildInfoItem(
                  title: 'Desarrollado por',
                  value: 'LearnHive Team',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la sección
            Row(
              children: [
                Icon(icon, color: Colors.lightBlueAccent),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contenido de la sección
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}