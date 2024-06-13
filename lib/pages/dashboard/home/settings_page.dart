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
  List<String> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    _loadColors();
    _loadSelectedLanguages();
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

  Future<void> _loadSelectedLanguages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguages = prefs.getStringList('selectedLanguages') ?? [];
    });
  }

  Future<void> _saveSelectedLanguages(List<String> languages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedLanguages', languages);
  }

  Future<void> _pickColor(
      String key, Color currentColor, Function(Color) onColorChanged) async {
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

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _LanguagePickerBottomSheet(
        selectedLanguages: _selectedLanguages,
        onSelectionChanged: (selectedLanguages) {
          setState(() {
            _selectedLanguages = selectedLanguages;
          });
          _saveSelectedLanguages(selectedLanguages);
        },
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
            // TTS Settings
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
                  "TTS Settings",
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
            // Translator Settings
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
                  "Translator Settings",
                  style: TextStyle(fontSize: 14),
                )),
            ListTile(
              title: const Text('Preferred Languages'),
              subtitle: Text(_selectedLanguages.join(', ')),
              trailing: const Icon(Icons.language),
              onTap: _showLanguagePicker,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePickerBottomSheet extends StatefulWidget {
  final List<String> selectedLanguages;
  final Function(List<String>) onSelectionChanged;

  const _LanguagePickerBottomSheet({
    required this.selectedLanguages,
    required this.onSelectionChanged,
  });

  @override
  __LanguagePickerBottomSheetState createState() =>
      __LanguagePickerBottomSheetState();
}

class __LanguagePickerBottomSheetState
    extends State<_LanguagePickerBottomSheet> {
  List<Language> languages = [
    Language('Afrikaans', 'af'),
    Language('Albanian', 'sq'),
    Language('Amharic', 'am'),
    Language('Arabic', 'ar'),
    Language('Armenian', 'hy'),
    Language('Assamese', 'as'),
    Language('Aymara', 'ay'),
    Language('Azerbaijani', 'az'),
    Language('Bambara', 'bm'),
    Language('Basque', 'eu'),
    Language('Belarusian', 'be'),
    Language('Bengali', 'bn'),
    Language('Bhojpuri', 'bho'),
    Language('Bosnian', 'bs'),
    Language('Bulgarian', 'bg'),
    Language('Catalan', 'ca'),
    Language('Cebuano', 'ceb'),
    Language('Chinese (Simplified)', 'zh-CN'),
    Language('Chinese (Traditional)', 'zh-TW'),
    Language('Corsican', 'co'),
    Language('Croatian', 'hr'),
    Language('Czech', 'cs'),
    Language('Danish', 'da'),
    Language('Dhivehi', 'dv'),
    Language('Dogri', 'doi'),
    Language('Dutch', 'nl'),
    Language('English', 'en'),
    Language('Esperanto', 'eo'),
    Language('Estonian', 'et'),
    Language('Ewe', 'ee'),
    Language('Filipino (Tagalog)', 'fil'),
    Language('Finnish', 'fi'),
    Language('French', 'fr'),
    Language('Frisian', 'fy'),
    Language('Galician', 'gl'),
    Language('Georgian', 'ka'),
    Language('German', 'de'),
    Language('Greek', 'el'),
    Language('Guarani', 'gn'),
    Language('Gujarati', 'gu'),
    Language('Haitian Creole', 'ht'),
    Language('Hausa', 'ha'),
    Language('Hawaiian', 'haw'),
    Language('Hebrew', 'he'),
    Language('Hindi', 'hi'),
    Language('Hmong', 'hmn'),
    Language('Hungarian', 'hu'),
    Language('Icelandic', 'is'),
    Language('Igbo', 'ig'),
    Language('Ilocano', 'ilo'),
    Language('Indonesian', 'id'),
    Language('Irish', 'ga'),
    Language('Italian', 'it'),
    Language('Japanese', 'ja'),
    Language('Javanese', 'jv'),
    Language('Kannada', 'kn'),
    Language('Kazakh', 'kk'),
    Language('Khmer', 'km'),
    Language('Kinyarwanda', 'rw'),
    Language('Konkani', 'gom'),
    Language('Korean', 'ko'),
    Language('Krio', 'kri'),
    Language('Kurdish', 'ku'),
    Language('Kurdish (Sorani)', 'ckb'),
    Language('Kyrgyz', 'ky'),
    Language('Lao', 'lo'),
    Language('Latin', 'la'),
    Language('Latvian', 'lv'),
    Language('Lingala', 'ln'),
    Language('Lithuanian', 'lt'),
    Language('Luganda', 'lg'),
    Language('Luxembourgish', 'lb'),
    Language('Macedonian', 'mk'),
    Language('Maithili', 'mai'),
    Language('Malagasy', 'mg'),
    Language('Malay', 'ms'),
    Language('Malayalam', 'ml'),
    Language('Maltese', 'mt'),
    Language('Maori', 'mi'),
    Language('Marathi', 'mr'),
    Language('Meiteilon (Manipuri)', 'mni-Mtei'),
    Language('Mizo', 'lus'),
    Language('Mongolian', 'mn'),
    Language('Myanmar (Burmese)', 'my'),
    Language('Nepali', 'ne'),
    Language('Norwegian', 'no'),
    Language('Nyanja (Chichewa)', 'ny'),
    Language('Odia (Oriya)', 'or'),
    Language('Oromo', 'om'),
    Language('Pashto', 'ps'),
    Language('Persian', 'fa'),
    Language('Polish', 'pl'),
    Language('Portuguese (Portugal, Brazil)', 'pt'),
    Language('Punjabi', 'pa'),
    Language('Quechua', 'qu'),
    Language('Romanian', 'ro'),
    Language('Russian', 'ru'),
    Language('Samoan', 'sm'),
    Language('Sanskrit', 'sa'),
    Language('Scots Gaelic', 'gd'),
    Language('Sepedi', 'nso'),
    Language('Serbian', 'sr'),
    Language('Sesotho', 'st'),
    Language('Shona', 'sn'),
    Language('Sindhi', 'sd'),
    Language('Sinhala (Sinhalese)', 'si'),
    Language('Slovak', 'sk'),
    Language('Slovenian', 'sl'),
    Language('Somali', 'so'),
    Language('Spanish', 'es'),
    Language('Sundanese', 'su'),
    Language('Swahili', 'sw'),
    Language('Swedish', 'sv'),
    Language('Tagalog (Filipino)', 'tl'),
    Language('Tajik', 'tg'),
    Language('Tamil', 'ta'),
    Language('Tatar', 'tt'),
    Language('Telugu', 'te'),
    Language('Thai', 'th'),
    Language('Tigrinya', 'ti'),
    Language('Tsonga', 'ts'),
    Language('Turkish', 'tr'),
    Language('Turkmen', 'tk'),
    Language('Twi (Akan)', 'ak'),
    Language('Ukrainian', 'uk'),
    Language('Urdu', 'ur'),
    Language('Uyghur', 'ug'),
    Language('Uzbek', 'uz'),
    Language('Vietnamese', 'vi'),
    Language('Welsh', 'cy'),
    Language('Xhosa', 'xh'),
    Language('Yiddish', 'yi'),
    Language('Yoruba', 'yo'),
    Language('Zulu', 'zu'),
  ];

  List<Language> _filteredLanguages = [];
  List<String> _selectedLanguages = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredLanguages = languages;
    _selectedLanguages = List.from(widget.selectedLanguages);
    _searchController.addListener(_filterLanguages);
  }

  void _filterLanguages() {
    setState(() {
      final searchText = _searchController.text.toLowerCase();
      _filteredLanguages = languages
          .where((lang) => lang.name.toLowerCase().contains(searchText))
          .toList();
    });
  }

  void _clearFilter() {
    setState(() {
      _searchController.clear();
      _filteredLanguages = languages;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLanguages);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Languages',
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearFilter,
                    ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredLanguages.length,
            itemBuilder: (context, index) {
              final language = _filteredLanguages[index];
              final isSelected = _selectedLanguages.contains(language.code);
              return CheckboxListTile(
                title: Text(language.name),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedLanguages.add(language.code);
                    } else {
                      _selectedLanguages.remove(language.code);
                    }
                  });
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              widget.onSelectionChanged(_selectedLanguages);
              Navigator.pop(context);
              _clearFilter(); // Clear filter when save button is pressed
            },
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class Language {
  final String name;
  final String code;

  Language(this.name, this.code);
}
