import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socio_calcu/GoogleAd/banner_ad.dart';
import 'package:socio_calcu/components/textfield.dart';
import 'package:socio_calcu/components/webview_screen.dart';
import 'package:socio_calcu/result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Brightness _brightness = Brightness.dark;
  bool _isDark = false;
  final _formKey = GlobalKey<FormState>();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _leverageController = TextEditingController();
  bool _isFutures = true;
  bool _isLong = true;
  // bool _isIsolated = true;
  // bool _isUSD_M_Futtures = true;
  bool isSpot = true;
  double _profit = 0;
  double _stopLoss = 0;
  double _liquidationPrice = 0;

// Calculate Profit
  void _calculateProfit() {
    double buyPrice = double.parse(_buyPriceController.text);
    double sellPrice = double.parse(_sellPriceController.text);
    double quantity = double.parse(_quantityController.text);

    double initialMarginRatio =
        1; // Example value, adjust based on actual trading conditions

    double stopLoss = double.parse(_stopLossController.text.trim().isNotEmpty
        ? _stopLossController.text
        : '0');

    double leverage = _isFutures ? double.parse(_leverageController.text) : 1;

    double profit = _isFutures
        ? calculateFuturesProfit(
            buyPrice, sellPrice, quantity, lev(leverage).toDouble(), _isLong)
        : calculateSpotProfit(buyPrice, sellPrice, quantity);
    double liquidationPrice = _isFutures
        ? calculateLiquidationPrice(
            buyPrice, initialMarginRatio, leverage, _isLong)
        : 0.0; // Liquidation price is not applicable for spot trading

    setState(() {
      _profit = profit;
      _liquidationPrice = liquidationPrice;
      _stopLoss = _isFutures
          ? calculateFuturesProfit(
              buyPrice, stopLoss, quantity, lev(leverage).toDouble(), _isLong)
          : calculateSpotProfit(buyPrice, stopLoss, quantity);
    });
  }

// Calculate Liquidation Price
  double calculateLiquidationPrice(double entryPrice, double initialMarginRatio,
      double leverage, bool isLong) {
    return isLong
        ? entryPrice / (1 + (initialMarginRatio / leverage))
        : entryPrice / (1 - (initialMarginRatio / leverage));
  }

// Calculate Spot Profit
  double calculateSpotProfit(
      double buyPrice, double sellPrice, double quantity) {
    double profit = (((1 / buyPrice) - (1 / sellPrice)) * quantity) * sellPrice;
    return profit;
  }

// Handle Leverage
  double lev(double leve) {
    if (leve > 0) {
      return leve;
    }
    return leve = 1;
  }

// Calculate Futures Profit
  double calculateFuturesProfit(double buyPrice, double sellPrice,
      double quantity, double leverage, bool isLong) {
    double profitLong =
        (((1 / buyPrice) - (1 / sellPrice)) * quantity * leverage) * sellPrice;
    double profitShort =
        (((1 / sellPrice) - (1 / buyPrice)) * quantity * leverage) * sellPrice;

    return isLong ? profitLong : profitShort;
  }

// Theme
  Future<void> _loadDarkModeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('isDark') ?? false;
    });
  }

// save theme in shared pref
  Future<void> _saveDarkModeSetting(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDark);
  }

// popup Menu
  final List<String> _popupMenuOptions = [
    'Fear and Greed Index',
    'Liquidation Heatmap',
  ];
  final List<String> _popupMenuWebUrls = [
    'https://alternative.me/crypto/fear-and-greed-index/',
    'https://www.coinglass.com/pro/futures/LiquidationHeatMap',
  ];
  final List<IconData> _popupMenuIcons = [
    Icons.trending_up, // Example icon for Fear and Greed Index
    Icons.waves_rounded, // Example icon for Liquidation Heatmap
  ];

  @override
  void initState() {
    _loadDarkModeSetting();
    super.initState();
  }

  @override
  void dispose() {
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _quantityController.dispose();
    _stopLossController.dispose();
    _leverageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Crypto Calculator",
      theme: ThemeData(
          useMaterial3: true,
          brightness: _isDark ? Brightness.dark : Brightness.light),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Crypto P/L Calculator',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            actions: [
              GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isDark = !_isDark;
                    });
                    await _saveDarkModeSetting(_isDark);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                        _isDark ? Icons.light_mode_outlined : Icons.light_mode),
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: PopupMenuButton<String>(
                  onSelected: (String result) {
                    print(result); // For demonstration purposes
                  },
                  itemBuilder: (BuildContext context) =>
                      _popupMenuOptions.map((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  websiteUrl: _popupMenuWebUrls[
                                      _popupMenuOptions.indexOf(option)],
                                  websiteName: option,
                                ),
                              ));
                        },
                        child: Row(
                          children: [
                            Icon(_popupMenuIcons[_popupMenuOptions.indexOf(
                                option)]), // Display the corresponding icon
                            SizedBox(width: 8), // Space between icon and text
                            Text(option),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity),
                            title: const Text(
                              'Spot',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 17),
                            ),
                            value: false,
                            groupValue: _isFutures,
                            onChanged: (value) {
                              setState(() {
                                isSpot = true;
                                _isFutures = false;
                                _quantityController.clear();
                                _stopLossController.clear();
                                _buyPriceController.clear();
                                _sellPriceController.clear();
                                _profit = 0;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity),
                            title: const Text(
                              'Futures',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 17),
                            ),
                            value: true,
                            groupValue: _isFutures,
                            onChanged: (value) {
                              setState(() {
                                isSpot = false;
                                _isFutures = true;
                                _quantityController.clear();
                                _stopLossController.clear();
                                _buyPriceController.clear();
                                _sellPriceController.clear();
                                _profit = 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    const Text(
                      'Cost / Margin*',
                      style: TextStyle(
                          // color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFieldCustom(quantityController: _quantityController),
                    if (_isFutures)
                      const SizedBox(
                        height: 8,
                      ),
                    if (_isFutures)
                      const Text(
                        'Position*',
                        style: TextStyle(
                            // color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),

                    if (_isFutures)
                      Row(
                        children: [
                          Checkbox(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: _isLong,
                            onChanged: (value) {
                              setState(() {
                                _isLong = true;
                              });
                            },
                          ),
                          const Text(
                            'Long',
                          ),
                          const SizedBox(
                            width: 48,
                          ),
                          Checkbox(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: _isLong ? false : true,
                            onChanged: (value) {
                              setState(() {
                                _isLong = false;
                              });
                            },
                          ),
                          const Text(
                            'Short',
                          ),
                        ],
                      ),
                    ////////////////////// Margin Mode ////////////////////////////////

                    // if (_isFutures)
                    //   const Text(
                    //     'Margin Mode*',
                    //     style: TextStyle(
                    //         // color: Colors.black,
                    //         fontWeight: FontWeight.w500),
                    //   ),
                    // if (_isFutures)
                    //   Row(
                    //     children: [
                    //       Checkbox(
                    //         materialTapTargetSize:
                    //             MaterialTapTargetSize.shrinkWrap,
                    //         value: _isIsolated,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _isIsolated = true;
                    //           });
                    //         },
                    //       ),
                    //       const Text(
                    //         'Isolated',
                    //       ),
                    //       const SizedBox(
                    //         width: 30,
                    //       ),
                    //       Checkbox(
                    //         materialTapTargetSize:
                    //             MaterialTapTargetSize.shrinkWrap,
                    //         value: _isIsolated ? false : true,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _isIsolated = false;
                    //           });
                    //         },
                    //       ),
                    //       const Text(
                    //         'Cross',
                    //       ),
                    //     ],
                    //   ),
                    /////////////////////////////////////////// Leverage//////////////////////
                    if (_isFutures)
                      const Text(
                        'Leverage*',
                        style: TextStyle(
                            // color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (_isFutures)
                      TextFieldCustom(quantityController: _leverageController),
                    const SizedBox(
                      height: 8,
                    ),
                    ///////////////////////// TOF //////////////////////////////////////
                    // if (_isFutures)
                    //   const Text(
                    //     'Type of Futures*',
                    //     style: TextStyle(
                    //         // color: Colors.black,
                    //         fontWeight: FontWeight.w500),
                    //   ),
                    // if (_isFutures)
                    //   Row(
                    //     children: [
                    //       Checkbox(
                    //         materialTapTargetSize:
                    //             MaterialTapTargetSize.shrinkWrap,
                    //         value: _isUSD_M_Futtures,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _isUSD_M_Futtures = true;
                    //           });
                    //         },
                    //       ),
                    //       const Text(
                    //         'USDS-M Futures',
                    //       ),
                    //       const SizedBox(
                    //         width: 20,
                    //       ),
                    //       Checkbox(
                    //         materialTapTargetSize:
                    //             MaterialTapTargetSize.shrinkWrap,
                    //         value: _isUSD_M_Futtures ? false : true,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _isUSD_M_Futtures = false;
                    //           });
                    //         },
                    //       ),
                    //       const Text(
                    //         'COIN-M Futures',
                    //       ),
                    //     ],
                    //   ),
                    const Text(
                      'Entry Price*',
                      style: TextStyle(
                          // color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFieldCustom(quantityController: _buyPriceController),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Exit Price*',
                      style: TextStyle(
                          // color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFieldCustom(quantityController: _sellPriceController),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Stop loss',
                      style: TextStyle(
                          // color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFieldCustom(quantityController: _stopLossController),
                    const SizedBox(
                      height: 10,
                    ),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                            onPressed: () {
                              _isFutures
                                  ? {
                                      if (_leverageController.text.isEmpty ||
                                          _quantityController.text.isEmpty ||
                                          _buyPriceController.text.isEmpty ||
                                          _sellPriceController.text.isEmpty)
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                              'Required Field is empty.',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ))
                                        }
                                    }
                                  : null;
                              _isFutures
                                  ? {
                                      if (_leverageController.text == '0')
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                              'Leverage Value can\'t be zero.',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ))
                                        }
                                    }
                                  : null;
                              _calculateProfit();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    isFutures: _isFutures,
                                    profit: _profit,
                                    liquidationPrice: _liquidationPrice,
                                    stopLoss: _stopLoss,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 109, 49, 220),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Calculate',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ));
                      },
                    ),

                    BannerAdWidget(adSize: AdSize.banner)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
