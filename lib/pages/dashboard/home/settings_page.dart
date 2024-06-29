import 'package:flutter/material.dart';
import 'package:Voxiloud/pages/dashboard/home/settings/translator_settings_page.dart';
import 'package:Voxiloud/pages/dashboard/home/settings/tts_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:Voxiloud/themes/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ListTile(
            title: const Text('Dark Theme'),
            trailing: Switch(
              value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
            ListTile(
              title: const Text('TTS Settings'),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TTSSettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Translator Settings'),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TranslatorSettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}