// lib/pages/home_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Voxiloud/pages/dashboard/tools/translate_page.dart';
import 'package:Voxiloud/pages/dashboard/tools/tts_page.dart';
import 'package:Voxiloud/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<ActivityData>> fetchRecentActivities() async {
  final prefs = await SharedPreferences.getInstance();
  final recentActivitiesJson = prefs.getStringList('recentActivity') ?? [];
  return recentActivitiesJson.reversed
      .map((e) => ActivityData.fromJson(jsonDecode(e)))
      .toList();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late Future<List<ActivityData>> recentActivities;

  @override
  void initState() {
    super.initState();
    recentActivities = fetchRecentActivities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the route observer
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    setState(() {
      recentActivities = fetchRecentActivities();
    });
  }

  @override
  void dispose() {
    // Unsubscribe from the route observer
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voxiloud',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              size: 26,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 4),
          //   child: IconButton(
          //     icon: const Icon(
          //       Icons.person_rounded,
          //       size: 26,
          //     ),
          //     onPressed: () {},
          //   ),
          // ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  const DashboardComponents(
                    name: "Text to Speech",
                    description: "Convert your text to speech",
                    icon: Icons.voice_chat,
                    location: "/tts",
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const DashboardComponents(
                    name: "Documents to Text",
                    description: "Convert your docx, pdf to text",
                    icon: Icons.document_scanner_rounded,
                    location: "/docs",
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const DashboardComponents(
                    name: "Translate",
                    description: "Translate your Text",
                    icon: Icons.translate_rounded,
                    location: "/translate",
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    "Recent Activity",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  FutureBuilder<List<ActivityData>>(
                    future: recentActivities,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.empty_wallet_change,
                                size: 40,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('No activity found.'),
                              ),
                            ],
                          ),
                        ));
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else {
                        final translations = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: translations.length,
                          itemBuilder: (context, index) {
                            final translation = translations[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (translation.tag ==
                                                "translate") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                                  return TranslatePage(
                                                    queryParameters: {
                                                      "text": translation.text,
                                                      "translatedName":
                                                          translation
                                                                  .translatedName
                                                              as String,
                                                      "translatedCode":
                                                          translation
                                                                  .translatedCode
                                                              as String
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
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary
                                                                  .withOpacity(
                                                                      0.5))),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                                      textData:
                                                                          translation.translatedText
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
                                                                Icons
                                                                    .voice_chat)),
                                                        const SizedBox(
                                                          width: 8,
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
                                                                            translation.text,
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
                                                                            translation.text,
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
                                                                context:
                                                                    context,
                                                                isDismissible:
                                                                    false,
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            16),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        ListTile(
                                                                          leading:
                                                                              const Icon(Icons.voice_chat),
                                                                          title:
                                                                              const Text('TTS'),
                                                                          onTap:
                                                                              () {
                                                                            // Handle TTS tap
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) {
                                                                                if (translation.tag == "translate") {
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
                                                                              const Icon(Icons.translate_rounded),
                                                                          title:
                                                                              const Text('Translate'),
                                                                          onTap:
                                                                              () {
                                                                            // Handle translate tap
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) {
                                                                                if (translation.tag == "translate") {
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
                                                                              const Icon(Icons.share_rounded),
                                                                          title:
                                                                              const Text('Share'),
                                                                          onTap:
                                                                              () async {
                                                                            // Handle share tap
                                                                            if (translation.tag ==
                                                                                "translate") {
                                                                              await Share.share(translation.translatedText as String);
                                                                            } else {
                                                                              await Share.share(translation.text);
                                                                            }
                                                                            // ignore: use_build_context_synchronously
                                                                            Navigator.pop(context);
                                                                          },
                                                                        ),
                                                                        ListTile(
                                                                          leading:
                                                                              Icon(
                                                                            Icons.delete_rounded,
                                                                            color:
                                                                                Theme.of(context).colorScheme.error,
                                                                          ),
                                                                          title:
                                                                              Text(
                                                                            "Delete",
                                                                            style:
                                                                                TextStyle(color: Theme.of(context).colorScheme.error),
                                                                          ),
                                                                          onTap:
                                                                              () {
                                                                            final prefs =
                                                                                SharedPreferences.getInstance();
                                                                            prefs.then((value) {
                                                                              final list = value.getStringList('recentActivity');
                                                                              if (list != null) {
                                                                                list.removeAt((list.length - 1) - index);
                                                                                value.setStringList('recentActivity', list);
                                                                                setState(() {
                                                                                  recentActivities = fetchRecentActivities();
                                                                                });
                                                                                Navigator.pop(context);
                                                                              }
                                                                            });
                                                                          },
                                                                        ),
                                                                        ListTile(
                                                                          leading: Icon(
                                                                              Icons.close_rounded,
                                                                              color: Theme.of(context).colorScheme.tertiary),
                                                                          title:
                                                                              Text(
                                                                            'Close',
                                                                            style:
                                                                                TextStyle(color: Theme.of(context).colorScheme.tertiary),
                                                                          ),
                                                                          onTap:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: const Icon(
                                                                Icons
                                                                    .more_vert))
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                translation.text,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                translation.date.split('.')[0],
                                                overflow: TextOverflow.ellipsis,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardComponents extends StatelessWidget {
  const DashboardComponents(
      {super.key,
      required this.name,
      required this.description,
      required this.icon,
      required this.location});
  final String name;
  final String description;
  final IconData icon;
  final String location;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, location);
      },
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1.0,
                  color: Colors.grey,
                ),
              ),
            ),
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              icon,
              size: 26,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                Text(
                  description,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// recentActivity

class ActivityData {
  final String tag;
  final String text;
  final String? translatedText;
  final String? translatedName;
  final String? translatedCode;
  final String date;

  ActivityData({
    required this.tag,
    required this.text,
    this.translatedText,
    this.translatedName,
    this.translatedCode,
    required this.date,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      tag: json['tag'],
      text: json['text'],
      translatedText: json['translatedText'],
      translatedName: json['translatedName'],
      translatedCode: json['translatedCode'],
      date: json['date'],
    );
  }
}
