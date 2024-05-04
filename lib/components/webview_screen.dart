import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  WebViewScreen({required this.websiteUrl});
final  String websiteUrl;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  String adId = 'ca-app-pub-3355640798916544/7371479478';
  late BannerAd bannerAd;
  bool isAdLoaded = false; // Add a flag to track if the ad has loaded
  initBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: adId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              isAdLoaded = true; // Set the flag to true when the ad loads
            });
          },
          onAdFailedToLoad: (ad, error) {
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
    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.websiteUrl));
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black12),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
            ),
            if (isAdLoaded) // Only display the ad if it has loaded
              Positioned(
                bottom: 10,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 5,
                  ),
                  color: Colors.white,
                  height: bannerAd.size.height.toDouble(),
                  width: double.infinity,
                  child: Center(child: AdWidget(ad: bannerAd)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
