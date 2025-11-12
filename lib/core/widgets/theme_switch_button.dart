import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.light_mode,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 8),
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.switchTheme();
              },
              activeColor: Colors.blueAccent,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.blueAccent : Colors.grey,
              size: 20,
            ),
          ],
        );
      },
    );
  }
}