import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen(
      {super.key,
      required this.profit,
      required this.stopLoss,
      required this.isFutures,
      required this.liquidationPrice});
  final double profit;
  final double liquidationPrice;
  final double stopLoss;
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
                Container(
                  height: MediaQuery.of(context).size.height * .65,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        profit >= 0
                            ? 'assets/profit-animation.json'
                            : 'assets/loss.json',
                        height: MediaQuery.of(context).size.height * .45,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Text(
                              'P/L :',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${profit.toStringAsFixed(2)}\$',
                            style: TextStyle(
                                color: profit >= 0.0
                                    ? const Color(0xff44b581)
                                    : Colors.red,
                                fontSize: 26,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (isFutures) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: const Text(
                                'Liquidation :',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${liquidationPrice.toStringAsFixed(2)}\$',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: const Text(
                              'StopLoss :',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${stopLoss.toStringAsFixed(2)}\$',
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 26,
                                fontWeight: FontWeight.w500),
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
