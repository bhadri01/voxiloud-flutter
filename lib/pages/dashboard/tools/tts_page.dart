import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  double _speechRate = 1.0;

  @override
  void initState() {
    super.initState();
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
      _voices = voices.map((voice) {
        return Map<String, String>.from(voice);
      }).toList();
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
    if (_selectedVoice != null) {
      await flutterTts.setVoice({"name": _selectedVoice!});
    }
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
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
            )
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
                            maxLines: null, // Allows for unlimited lines
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter text',
                            ),
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
                          color: Theme.of(context).colorScheme.primaryContainer,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showVoiceSelectionSheet,
                    child: Text('Select Voice'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _showSpeedSelectionSheet,
                    child: Text('Select Speed'),
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

  void _showVoiceSelectionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String? filter;
            List<Map<String, String>> filteredVoices = _voices;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filter = value;
                        filteredVoices = _voices
                            .where((voice) => voice['name']!
                                .toLowerCase()
                                .contains(filter!.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: filteredVoices.map((voice) {
                      return ListTile(
                        title: Text(voice['name']!),
                        onTap: () {
                          setState(() {
                            _selectedVoice = voice['name'];
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('0.5x'),
              onTap: () {
                setState(() {
                  _speechRate = 0.5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('0.75x'),
              onTap: () {
                setState(() {
                  _speechRate = 0.75;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('1.0x'),
              onTap: () {
                setState(() {
                  _speechRate = 1.0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('1.25x'),
              onTap: () {
                setState(() {
                  _speechRate = 1.25;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('1.5x'),
              onTap: () {
                setState(() {
                  _speechRate = 1.5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('2.0x'),
              onTap: () {
                setState(() {
                  _speechRate = 2.0;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

enum TtsState { playing, stopped, paused }
