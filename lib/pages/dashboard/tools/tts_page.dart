import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voxiloud/pages/dashboard/tools/translate_page.dart';
import 'package:path_provider/path_provider.dart';

class TtsPage extends StatefulWidget {
  const TtsPage({super.key, this.textData = ""});
  final String textData;

  @override
  State<TtsPage> createState() => _TtsPageState();
}

class _TtsPageState extends State<TtsPage> {
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  bool _isEditing = true;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  List<String> _textPara = [];
  int _paraIndex = 0;
  int _startOffset = 0;
  int _endOffset = 0;
  List<Map<String, String>> _voices = [];
  String? _selectedVoice;
  List<Map<String, String>> filteredVoices = [];
  double _speechRate = 0.5;

  Future<void> requestPermissions(BuildContext context) async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      // Permission is already granted
      print("Storage permission already granted.");
    } else if (status.isDenied) {
      // Permission is denied but not permanently
      if (await Permission.storage.request().isGranted) {
        print("Storage permission granted after request.");
      } else {
        _showPermissionDeniedDialog(context);
      }
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied
      _showPermissionPermanentlyDeniedDialog(context);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
              'Storage permission is needed to save and retrieve audio files. Please grant the permission.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Permanently Denied'),
          content: Text(
              'Storage permission has been permanently denied. Please enable it from the app settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    requestPermissions(context);
    flutterTts = FlutterTts();
    _textController = TextEditingController(text: widget.textData);
    textProcess();

    _getVoices();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      if (_paraIndex == _textPara.length - 1) {
        setState(() {
          ttsState = TtsState.stopped;
          _startOffset = 0;
          _endOffset = 0;
          _paraIndex = 0;
        });
      } else {
        setState(() {
          _paraIndex++;
          _startOffset = 0;
          _endOffset = 0;
        });
        _speak();
      }
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
        _startOffset = 0;
        _endOffset = 0;
        _paraIndex = 0;
      });
    });

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      setState(() {
        _startOffset = startOffset;
        _endOffset = endOffset;
      });
    });
  }

  Future<void> _getVoices() async {
    List<dynamic> voices = await flutterTts.getVoices;
    setState(() {
      _voices = voices.map((voice) => Map<String, String>.from(voice)).toList();
      filteredVoices = _voices;
      if (_voices.isNotEmpty) {
        _selectedVoice = _voices.first['name'];
      }
    });
  }

  void textProcess() {
    String input = _textController.text;
    RegExp regExp = RegExp(r'[\n.]');
    _textPara = input.split(regExp);
  }

  Future _speak() async {
    await flutterTts.setVoice({"name": _selectedVoice!});
    await flutterTts.setSpeechRate(_speechRate);

    if (ttsState == TtsState.paused) {
      var textToSpeak = _textPara[_paraIndex].substring(_startOffset);
      var result = await flutterTts.speak(textToSpeak);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    } else if (_paraIndex < _textPara.length) {
      textProcess();
      setState(() {
        _isEditing = false;
      });

      var textToSpeak = _textPara[_paraIndex].substring(_startOffset);
      var result = await flutterTts.speak(textToSpeak);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    } else {
      setState(() {
        ttsState = TtsState.stopped;
        _startOffset = 0;
        _endOffset = 0;
        _paraIndex = 0;
      });
    }
  }

  Future _pause() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      setState(() {
        ttsState = TtsState.paused;
      });
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      setState(() {
        ttsState = TtsState.stopped;
        _startOffset = 0;
        _endOffset = 0;
        _paraIndex = 0;
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      _stop();
      if (_isEditing) {
        _dismissKeyboard();
      }
    });
  }

  void _nextPara() {
    if (_paraIndex < _textPara.length - 1) {
      setState(() {
        _paraIndex++;
        _startOffset = 0;
        _endOffset = 0;
      });
    }
  }

  void _prevPara() {
    if (_paraIndex > 0) {
      setState(() {
        _paraIndex--;
        _startOffset = 0;
        _endOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS'),
        actions: [
          Row(
            children: [
              Visibility(
                visible: !_isEditing,
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: _toggleEditing,
                ),
              ),
              Visibility(
                visible: !_isEditing,
                child: IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () => _showBottomSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          width: double.infinity,
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  if (_isEditing)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            minLines: 10,
                            maxLines: null, // Allows for unlimited lines
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter text',
                                alignLabelWithHint: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (!_isEditing)
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: _highlightText(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: () => _showVoiceSelectionSheet(context),
                      child: const Column(
                        children: [
                          Icon(
                            Iconsax.voice_cricle,
                            size: 26,
                          ),
                          Text(
                            'voice',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _prevPara,
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          size: 26,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Theme.of(context).colorScheme.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              ttsState == TtsState.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              size: 26,
                            ),
                            onPressed: () {
                              if (ttsState == TtsState.playing) {
                                _pause();
                              } else {
                                _speak();
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _nextPara,
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: _showSpeedSelectionSheet,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.speed_rounded,
                            size: 26,
                          ),
                          Text(
                            '${_speechRate.toString()}x',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _highlightText() {
    List<TextSpan> spans = [];

    for (int i = 0; i < _textPara.length; i++) {
      String para = _textPara[i];

      if (i == _paraIndex) {
        // Current paragraph to highlight
        if (_startOffset > para.length) _startOffset = para.length;
        if (_endOffset > para.length) _endOffset = para.length;

        var startWord = para.substring(0, _startOffset);
        var currentWord = para.substring(_startOffset, _endOffset);
        var endWord = para.substring(_endOffset);

        spans.add(TextSpan(
          text: startWord,
          style: TextStyle(
            backgroundColor: Colors.yellow[100],
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ));

        spans.add(TextSpan(
          text: currentWord,
          style: TextStyle(
              backgroundColor: Colors.yellow,
              color: Theme.of(context).colorScheme.scrim,
              fontWeight: FontWeight.w500),
        ));

        spans.add(TextSpan(
          text: endWord,
          style: TextStyle(
            backgroundColor: Colors.yellow[100],
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ));
      } else {
        // Other paragraphs
        spans.add(TextSpan(
          text: para,
          style: TextStyle(
            backgroundColor: Colors.transparent,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ));
      }

      if (i != _textPara.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  void _filterVoices(String query) {
    setState(() {
      filteredVoices = _voices
          .where((voice) =>
              voice['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showVoiceSelectionSheet(BuildContext context) {
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
                            _filterVoices(value);
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
                        itemCount: filteredVoices.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            value:
                                _selectedVoice == filteredVoices[index]['name'],
                            title: Text(filteredVoices[index]['name']!),
                            onChanged: (value) {
                              setState(() {
                                _selectedVoice = filteredVoices[index]['name'];
                              });
                              // Unfocus the input field
                              FocusScope.of(context).unfocus();
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            secondary:
                                _selectedVoice == filteredVoices[index]['name']
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

  void _showSpeedSelectionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // List of speed values
        final List<double> speedValues = [
          0.1,
          0.2,
          0.3,
          0.4,
          0.5,
          0.6,
          0.7,
          0.8,
          0.9,
          1.0,
          1.25,
          1.5,
          1.75,
          2.0
        ];

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: speedValues.map((speed) {
              return ListTile(
                title: Text('${speed}x'),
                trailing: _speechRate == speed
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _speechRate = speed;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    _stop();
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
                      leading: const Icon(Icons.translate_rounded),
                      title: const Text('Translate'),
                      onTap: () {
                        // Handle TTS tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TranslatePage(
                              queryParameters: {
                                "text": _textController.text,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: const Text('Download Audio'),
                      onTap: () {
                        // Navigate to the TTS route with the input text data
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                        _convertTextToSpeech();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share_rounded),
                      title: const Text('Share'),
                      onTap: () async {
                        // Share the input text data
                        if (_textController.text.isNotEmpty) {
                          await Share.share(_textController.text);
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
                        _showSaveBottomSheet(context);
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

  void _showSaveBottomSheet(BuildContext context) {
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
                              _saveTTS(title);
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

  Future<void> _saveTTS(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final translations = prefs.getStringList('savedActivity') ?? [];
    final translation = {
      'tag': 'translate',
      'title': title,
      'text': _textController.text,
      'date': DateTime.now().toString()
    };
    translations.add(jsonEncode(translation));
    await prefs.setStringList('savedActivity', translations);
    _showSnackbar("Saved successfully");
  }

  void _showSnackbar(String text) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
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

  Future<Directory> _getMusicDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final musicDirectory = Directory('${directory.path}/Music');

    if (!(await musicDirectory.exists())) {
      await musicDirectory.create(recursive: true);
    }

    print('Music Directory Path: ${musicDirectory.path}'); // Debug print
    return musicDirectory;
  }

  Future<void> _convertTextToSpeech() async {
    final FlutterTts flutterTts = FlutterTts();
    final text = _textController.text;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter text to convert.'),
      ));
      return;
    }

    try {
      // Get the music directory
      final musicDirectory = await _getMusicDirectory();
      final musicDirPath = musicDirectory.path; // Extract the path

      Future<String> getNextAvailableFilename({
        required String baseName, // Base part of the filename
        required String dirPath, // Path to directory
      }) async {
        int count = 1;
        String filePath;
        do {
          filePath = '$dirPath/$baseName$count.mp3';
          count++;
        } while (await File(filePath).exists());
        return filePath; // Return the complete file path
      }

      // Generate a unique filename
      final filePath = await getNextAvailableFilename(
          baseName: 'voxiloud_audio', dirPath: musicDirPath);

      // Configure TTS settings
      await flutterTts.setVoice({"name": _selectedVoice!});
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      // Synthesize text to speech and save to file
      await flutterTts.synthesizeToFile(text, filePath);

      _showSnackbar('Audio saved to $filePath');
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${error.toString()}'),
      ));
    }
  }
}

enum TtsState { playing, stopped, paused }
