import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:socio_calcu/GoogleAd/banner_ad.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen(
      {super.key,
      required this.profit,
      required this.stopLoss,
      required this.isFutures,
      required this.entryPrice,
      required this.liquidationPrice});
  final double profit;
  final double liquidationPrice;
  final double stopLoss;
  final double entryPrice;
  final bool isFutures;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090c22),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff090c22),
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
              size: 18,
            )),
        title: const Text(
          'PNL (Profit and Loss)',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                BannerAdWidget(adSize: AdSize.banner),
                Container(
                  height: MediaQuery.of(context).size.height * .6,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20, top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LottieBuilder.asset(
                          profit >= 0
                              ? 'assets/profit-animation-green.json'
                              : 'assets/loss.json',
                          height: MediaQuery.of(context).size.height * .4,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child:  Text(
                              'Profit/Loss $entryPrice',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Text(
                              '${profit.toStringAsFixed(2)}\$',
                              style: TextStyle(
                                  color: profit >= 0.0
                                      ? const Color(0xff44b581)
                                      : Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      if (isFutures) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: const Text(
                                'Liquidation',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Text(
                                '${liquidationPrice.toStringAsFixed(2)}\$',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: const Text(
                              'StopLoss',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Text(
                              '${stopLoss.toStringAsFixed(2)}\$',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Re-Calculate',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                const SizedBox(
                  height: 8,
                ),
                const SizedBox(
                  height: 60,
                  child: Text(
                    'Use the code ”722626479” when opening your Binance Futures account and receive a 20% fee discount.',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
