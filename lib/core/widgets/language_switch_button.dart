import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final appLocalizations = AppLocalizations.of(context);
    final isSpanish = localeProvider.languageCode == 'es';

    return Tooltip(
      message: isSpanish ? appLocalizations.switchEnglish : appLocalizations.switchSpanish,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texto ES
          Text(
            'ES',
            style: TextStyle(
              color: isSpanish ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          // Switch
          Switch(
            value: !isSpanish, // true para EN, false para ES
            onChanged: (value) {
              localeProvider.toggleLanguage();
            },
            activeColor: Colors.blueAccent,
          ),
          const SizedBox(width: 8),
          // Texto EN
          Text(
            'EN',
            style: TextStyle(
              color: !isSpanish ? Colors.blueAccent : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}