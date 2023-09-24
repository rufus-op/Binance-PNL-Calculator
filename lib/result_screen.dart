import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen(this.profit);
  double profit;

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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        profit >= 0 ? 'assets/profit.json' : 'assets/loss.json',
                        height: MediaQuery.of(context).size.height * .35,
                      ),
                      Text(
                        '${profit.toStringAsFixed(2)}\$',
                        style: TextStyle(
                            color: profit >= 0.0
                                ? const Color(0xff44b581)
                                : Colors.red,
                            fontSize: 30,
                            fontWeight: FontWeight.w600),
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
