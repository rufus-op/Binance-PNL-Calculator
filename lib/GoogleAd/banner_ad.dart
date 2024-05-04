import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {

  final AdSize adSize;
  const BannerAdWidget({super.key, required this.adSize});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  String adId = 'ca-app-pub-3355640798916544/7371479478';
  late BannerAd bannerAd;
  initBannerAd() {
    bannerAd = BannerAd(
        size: widget.adSize,
        adUnitId: adId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('On Ad loaded : ${ad.adUnitId} ${ad.responseInfo}');
          },
          onAdFailedToLoad: (ad, error) {
            print('On Ad failed : ${error.message}');
            ad.dispose();
          },
        ),
        request: const AdRequest());
    bannerAd.load();
  }

  @override
  void initState() {
    initBannerAd();
    super.initState();
  }

  @override
  void dispose() {
    bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: bannerAd.size.height.toDouble() + 20,
      width: MediaQuery.of(context).size.width,
      child: AdWidget(ad: bannerAd),
    );
  }
}
