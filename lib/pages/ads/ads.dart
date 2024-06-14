import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          // ignore: avoid_print
          print('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isAdLoaded,
      child: Container(
        color: Theme.of(context).cardColor,
        width: double.infinity,
        height: _bannerAd.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd),
      ),
    );
  }
}

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            // ignore: avoid_print
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('Ad showed fullscreen content.'),
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              // ignore: avoid_print
              print('Ad failed to show fullscreen content: $error');
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              // ignore: avoid_print
              print('Ad dismissed fullscreen content.');
              ad.dispose();
              loadAd(); // Load a new ad
            },
            // ignore: avoid_print
            onAdImpression: (InterstitialAd ad) =>
                print('Ad impression occurred.'),
            // ignore: avoid_print
            onAdClicked: (InterstitialAd ad) => print('Ad clicked.'),
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          // ignore: avoid_print
          print('Interstitial ad failed to load: $error');
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showAd(Function onAdDismissed) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        // ignore: avoid_print
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            print('Ad showed fullscreen content.'),
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          // ignore: avoid_print
          print('Ad failed to show fullscreen content: $error');
          ad.dispose();
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          // ignore: avoid_print
          print('Ad dismissed fullscreen content.');
          ad.dispose();
          loadAd(); // Load a new ad
          onAdDismissed(); // Execute the callback function after ad is dismissed
        },
        // ignore: avoid_print
        onAdImpression: (InterstitialAd ad) => print('Ad impression occurred.'),
        // ignore: avoid_print
        onAdClicked: (InterstitialAd ad) => print('Ad clicked.'),
      );
      _interstitialAd!.show();
    } else {
      onAdDismissed(); // Execute the callback immediately if no ad is loaded
    }
  }
}
