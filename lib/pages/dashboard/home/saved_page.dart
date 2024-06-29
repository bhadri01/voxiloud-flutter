import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Voxiloud/pages/dashboard/tools/translate_page.dart';
import 'package:Voxiloud/pages/dashboard/tools/tts_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late Future<List<SavedData>> _futureSavedTranslations;
  late Future<List<String>> _futureDownloadedAudios;
  int _activeState = 1; // 1: Saved Activity, 2: Downloaded Audio

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
                      leading: const Icon(Icons.save_rounded),
                      title: const Text(
                        'Saved Activity',
                      ),
                      onTap: () {
                        setState(() {
                          _activeState = 1;
                        });
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.headset_rounded),
                      title: const Text(
                        'Downloaded Audio',
                      ),
                      onTap: () async {
                        setState(() {
                          _activeState = 2;
                          _futureDownloadedAudios = getDownloadedAudioList();
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

  Future<Directory> _getMusicDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final musicDirectory = Directory('${directory.path}/Music');

    if (!(await musicDirectory.exists())) {
      await musicDirectory.create(recursive: true);
    } // Debug print
    return musicDirectory;
  }

  Future<List<String>> getDownloadedAudioList() async {
    try {
      final musicDirectory = await _getMusicDirectory();

      // Print the directory path for debugging
      print('Listing Entities in Music Directory Path: ${musicDirectory.path}');

      if (!await musicDirectory.exists()) {
        print('Music directory does not exist');
        return []; // Return an empty list if the directory does not exist
      }

      // List and print all entities in the music directory for debugging
      final entities = musicDirectory.listSync();
      print('Entities in Music Directory: $entities');

      final audioFiles = entities
          .where((entity) {
            print('Entity: ${entity}'); // Print each entity path
            return entity is File && entity.path.endsWith('.mp3');
          }) // Filter for audio files
          .map((entity) => entity.path)
          .toList();

      print('Audio files: $audioFiles'); // Debug print
      return audioFiles;
    } catch (e) {
      print('Error retrieving audio list: $e');
      return []; // Return an empty list in case of an error
    }
  }

  @override
  void initState() {
    super.initState();
    _futureSavedTranslations = _getSavedTranslations();
    _futureDownloadedAudios =
        Future.value([]); // Initialize with empty list for downloaded audio
  }

  Future<List<SavedData>> _getSavedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final translations = prefs.getStringList('savedActivity') ?? [];
    return translations.reversed.map((translation) {
      return SavedData.fromJson(jsonDecode(translation));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _activeState == 1
            ? const Text(
                'Saved Activity',
                style: TextStyle(fontSize: 18),
              )
            : const Text(
                'Download Audio',
                style: TextStyle(fontSize: 18),
              ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert_rounded),
        //     onPressed: () => _showBottomSheet(context),
        //   ),
        // ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: _activeState == 1
            ? FutureBuilder<List<SavedData>>(
                future: _futureSavedTranslations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Icon(
                          Iconsax.empty_wallet_change,
                          size: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No saved activity found.'),
                        ),
                      ],
                    ));
                  } else {
                    final translations = snapshot.data!;
                    return ListView.builder(
                      itemCount: translations.length,
                      itemBuilder: (context, index) {
                        final translation = translations[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (translation.tag == "translate") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return TranslatePage(
                                                queryParameters: {
                                                  "text": translation.text,
                                                  "translatedName": translation
                                                      .translatedName as String,
                                                  "translatedCode": translation
                                                      .translatedCode as String
                                                },
                                              );
                                            }),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return TtsPage(
                                                textData: translation.text,
                                              );
                                            }),
                                          );
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 6),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      width: 1,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.5))),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary
                                                                .withOpacity(
                                                                    0.5)),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 8,
                                                            width: 8,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 4),
                                                            child: Text(
                                                              translation.tag,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6),
                                                      child: Text(
                                                        translation.title[0]
                                                                .toUpperCase() +
                                                            translation.title
                                                                .substring(1),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                              if (translation
                                                                      .tag ==
                                                                  "translate") {
                                                                return TtsPage(
                                                                  textData: translation
                                                                          .translatedText
                                                                      as String,
                                                                );
                                                              } else {
                                                                return TtsPage(
                                                                  textData:
                                                                      translation
                                                                          .text,
                                                                );
                                                              }
                                                            }),
                                                          );
                                                        },
                                                        child: const Icon(
                                                            Icons.voice_chat)),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                              if (translation
                                                                      .tag ==
                                                                  "translate") {
                                                                return TranslatePage(
                                                                  queryParameters: {
                                                                    "text":
                                                                        translation
                                                                            .text,
                                                                    "translatedName":
                                                                        translation.translatedName
                                                                            as String,
                                                                    "translatedCode":
                                                                        translation.translatedCode
                                                                            as String
                                                                  },
                                                                );
                                                              } else {
                                                                return TranslatePage(
                                                                  queryParameters: {
                                                                    "text":
                                                                        translation
                                                                            .text,
                                                                  },
                                                                );
                                                              }
                                                            }),
                                                          );
                                                        },
                                                        child: const Icon(Icons
                                                            .translate_rounded)),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          showModalBottomSheet(
                                                            context: context,
                                                            isDismissible:
                                                                false,
                                                            builder: (context) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            16),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    ListTile(
                                                                      leading:
                                                                          const Icon(
                                                                              Icons.voice_chat),
                                                                      title: const Text(
                                                                          'TTS'),
                                                                      onTap:
                                                                          () {
                                                                        // Handle TTS tap
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(builder:
                                                                              (context) {
                                                                            if (translation.tag ==
                                                                                "translate") {
                                                                              return TtsPage(
                                                                                textData: translation.translatedText as String,
                                                                              );
                                                                            } else {
                                                                              return TtsPage(
                                                                                textData: translation.text,
                                                                              );
                                                                            }
                                                                          }),
                                                                        );
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          const Icon(
                                                                              Icons.translate_rounded),
                                                                      title: const Text(
                                                                          'Translate'),
                                                                      onTap:
                                                                          () {
                                                                        // Handle translate tap
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(builder:
                                                                              (context) {
                                                                            if (translation.tag ==
                                                                                "translate") {
                                                                              return TranslatePage(
                                                                                queryParameters: {
                                                                                  "text": translation.text,
                                                                                  "translatedName": translation.translatedName as String,
                                                                                  "translatedCode": translation.translatedCode as String
                                                                                },
                                                                              );
                                                                            } else {
                                                                              return TranslatePage(
                                                                                queryParameters: {
                                                                                  "text": translation.text,
                                                                                },
                                                                              );
                                                                            }
                                                                          }),
                                                                        );
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          const Icon(
                                                                              Icons.share_rounded),
                                                                      title: const Text(
                                                                          'Share'),
                                                                      onTap:
                                                                          () async {
                                                                        // Handle share tap
                                                                        if (translation.tag ==
                                                                            "translate") {
                                                                          await Share.share(translation.translatedText
                                                                              as String);
                                                                        } else {
                                                                          await Share.share(
                                                                              translation.text);
                                                                        }
                                                                        // ignore: use_build_context_synchronously
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading:
                                                                          Icon(
                                                                        Icons
                                                                            .delete_rounded,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .error,
                                                                      ),
                                                                      title:
                                                                          Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Theme.of(context).colorScheme.error),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        final prefs =
                                                                            SharedPreferences.getInstance();
                                                                        prefs.then(
                                                                            (value) {
                                                                          final list =
                                                                              value.getStringList('savedActivity');
                                                                          if (list !=
                                                                              null) {
                                                                            list.removeAt((list.length - 1) -
                                                                                index);
                                                                            value.setStringList('savedActivity',
                                                                                list);
                                                                            setState(() {
                                                                              _futureSavedTranslations = _getSavedTranslations();
                                                                            });
                                                                            Navigator.pop(context);
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                    ListTile(
                                                                      leading: Icon(
                                                                          Icons
                                                                              .close_rounded,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .tertiary),
                                                                      title:
                                                                          const Text(
                                                                        'Close'
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: const Icon(
                                                            Icons.more_vert))
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            translation.text,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            height: 1,
                                          ),
                                          Text(
                                            translation.date.split('.')[0],
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              )
            : FutureBuilder<List<String>>(
                future: _futureDownloadedAudios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Icon(
                          Iconsax.empty_wallet_change,
                          size: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No audios found.'),
                        ),
                      ],
                    ));
                  } else {
                    final audioFiles = snapshot.data!;
                    return ListView.builder(
                      itemCount: audioFiles.length,
                      itemBuilder: (context, index) {
                        final audioPath = audioFiles[index];
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title:
                              Text(audioPath.split('/').last), // Get filename
                          onTap: () async {
                            // Handle audio playback functionality
                            // (use a suitable audio player library)
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.share_rounded),
                            onPressed: () async {
                              await Share.shareUri(audioPath as Uri);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
      ),
    );
  }
}

class SavedData {
  final String tag;
  final String title;
  final String text;
  final String? translatedText;
  final String? translatedName;
  final String? translatedCode;
  final String date;

  SavedData({
    required this.tag,
    required this.title,
    required this.text,
    this.translatedText,
    this.translatedName,
    this.translatedCode,
    required this.date,
  });

  factory SavedData.fromJson(Map<String, dynamic> json) {
    return SavedData(
      tag: json['tag'],
      title: json['title'],
      text: json['text'],
      translatedText: json['translatedText'],
      translatedName: json['translatedName'],
      translatedCode: json['translatedCode'],
      date: json['date'],
    );
  }
}
