// lib/pages/dashboard/tools/docs_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:language_detector/language_detector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voxiloud/pages/dashboard/tools/tts_page.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key, this.queryParameters});
  final Map<String, String>? queryParameters;
  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _textController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();

  String _inputData = "";
  String _fromLanguageCode = "";
  String _fromLanguageName = "";
  String _toLanguageCode = "";
  String _toLanguageName = "";
  String _previouslySelectedLanguageCode = "";
  String _previouslySelectedLanguageName = "";
  String _translatedString = "";
  bool _isTranslating = false;

  String _limitInputData(String input) {
    List<String> words = input.split(' ');
    if (words.length > 10) {
      return words.sublist(0, 10).join(' ');
    } else {
      return input;
    }
  }

  void _onTextChanged(String text) async {
    setState(() {
      _inputData = text;
    });
    if (text.isNotEmpty) {
      _fromLanguageCode = await LanguageDetector.getLanguageCode(
          content: _limitInputData(text));
      _fromLanguageName = await LanguageDetector.getLanguageName(
          content: _limitInputData(text));
      if (_fromLanguageName == "Automatic") {
        _fromLanguageName = "English";
      }
      setState(() {});
    }
  }

  void _translate() async {
    FocusScope.of(context).unfocus();
    if (_inputData.isNotEmpty) {
      if (_fromLanguageCode.isNotEmpty &&
          _fromLanguageName.isNotEmpty &&
          _toLanguageCode.isNotEmpty &&
          _toLanguageName.isNotEmpty) {
        setState(() {
          _isTranslating = true;
        });
        try {
          final translation = await _translator.translate(
            _inputData,
            from: _fromLanguageCode,
            to: _toLanguageCode,
          );
          setState(() {
            _translatedString = translation.text;
            _isTranslating = false;
          });
          // for every action this will add has a recent activity
          _motinorTranslationActivity();
        } catch (e) {
          _showSnackbar("Error translating text: $e");
          setState(() {
            _translatedString = "";
            _isTranslating = false;
          });
        }
      } else {
        _showSnackbar(
            "Please select a language and ensure the translator is initialized");
      }
    } else {
      _showSnackbar("Input is empty");
      setState(() {
        _translatedString = "";
      });
    }
  }

  void _showSnackbar(String text) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 1),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      content: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );

    // Find the ScaffoldMessenger in the widget tree and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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

  List<Language> filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    filteredLanguages = languages;
    if (widget.queryParameters != null) {
      _onTextChanged(widget.queryParameters!['text'] ?? "");
      _toLanguageName = widget.queryParameters!['translatedName'] ?? "";
      _toLanguageCode = widget.queryParameters!['translatedCode'] ?? "";
    }
  }

  void _filterLanguages(String query) {
    setState(() {
      filteredLanguages = languages
          .where((language) =>
              language.name.toLowerCase().contains(query.toLowerCase()) ||
              language.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 0.8 * MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _filterLanguages(value);
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredLanguages.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            value: _toLanguageCode ==
                                filteredLanguages[index].code,
                            title: Text(filteredLanguages[index].name),
                            onChanged: (value) {
                              _toLanguageName = filteredLanguages[index].name;
                              _toLanguageCode = filteredLanguages[index].code;
                              // Unfocus the input field
                              FocusScope.of(context).unfocus();
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            secondary:
                                _toLanguageCode == filteredLanguages[index].code
                                    ? const Icon(Icons.check)
                                    : null,
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _toLanguageCode = _previouslySelectedLanguageCode;
                              _toLanguageName = _previouslySelectedLanguageName;
                              FocusScope.of(context).unfocus();
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _previouslySelectedLanguageCode = _toLanguageCode;
                              _previouslySelectedLanguageName = _toLanguageName;
                              FocusScope.of(context).unfocus();
                            },
                            child: const Text('Select'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.voice_chat),
                      title: const Text('TTS'),
                      onTap: () {
                        // Handle TTS tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TtsPage(
                              textData: _translatedString,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share_rounded),
                      title: const Text('Share'),
                      onTap: () async {
                        // Share the input text data
                        if (_translatedString.isNotEmpty) {
                          await Share.share(_translatedString);
                        }

                        // ignore: use_build_context_synchronously
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.save_rounded),
                      title: const Text('Save'),
                      onTap: () {
                        // Navigate to the TTS route with the input text data
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                        _showSaveBottomSheet(context, _translatedString);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.delete_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        "Delete",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      onTap: () {
                        // Clear the input text data
                        setState(() {
                          _inputData = "";
                          _fromLanguageCode = "";
                          _fromLanguageName = "";
                          _toLanguageCode = "";
                          _toLanguageName = "";
                          _previouslySelectedLanguageCode = "";
                          _previouslySelectedLanguageName = "";
                          _translatedString = "";
                          _isTranslating = false;
                        });
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      title: Text(
                        'Close',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the TTS route with the input text data
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSaveBottomSheet(BuildContext context, String translatedText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        String title = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                          width: double.infinity, child: Text("Save as")),
                    ),
                    SizedBox(
                      height: 50, // Set the height to 50
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            title = value;
                          });
                        }, // Set the maximum number of lines to 1
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              FocusScope.of(context).unfocus();
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              // Save the translation with the title
                              Navigator.pop(context);
                              FocusScope.of(context).unfocus();
                              _saveTranslation(title);
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveTranslation(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final translations = prefs.getStringList('savedActivity') ?? [];
    final translation = {
      'tag': 'translate',
      'title': title,
      'text': _inputData,
      'translatedText': _translatedString,
      'translatedName': _toLanguageName,
      'translatedCode': _toLanguageCode,
      'date': DateTime.now().toString()
    };
    translations.add(jsonEncode(translation));
    await prefs.setStringList('savedActivity', translations);
    _showSnackbar("Saved successfully");
  }

  Future<void> _motinorTranslationActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final translations = prefs.getStringList('recentActivity') ?? [];
    final translation = {
      'tag': 'translate',
      'text': _inputData,
      'translatedText': _translatedString,
      'translatedName': _toLanguageName,
      'translatedCode': _toLanguageCode,
      'date': DateTime.now().toString()
    };
    translations.add(jsonEncode(translation));
    await prefs.setStringList('recentActivity', translations);
    _showSnackbar("Activity added");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        appBar: AppBar(
          title: const Text('Translate'),
          actions: [
            Visibility(
              visible: _translatedString.isNotEmpty,
              child: IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => _showBottomSheet(context),
              ),
            ),
          ],
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: SizedBox(
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 5,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer),
                                  onPressed: () {},
                                  child: Text(
                                      _fromLanguageCode.isNotEmpty
                                          // ignore: unnecessary_string_interpolations
                                          ? "$_fromLanguageName"
                                          : "Auto Detect",
                                      style: const TextStyle(fontSize: 12)))),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.switch_left_rounded),
                          ),
                          Expanded(
                              flex: 5,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer),
                                  onPressed: () => _showLanguagePicker(context),
                                  child: Text(
                                    _toLanguageName.isNotEmpty
                                        ? _toLanguageName
                                        : "Select language",
                                    style: const TextStyle(fontSize: 12),
                                  ))),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                          controller: _textController..text = _inputData,
                          onChanged: _onTextChanged,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            labelText: 'Enter text to translate',
                            border: OutlineInputBorder(),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary),
                          onPressed: _isTranslating ? null : _translate,
                          child: _isTranslating
                              ? const SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      "Translate",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: _translatedString.isNotEmpty,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.5)),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _translatedString,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

// language selection area
class LanguageChooseFromTo extends StatelessWidget {
  const LanguageChooseFromTo({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor:
                Theme.of(context).colorScheme.onSecondaryContainer),
        onPressed: () {},
        child: Text(
          title,
        ));
  }
}

class Language {
  final String name;
  final String code;

  Language(this.name, this.code);
}
