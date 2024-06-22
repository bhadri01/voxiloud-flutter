import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatorSettingsPage extends StatefulWidget {
  const TranslatorSettingsPage({super.key});

  @override
  State<TranslatorSettingsPage> createState() => _TranslatorSettingsPageState();
}

class _TranslatorSettingsPageState extends State<TranslatorSettingsPage> {
  List<String> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguages();
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
        title: const Text('Translator Settings'),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
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
              _clearFilter();
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
