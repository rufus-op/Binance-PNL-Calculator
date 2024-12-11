import 'dart:developer';
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
  bool _isDark = false;
  final _formKey = GlobalKey<FormState>();
  final _buyPriceController = TextEditingController();
  final _dcaBuyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _leverageController = TextEditingController();
  bool _isFutures = true;
  bool _isLong = true;
  bool isSpot = true;
  double _profit = 0;
  double _stopLoss = 0;
  double _liquidationPrice = 0;
  double totalDcaEntry = 0.0; // Store the total DCA entry price
  double totalDcaMargin = 0.0; // Store the total margin for DCA entries

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
    'Banter Bubbles',
    'Fear and Greed Index',
    'Liquidation Heatmap',
    'Charts',
  ];
  final List<String> _popupMenuWebUrls = [
    'https://banterbubbles.com/',
    'https://alternative.me/crypto/fear-and-greed-index/',
    'https://www.coinglass.com/pro/futures/LiquidationHeatMap',
    'https://velo.xyz/chart',
  ];
  final List<IconData> _popupMenuIcons = [
    Icons.bubble_chart_outlined, // Example icon for Fear and Greed Index
    Icons.graphic_eq_rounded, // Example icon for Fear and Greed Index
    Icons.waves_rounded, // Example icon for Liquidation Heatmap
    Icons.trending_up, // Example icon for Liquidation Heatmap
  ];

  @override
  void initState() {
    _loadDarkModeSetting();
    super.initState();
  }

  @override
  void dispose() {
    _buyPriceController.dispose();
    _dcaBuyPriceController.dispose();
    _sellPriceController.dispose();
    _quantityController.dispose();
    _stopLossController.dispose();
    _leverageController.dispose();
    super.dispose();
  }

  double selectedMaintenanceMarginRate = 0.004; // Default value (0.40%)

  // Available Maintenance Margin Rates (converted to decimal for calculation)
  List<Map<String, double>> marginRates = [
    {'0.40%': 0.004},
    {'0.50%': 0.005},
    {'1.00%': 0.01},
    {'2.00%': 0.02},
    {'3.00%': 0.03},
    {'5.00%': 0.05},
  ];

// Add these state variables
  List<Map<String, dynamic>> _dcaEntries =
      []; // Stores DCA entries with controllers
  final int _maxDcaEntries = 5; // Max number of DCA entries

// Add DCA Entry
  void _addDcaEntry() {
    if (_dcaEntries.length < _maxDcaEntries) {
      setState(() {
        // Create a new controller for each DCA entry
        _dcaEntries.add({
          'price': 0.0,
          'margin': 0.0,
          'priceController': TextEditingController(),
          'marginController': TextEditingController(),
        });
      });
    }
  }

// Remove DCA Entry
  void _removeDcaEntry(int index) {
    setState(() {
      _dcaEntries.removeAt(index);
    });
  }

  static const TextStyle defaultTextStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Crypto Calculator",
      theme: ThemeData(
          useMaterial3: true,
          brightness: _isDark ? Brightness.dark : Brightness.light),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            toolbarHeight: MediaQuery.sizeOf(context).height * 0.05,
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
                                                  _popupMenuOptions
                                                      .indexOf(option)],
                                              websiteName: option,
                                            ),
                                          ));
                                    },
                                    child: Row(
                                      children: [
                                        Icon(_popupMenuIcons[
                                            _popupMenuOptions.indexOf(
                                                option)]), // Display the corresponding icon
                                        SizedBox(
                                            width:
                                                8), // Space between icon and text
                                        Text(option),
                                      ],
                                    )));
                          }).toList()))
            ]),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.5),
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
                          contentPadding: EdgeInsets.zero, // Remove padding
                          visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity),
                          title: const Text('Spot', style: defaultTextStyle),
                          value: false,
                          groupValue: _isFutures,
                          onChanged: (value) {
                            setState(() {
                              isSpot = true;
                              _isFutures = false;
                              _quantityController.clear();
                              _stopLossController.clear();
                              _buyPriceController.clear();
                              _dcaBuyPriceController.clear();
                              _sellPriceController.clear();
                              _profit = 0;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          contentPadding: EdgeInsets.zero, // Remove padding
                          visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity),
                          title: Text('Futures', style: defaultTextStyle),
                          value: true,
                          groupValue: _isFutures,
                          onChanged: (value) {
                            setState(() {
                              isSpot = false;
                              _isFutures = true;
                              _quantityController.clear();
                              _stopLossController.clear();
                              _buyPriceController.clear();
                              _dcaBuyPriceController.clear();
                              _sellPriceController.clear();
                              _profit = 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  labelWithAsterisk(isRequired: true, label: "Cost / Margin"),
                  const SizedBox(height: 8),
                  TextFieldCustom(quantityController: _quantityController),
                  if (_isFutures) const SizedBox(height: 8),
                  if (_isFutures)
                    labelWithAsterisk(isRequired: true, label: "Position"),
                  if (_isFutures)
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            contentPadding: EdgeInsets.zero, // Remove padding
                            visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity),
                            title: const Text('Long', style: defaultTextStyle),
                            value: true,
                            groupValue: _isLong,
                            onChanged: (value) {
                              setState(() {
                                _isLong = true;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            contentPadding: EdgeInsets.zero, // Remove padding
                            visualDensity: const VisualDensity(
                                horizontal: VisualDensity.minimumDensity,
                                vertical: VisualDensity.minimumDensity),
                            title: Text('Short', style: defaultTextStyle),
                            value: false,
                            groupValue: _isLong,
                            onChanged: (value) {
                              setState(() {
                                _isLong = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  /////////////////////////////////////////// Leverage//////////////////////
                  if (_isFutures)
                    labelWithAsterisk(isRequired: true, label: "Leverage"),

                  const SizedBox(height: 8),

                  if (_isFutures)
                    TextFieldCustom(quantityController: _leverageController),

                  const SizedBox(height: 8),
                  // Modern Dropdown with custom background color and styling
                  labelWithAsterisk(isRequired: true, label: "Fees"),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: DropdownButtonFormField<double>(
                      value: selectedMaintenanceMarginRate,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMaintenanceMarginRate = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      items: marginRates.map((rate) {
                        return DropdownMenuItem<double>(
                          value: rate.values.first,
                          child: Text(
                            rate.keys.first,
                            style: TextStyle(
                              fontWeight: FontWeight.w500, // Text weight
                              fontSize: 16, // Text size
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  labelWithAsterisk(isRequired: true, label: "Entry Price"),
                  const SizedBox(height: 8),
                  TextFieldCustom(quantityController: _buyPriceController),
                  const SizedBox(height: 8),
                  labelWithAsterisk(isRequired: true, label: "Exit Price"),
                  const SizedBox(height: 8),
                  TextFieldCustom(quantityController: _sellPriceController),
                  const SizedBox(height: 8),
                  labelWithAsterisk(isRequired: false, label: "Stop loss"),
                  const SizedBox(height: 8),
                  TextFieldCustom(quantityController: _stopLossController),
                  const SizedBox(height: 10),
                  // Add DCA Entries button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          fixedSize: Size(double.maxFinite, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                  color: const Color.fromARGB(
                                      255, 109, 49, 220)))),
                      onPressed: () {
                        _addDcaEntry();
                      },
                      child: const Text('Add DCA Entry')),

                  // Display DCA Entries
                  if (_dcaEntries.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _dcaEntries.length,
                      itemBuilder: (context, index) {
                        // Access controllers and values
                        final priceController = _dcaEntries[index]
                            ['priceController'] as TextEditingController;
                        final marginController = _dcaEntries[index]
                            ['marginController'] as TextEditingController;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'DCA Entry Price',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _dcaEntries[index]['price'] =
                                            double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: marginController,
                                    decoration: const InputDecoration(
                                      labelText: 'DCA Margin',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _dcaEntries[index]['margin'] =
                                            double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    _removeDcaEntry(index);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      return ElevatedButton(
                          onPressed: () {
                            // Reset the total DCA margin and entry price before recalculating
                            totalDcaMargin = 0.0;
                            totalDcaEntry = 0.0;

                            double initialMargin =
                                double.tryParse(_quantityController.text) ??
                                    0.0;
                            double initialPrice =
                                double.tryParse(_buyPriceController.text) ??
                                    0.0;

                            // Check if the necessary fields for Futures are empty
                            if (_isFutures) {
                              if (_leverageController.text.isEmpty ||
                                  _quantityController.text.isEmpty ||
                                  _buyPriceController.text.isEmpty ||
                                  _sellPriceController.text.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Required Field is empty.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                                return;
                              }

                              if (_leverageController.text == '0') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'Leverage Value can\'t be zero.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                                return;
                              }
                            }

                            // Include the initial position margin and price into the calculation
                            totalDcaMargin += initialMargin;
                            totalDcaEntry += initialPrice * initialMargin;

                            // Process each DCA entry
                            for (var entry in _dcaEntries) {
                              double price =
                                  entry['price'] ?? 0.0; // The DCA entry price
                              double margin = entry['margin'] ??
                                  0.0; // The DCA entry margin

                              // Ensure margin is not zero before performing any calculations
                              if (margin == 0) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Margin cannot be zero for DCA entries.'),
                                  backgroundColor: Colors.red,
                                ));
                                return;
                              }

                              // Sum up the margins
                              totalDcaMargin += margin;

                              // Sum up the weighted prices (price * margin)
                              totalDcaEntry += price * margin;
                            }

                            // Calculate the weighted average DCA entry price
                            if (totalDcaMargin > 0) {
                              totalDcaEntry /=
                                  totalDcaMargin; // Weighted average price
                            } else {
                              totalDcaEntry =
                                  0.0; // In case there's a mistake in margin calculation
                            }

                            // Debug log to check the calculation
                            log('Initial Entry Price: $initialPrice');
                            log('Initial Margin: $initialMargin');
                            log('Total DCA Entry Price (after DCA): $totalDcaEntry');
                            log('Total Margin: $totalDcaMargin');

                            // Calculate profit and other required values based on the final entry price and margin
                            _calculateProfit(
                                    buyPrice: totalDcaEntry,
                                    quantity: totalDcaMargin)
                                .then((value) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                    isFutures: _isFutures,
                                    profit: _profit,
                                    entryPrice: value,
                                    liquidationPrice: _liquidationPrice,
                                    stopLoss: _stopLoss,
                                  ),
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 109, 49, 220),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Calculate',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white)));
                    },
                  ),
                  BannerAdWidget(adSize: AdSize.banner)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// Helper Widget for Label with Asterisk
  Widget labelWithAsterisk({required String label, required bool isRequired}) {
    return Row(
      children: [
        Text(label, style: defaultTextStyle),
        if (isRequired)
          Text('  *', style: defaultTextStyle.copyWith(color: Colors.red)),
      ],
    );
  }

  // Calculate Profit
  Future<double> _calculateProfit(
      {required double buyPrice, required double quantity}) async {
    double sellPrice = double.parse(_sellPriceController.text);

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
    return buyPrice;
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
}
