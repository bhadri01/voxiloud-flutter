import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _primaryBgColor = Colors.yellow;
  Color _secondaryBgColor = Colors.yellow.shade100;
  Color _primaryFgColor = Colors.black;
  Color _secondaryFgColor = Colors.black;
  

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _primaryBgColor =
          Color(prefs.getInt('primaryBgColor') ?? Colors.yellow.value);
      _secondaryBgColor = Color(
          prefs.getInt('secondaryBgColor') ?? Colors.yellow.shade100.value);
      _primaryFgColor =
          Color(prefs.getInt('primaryFgColor') ?? Colors.black.value);
      _secondaryFgColor =
          Color(prefs.getInt('secondaryFgColor') ?? Colors.black.value);
    });
  }

  Future<void> _saveColor(String key, Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, color.value);
  }

  void _pickColor(
      String key, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (Color color) {
              onColorChanged(color);
              _saveColor(key, color);
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Select'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
            // it's a tts settings
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer))),
                child: const Text(
                  "TTS",
                  style: TextStyle(fontSize: 14),
                )),
            ListTile(
              title: const Text('Primary Background Color'),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _primaryBgColor,
                ),
                width: 30,
                height: 30,
              ),
              onTap: () =>
                  _pickColor('primaryBgColor', _primaryBgColor, (color) {
                setState(() {
                  _primaryBgColor = color;
                });
              }),
            ),
            ListTile(
              title: const Text('Secondary Background Color'),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _secondaryBgColor,
                ),
                width: 30,
                height: 30,
              ),
              onTap: () =>
                  _pickColor('secondaryBgColor', _secondaryBgColor, (color) {
                setState(() {
                  _secondaryBgColor = color;
                });
              }),
            ),
            ListTile(
              title: const Text('Primary Foreground Color'),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _primaryFgColor,
                ),
                width: 30,
                height: 30,
              ),
              onTap: () =>
                  _pickColor('primaryFgColor', _primaryFgColor, (color) {
                setState(() {
                  _primaryFgColor = color;
                });
              }),
            ),
            ListTile(
              title: const Text('Secondary Foreground Color'),
              trailing: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: _secondaryFgColor,
                ),
                width: 30,
                height: 30,
              ),
              onTap: () =>
                  _pickColor('secondaryFgColor', _secondaryFgColor, (color) {
                setState(() {
                  _secondaryFgColor = color;
                });
              }),
            ),
            // it's a translate settings
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 0.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer))),
                child: const Text(
                  "Translate",
                  style: TextStyle(fontSize: 14),
                )),
          ],
        ),
      ),
    );
  }
}
