import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voxiloud/pages/ads/ads.dart';
import 'package:voxiloud/pages/dashboard/tools/translate_page.dart';
import 'package:voxiloud/pages/dashboard/tools/tts_page.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  String extractedText = '';
  String? selectedFilePath;
  String selectedFileName = '';
  bool isFileSelected = false;
  bool _isConvarting = false;
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    _interstitialAdManager.loadAd();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'pdf'],
      allowMultiple: false,
    );

    if (result == null) {
      setState(() {
        extractedText = 'No files selected';
      });
      return;
    }

    setState(() {
      selectedFilePath = result.files.single.path!;
      selectedFileName = result.files.single.name;
      isFileSelected = true;
    });
  }

  Future<void> extractTextFromFile() async {
    setState(() {
      _isConvarting = true;
    });
    if (selectedFilePath == null) {
      setState(() {
        _isConvarting = false;
        extractedText = 'No file selected for extraction';
      });
      return;
    }

    final filePath = selectedFilePath!;
    StringBuffer buffer = StringBuffer();

    if (filePath.endsWith('.docx')) {
      try {
        final bytes = File(filePath).readAsBytesSync();
        final text = docxToText(bytes);
        buffer.writeln(text);
      } catch (e) {
        buffer.writeln('Error reading file: $e');
      }
    } else if (filePath.endsWith('.pdf')) {
      try {
        final text = await ReadPdfText.getPDFtext(filePath);
        buffer.writeln(text);
      } catch (e) {
        buffer.writeln('Error reading file: $e');
      }
    }

    setState(() {
      _isConvarting = false;
      extractedText = buffer.toString().trim();
      _motinorDocsActivity();
    });
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
                              textData: extractedText,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.translate_rounded),
                      title: const Text('Translate'),
                      onTap: () {
                        // Handle TTS tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return TranslatePage(
                              queryParameters: {
                                "text": extractedText,
                              },
                            );
                          }),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share_rounded),
                      title: const Text('Share'),
                      onTap: () {
                        // Share the input text data
                        _interstitialAdManager.showAd(() async {
                          if (extractedText.isNotEmpty) {
                            await Share.share(extractedText);
                          }
                        });

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
                        _interstitialAdManager.showAd((){});
                        _showSaveBottomSheet(context, extractedText);
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
                          extractedText = '';
                          selectedFilePath = '';
                          selectedFileName = '';
                          isFileSelected = false;
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
                              _saveDocs(title);
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

  Future<void> _saveDocs(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final translations = prefs.getStringList('savedActivity') ?? [];
    final translation = {
      'tag': 'docs',
      'title': title,
      'text': extractedText,
      'date': DateTime.now().toString()
    };
    translations.add(jsonEncode(translation));
    await prefs.setStringList('savedActivity', translations);
    _showSnackbar("Saved successfully");
  }

  Future<void> _motinorDocsActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final translations = prefs.getStringList('recentActivity') ?? [];
    final translation = {
      'tag': 'docs',
      'text': extractedText,
      'date': DateTime.now().toString()
    };
    translations.add(jsonEncode(translation));
    await prefs.setStringList('recentActivity', translations);
    _showSnackbar("Activity added");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docs to Text'),
        actions: [
          Visibility(
            visible: extractedText.isNotEmpty,
            child: IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showBottomSheet(context),
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        width: double.infinity,
        height: double.infinity,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 4,
                  ),
                  // Helper section to select the file from the device
                  Visibility(
                    visible: !isFileSelected,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            width: 1,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                      ),
                      child: Column(
                        children: [
                          const Text(
                              "Upload your files to extract the text data from the file."),
                          const SizedBox(
                            height: 12,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _interstitialAdManager.showAd(() {
                                pickFile();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text("Upload File"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isFileSelected,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              width: 1,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary))),
                                  child: Text(
                                    selectedFileName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedFilePath = null;
                                    selectedFileName = '';
                                    isFileSelected = false;
                                    _isConvarting = false;
                                    extractedText = '';
                                  });
                                },
                                icon: Icon(
                                  Iconsax.close_square,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: extractTextFromFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: _isConvarting
                              ? SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          "processing...",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                      child: Text('Extract Text from File'))),
                        ),
                        const SizedBox(height: 12),
                        Visibility(
                          visible: extractedText.isNotEmpty,
                          child: Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.5)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Converted Text"),
                                        Row(
                                          children: [
                                            GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: extractedText));
                                                  _showSnackbar(
                                                      'Copied to clipboard!');
                                                },
                                                child: const Icon(
                                                    Icons.copy_rounded)),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TtsPage(
                                                        textData: extractedText,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                    Icons.voice_chat)),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                      return TranslatePage(
                                                        queryParameters: {
                                                          "text": extractedText
                                                        },
                                                      );
                                                    }),
                                                  );
                                                },
                                                child: const Icon(
                                                    Icons.translate_rounded)),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  _showBottomSheet(context);
                                                },
                                                child: const Icon(
                                                    Icons.more_vert_rounded))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  SizedBox(
                                      width: double.infinity,
                                      child: Text(extractedText)),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAdWidget(),
        ],
      ),
    );
  }
}
