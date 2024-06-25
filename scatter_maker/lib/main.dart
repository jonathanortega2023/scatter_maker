// ignore_for_file: sort_child_properties_last

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_keyboard/math_keyboard.dart';
import "package:math_expressions/math_expressions.dart";
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scatter_maker/widgets/web_ads.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:html' as html;
import 'dart:math' as math;
import 'package:data/data.dart';
import 'package:screenshot/screenshot.dart';
import './widgets/buttons/icon_action_buttons.dart';
import './widgets/buttons/color_action_buttons.dart';
import './widgets/icons.dart';

final domainFormatters = [
  LengthLimitingTextInputFormatter(7),
  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
];
final intervalFormatters = [
  LengthLimitingTextInputFormatter(7),
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
];

enum RegressionLocation {
  topLeft,
  centerLeft,
  bottomLeft,
  topCenter,
  center,
  bottomCenter,
  topRight,
  centerRight,
  bottomRight,
}

Offset getRegressionOffset(RegressionLocation location, Size size) {
  final widthStep = size.width / 9;
  final heightStep = size.height / 9;
  switch (location) {
    case RegressionLocation.topLeft:
      return Offset(widthStep, heightStep * 2);
    case RegressionLocation.topCenter:
      return Offset(widthStep * 4, heightStep * 2);
    case RegressionLocation.topRight:
      return Offset(widthStep * 7, heightStep * 2);
    case RegressionLocation.centerLeft:
      return Offset(widthStep, heightStep * 4);
    case RegressionLocation.center:
      return Offset(widthStep * 4, heightStep * 4);
    case RegressionLocation.centerRight:
      return Offset(widthStep * 7, heightStep * 4);
    case RegressionLocation.bottomLeft:
      return Offset(widthStep, heightStep * 6);
    case RegressionLocation.bottomCenter:
      return Offset(widthStep * 4, heightStep * 6);
    case RegressionLocation.bottomRight:
      return Offset(widthStep * 7, heightStep * 6);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scatter Maker',
      theme: ThemeData(
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Scatter Maker Home Page'),
    );
  }
}

const SizedBox _kSizedBoxW5 = SizedBox(width: 5);
const SizedBox _kSizedBoxW20 = SizedBox(width: 20);
const SizedBox _kSizedBoxW40 = SizedBox(width: 40);
const SizedBox _kSizedBoxH20 = SizedBox(height: 20);
const SizedBox _kSizedBoxH40 = SizedBox(height: 40);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _chartKey = GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();

  Color scatterBorderColor = Colors.purple;
  Color scatterFillColor = Colors.white;
  Color regressionLineColor = Colors.blue;
  int colorPickerIndex = 0;

  MathFieldEditingController? mathFieldController =
      MathFieldEditingController();
  String? typedExpression;
  bool isTExpression = false;
  double? lowerDomain;
  double? upperDomain;
  double? lowerRange;
  double? upperRange;

  double lowerXAxis = 0;
  double upperXAxis = 10;
  double? xAxisInterval;

  double? lowerYAxis;
  double? upperYAxis;
  double? yAxisInterval;

  int numPoints = 200;

  String? xLabel;
  String? yLabel;
  String? chartTitle;

  int? selectedRegressionOption;
  int polynomialDegree = 2;
  bool plotRegressionEquation = true;
  bool showRegressionEquation = true;
  bool showRSquared = true;
  RegressionLocation regressionLocation = RegressionLocation.topLeft;
  double? rSquared;
  String? rSquaredString;
  String? regressionEquationString;
  UnaryFunction<double>? regressionEquationFunction;

  double randomnessStrength = 0;

  int _aspectRatioMenuValue = 2;
  double chartAspectRatio = 1.8;
  List<double> xValues = [];
  List<double> yValues = [];
  List<double> yValuesNoisy = [];
  List<double> xValuesFiltered = [];
  List<double> yValuesNoisyFiltered = [];

  List<ScatterSpot> fakeScatterPoints = List.generate(51, (index) {
    return ScatterSpot(index.toDouble() / 5, index.toDouble() / 5,
        radius: 8, color: Colors.accents[index % Colors.accents.length]);
  });

  double dotX = 0.10;

  double dotY = 0.25;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("y = ", style: TextStyle(fontSize: 25)),
              Expanded(child: equationField(), flex: 4),
              _kSizedBoxW40,
              Expanded(child: lowerDomainForm()),
              _kSizedBoxW20,
              Expanded(child: upperDomainForm()),
              _kSizedBoxW20,
              Expanded(child: pointNumberForm()),
              _kSizedBoxW20,
              Expanded(child: titleLabelForm(), flex: 4),
              _kSizedBoxW40,
              Expanded(child: chartAspectRatioMenu()),
              _kSizedBoxW20,
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: lowerXAxisForm()),
              _kSizedBoxW20,
              Expanded(child: upperXAxisForm()),
              _kSizedBoxW20,
              Expanded(child: horizontalAxisInterval()),
              _kSizedBoxW20,
              Expanded(child: xAxisLabelForm(), flex: 2),
              _kSizedBoxW40,
              Expanded(child: verticalAxisMin()),
              _kSizedBoxW20,
              Expanded(child: verticalAxisMax()),
              _kSizedBoxW20,
              Expanded(child: verticalAxisInterval()),
              _kSizedBoxW20,
              Expanded(child: yAxisLabelForm(), flex: 2),
              _kSizedBoxW40,
              generateDataButton(),
            ],
          ),
          const Divider(),
          threeColorPicker(),
          const Divider(),
          Row(children: [
            Flexible(
              flex: 2,
              child: Column(
                children: [
                  _kSizedBoxH20,
                  Stack(
                    children: [
                      Transform.translate(
                          offset: const Offset(15, -20),
                          child: const Text(
                            "Noise Level",
                            style: TextStyle(fontSize: 16),
                          )),
                      randomnessSlider(),
                    ],
                  ),
                  _kSizedBoxH20,
                  regressionOptions(),

                  const Divider(
                    color: Colors.black,
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const PaypalDonateButton(),
                          // TODO Add about button to new page
                        ],
                      ),
                      saveChartButton(),
                    ],
                  ),
                  // TODO Ad
                  // Container(
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.black, width: 1)),
                  //   height: 200,
                  //   width: 600,
                  //   child: const DisplayWebAd(),
                  // ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.black, width: 1)),
                  //   height: 200,
                  //   width: 600,
                  //   child: const FeedWebAd(),
                  // )
                ],
              ),
            ),
            Flexible(
              flex: _aspectRatioMenuValue < 2
                  ? 2
                  : _aspectRatioMenuValue == 2
                      ? 3
                      : 4,
              child: Center(child: scatterChartGraph()),
            )
          ])
        ]),
      ),
    ));
  }

  randomnessSlider() {
    // lock the slider if regression selected
    return AbsorbPointer(
      absorbing: yValues.isEmpty,
      child: SfSlider(
        value: randomnessStrength / 10,
        onChanged: (value) {
          if (selectedRegressionOption != null) {
            _snackBar("Turn off regression to adjust noise");
            return;
          }
          setState(() {
            randomnessStrength = value * 10;
          });
          _makeNoisyData();
          _filterNoisyData();
          _getRegressionEquation();
        },
        min: 0,
        max: 1,
        interval: 0.1,
        stepSize: 0.1,
        showTicks: true,
        showLabels: true,
        labelFormatterCallback: (actualValue, formattedText) {
          return (actualValue * 100).toStringAsFixed(0) + '%';
        },
      ),
    );
  }

  IconActionButton saveChartButton() {
    return IconActionButton(
        text: 'Save Chart', icon: Icons.download, onPressed: saveChart);
  }

  IconActionButton generateDataButton() {
    return IconActionButton(
        text: 'Generate Data', icon: Icons.refresh, onPressed: generateData);
  }

  Widget scatterChartGraph() {
    String regressionText = "";
    if (showRegressionEquation) {
      regressionText = regressionEquationString ?? "";
    }
    if (showRSquared) {
      regressionText += "\n${rSquaredString ?? ""}";
    }
    return Screenshot(
      controller: screenshotController,
      child: Animate(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 1200),
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: chartAspectRatio,
            child: Stack(
              children: [
                ScatterChart(
                  key: _chartKey,
                  ScatterChartData(
                    minX: lowerXAxis,
                    maxX: upperXAxis,
                    minY: lowerYAxis,
                    maxY: upperYAxis,
                    scatterSpots: _getScatterSpots() + _regressionLine(),
                    scatterTouchData: ScatterTouchData(enabled: false),
                    showingTooltipIndicators: null,
                    scatterLabelSettings:
                        ScatterLabelSettings(showLabel: false),
                    backgroundColor: Colors.white,
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: AxisTitles(
                          axisNameWidget: Text(chartTitle ?? "Title",
                              style: const TextStyle(
                                fontSize: 30,
                              )),
                          axisNameSize: 60),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: yAxisInterval),
                          axisNameWidget: Text(
                            yLabel ?? "Y",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          axisNameSize: 30),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: xAxisInterval),
                          axisNameWidget: Text(xLabel ?? "X",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          axisNameSize: 30),
                      // Adds empty widget for whitespace
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (numValue, titleValue) {
                                return const SizedBox.shrink();
                              })),
                    ),
                  ),
                ),
                // depends on future because the chart size is not known until after the chart is built
                // TODO Fix for vertical aspect ratios
                FutureBuilder<Size>(
                  future: Future(() => _chartKey.currentContext!.size!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      final chartSize = snapshot.data!;
                      return Transform.translate(
                        // offset:
                        //     getRegressionOffset(regressionLocation, chartSize),
                        offset: Offset(
                            dotX * chartSize.width, dotY * chartSize.height),
                        child: Text(
                          regressionText,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  color: Colors.white,
                                  offset: Offset(1, 1),
                                  blurRadius: 1)
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget regressionOptions() {
    return Column(
      children: [
        const Divider(),
        // TODO, precalculate all degrees and store them in a lookup
        CheckboxListTile(
            enabled: yValues.isNotEmpty,
            title: const Text("Polynomial Regression"),
            value: selectedRegressionOption == 0,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                selectedRegressionOption = value ? 0 : null;
              });
              if (selectedRegressionOption == null) {
                setState(() {
                  regressionEquationString = null;
                  rSquaredString = null;
                  rSquared = null;
                });
              } else {
                _getRegressionEquation();
              }
            }),
        if (selectedRegressionOption == 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Degree"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                        icon: PolyDegreeIcon(degree: index),
                        onPressed: () {
                          setState(() {
                            polynomialDegree = index;
                          });
                          _getRegressionEquation();
                        },
                        style: ButtonStyle(
                            side: WidgetStateProperty.all(const BorderSide(
                                color: Colors.black, width: 1)),
                            backgroundColor: polynomialDegree == index
                                ? WidgetStateProperty.all(
                                    regressionLineColor.withOpacity(0.5))
                                : WidgetStateProperty.all(Colors.grey[200])),
                        label: Text(index.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                            ))),
                  );
                }),
              ),
            ],
          ),
        CheckboxListTile(
            title: const Text(
                "👷🏾‍♂️ Exponential Regression - 🚧 Under Construction 🚧"),
            value: selectedRegressionOption == 1,
            enabled: false,
            // TODO Implement
            onChanged: (value) {
              return;
              if (value == null) {
                return;
              }
              setState(() {
                selectedRegressionOption = value ? 1 : null;
              });
              _getRegressionEquation();
            }),
        const Divider(),
        ExpansionTile(
          enabled: selectedRegressionOption != null,
          title: Text('Regression Equation Options'),
          children: [
            CheckboxListTile(
                title: const Text('Regression equation w.r.t. T'),
                value: isTExpression,
                enabled: selectedRegressionOption != null,
                onChanged: (value) {
                  setState(() {
                    isTExpression = value ?? false;
                    if (isTExpression) {
                      regressionEquationString =
                          regressionEquationString!.replaceAll("X", "T");
                    } else {
                      regressionEquationString =
                          regressionEquationString!.replaceAll("T", "X");
                    }
                  });
                }),
            CheckboxListTile(
              title: const Text('Plot regression equation'),
              value: plotRegressionEquation,
              enabled: selectedRegressionOption != null,
              onChanged: (value) {
                setState(() {
                  plotRegressionEquation = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Show equation on graph'),
              value: showRegressionEquation,
              enabled: selectedRegressionOption != null,
              onChanged: (value) {
                setState(() {
                  showRegressionEquation = value ?? false;
                });
              },
            ),
            // TODO changeable regression decimal precision
          ],
        ),
        CheckboxListTile(
          title: const Text('Show R² on graph'),
          value: showRSquared,
          enabled: selectedRegressionOption != null,
          onChanged: (value) {
            setState(() {
              showRSquared = value ?? false;
            });
          },
        ),
        if (showRegressionEquation || showRSquared)
          ListTile(
            enabled: selectedRegressionOption != null,
            title: const Text("Regression equation placement:"),
            // replace with a container that has a movable dot for relative placement
            trailing: GestureDetector(
                onPanUpdate: (details) {
                  if (selectedRegressionOption == null) {
                    return;
                  }
                  setState(() {
                    dotX += details.delta.dx / 250;
                    dotY += details.delta.dy / 250;
                    dotX = dotX.clamp(0, 1);
                    dotY = dotY.clamp(0, 1);
                  });
                },
                onTapDown: (details) {
                  if (selectedRegressionOption == null) {
                    return;
                  }
                  setState(() {
                    dotX = details.localPosition.dx / 50;
                    dotY = details.localPosition.dy / 50;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: dotX * 50 - 10,
                        top: dotY * 50 - 10,
                        child: const Icon(Icons.circle, size: 20),
                      ),
                    ],
                  ),
                )),
            // trailing: Container(
            //     height: 50,
            //     width: 50,
            //     child: GridView.count(
            //         scrollDirection: Axis.horizontal,
            //         crossAxisCount: 3,
            //         children: List.generate(9, (index) {
            //           return GestureDetector(
            //               onTap: () {
            //                 setState(() {
            //                   regressionLocation =
            //                       RegressionLocation.values[index];
            //                 });
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(1.0),
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                       border: Border.all(width: 1),
            //                       color: regressionLocation ==
            //                               RegressionLocation.values[index]
            //                           ? Colors.black
            //                           : Colors.grey[200]),
            //                 ),
            //               ));
            //         }))),
          ),
        const Divider(),
        SelectionArea(
          child: Column(
            children: [
              Text("Regression equation: ${regressionEquationString ?? ""}",
                  style: const TextStyle(fontSize: 20)),
              Text("R²: ${rSquared ?? ""}",
                  style: const TextStyle(fontSize: 20)),
            ],
          ),
        )
      ],
    );
  }

  updateRegressionLineColor(Color color) {
    setState(() {
      regressionLineColor = color;
    });
  }

  updatePointBorderColor(Color color) {
    setState(() {
      scatterBorderColor = color;
    });
  }

  updatePointFillColor(Color color) {
    setState(() {
      scatterFillColor = color;
    });
  }

  Widget chartAspectRatioMenu() {
    return DropdownButton(
      isExpanded: true,
      hint: const Row(children: [
        Icon(Icons.screen_rotation),
        _kSizedBoxW5,
        Text('Chart Aspect Ratio')
      ]),
      items: const [
        DropdownMenuItem<int>(
          value: 0,
          child: Row(children: [
            Icon(Icons.crop_portrait_sharp, ),
            _kSizedBoxW5,
            Text('Tall'),
          ]),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Row(children: [
            Icon(Icons.crop_portrait_sharp),
            _kSizedBoxW5,
            Text('Portrait'),
          ]),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Row(children: [
            Icon(Icons.crop_square_sharp),
            _kSizedBoxW5,
            Text('Square'),
          ]),
        ),
        DropdownMenuItem<int>(
          value: 3,
          child: Row(children: [
            Icon(Icons.crop_landscape_sharp),
            _kSizedBoxW5,
            Text('Landscape'),
          ]),
        ),
        DropdownMenuItem<int>(
          value: 4,
          child: Row(children: [
            Icon(Icons.crop_landscape_sharp),
            _kSizedBoxW5,
            Text('Wide'),
          ]),
        ),
      ],
      value: _aspectRatioMenuValue,
      onChanged: (value) {
        setState(() {
          _aspectRatioMenuValue = value!;
          if (value == 0) {
            chartAspectRatio = 0.6;
          } else if (value == 1) {
            chartAspectRatio = 0.8;
          } else if (value == 2) {
            chartAspectRatio = 1.0;
          } else if (value == 3) {
            chartAspectRatio = 1.4;
          } else {
            chartAspectRatio = 1.8;
          }
        });
      },
    );
  }

  Widget titleLabelForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          chartTitle = text;
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(), hintText: 'Title', labelText: 'Title'),
    );
  }

  Widget yAxisLabelForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          yLabel = text;
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Y label',
          labelText: 'Y label'),
    );
  }

  Widget xAxisLabelForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          xLabel = text;
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X label',
          labelText: 'X label'),
    );
  }

  Widget pointNumberForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          numPoints = int.parse(text);
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Data Points',
          labelText: "Data Points"),
      inputFormatters: [
        LengthLimitingTextInputFormatter(4),
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget verticalAxisInterval() {
    return TextField(
      onChanged: (text) {
        if (text.isEmpty || text == "." || text == "0.") {
          return;
        }

        try {
          final value = double.parse(text);
          if (value != 0) {
            setState(() {
              yAxisInterval = value;
            });
          }
        } catch (e) {
          _snackBar("Invalid Y axis interval");
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Y axis interval',
          labelText: 'Y axis interval'),
      inputFormatters: intervalFormatters,
    );
  }

  Widget verticalAxisMax() {
    return TextField(
      onChanged: (text) {
        setState(() {
          if (text.isEmpty) {
            upperYAxis = null;
          } else if (text == "-") {
            upperYAxis = null;
          } else {
            upperYAxis = double.parse(text);
          }
        });
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Y axis max',
          labelText: 'Y axis max'),
      inputFormatters: domainFormatters,
    );
  }

  Widget verticalAxisMin() {
    return TextField(
      onChanged: (text) {
        setState(() {
          if (text.isEmpty) {
            lowerYAxis = null;
          } else if (text == "-") {
            lowerYAxis = null;
          } else {
            lowerYAxis = double.parse(text);
          }
        });
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Y axis min',
          labelText: 'Y axis min'),
      inputFormatters: domainFormatters,
    );
  }

  Widget horizontalAxisInterval() {
    return TextField(
      onChanged: (text) {
        if (text.isEmpty || text == "." || text == "0.") {
          return;
        }

        try {
          final value = double.parse(text);
          if (value != 0) {
            setState(() {
              xAxisInterval = value;
            });
          }
        } catch (e) {
          _snackBar("Invalid Y axis interval");
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X axis interval',
          labelText: 'X axis interval'),
      inputFormatters: intervalFormatters,
    );
  }

  Widget upperXAxisForm() {
    return TextField(
      onChanged: (text) {
        if (text.isEmpty || text == "-" || text == "." || text == "-.") {
          return;
        }
        double textValue;
        try {
          textValue = double.parse(text);
        } catch (e) {
          _snackBar("Invalid X axis max");
          return;
        }
        setState(() {
          upperXAxis = textValue;
        });
        _filterNoisyData();
      },
      onEditingComplete: () {
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X max',
          labelText: 'X axis max'),
      inputFormatters: domainFormatters,
    );
  }

  Widget lowerXAxisForm() {
    return TextField(
      onChanged: (text) {
        if (text.isEmpty || text == "-" || text == "." || text == "-.") {
          return;
        }
        double textValue;
        try {
          textValue = double.parse(text);
        } catch (e) {
          _snackBar("Invalid X axis min");
          return;
        }
        setState(() {
          lowerXAxis = textValue;
        });
        _filterNoisyData();
      },
      onEditingComplete: () {
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X min',
          labelText: 'X axis min'),
      inputFormatters: domainFormatters,
    );
  }

  Widget upperRangeForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          upperRange = double.parse(text);
        });
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Range max',
          labelText: 'Range max'),
      inputFormatters: domainFormatters,
    );
  }

  Widget lowerRangeForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          lowerRange = double.parse(text);
        });
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Range min',
          labelText: 'Range min'),
      inputFormatters: domainFormatters,
    );
  }

  Widget upperDomainForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          upperDomain = double.parse(text);
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Domain max',
          labelText: 'Domain max'),
      inputFormatters: domainFormatters,
    );
  }

  Widget lowerDomainForm() {
    return TextField(
      onChanged: (text) {
        setState(() {
          lowerDomain = double.parse(text);
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Domain min',
          labelText: 'Domain min'),
      inputFormatters: domainFormatters,
    );
  }

  Widget equationField() {
    return MathField(
      variables: const ['X', 'T'],
      controller: mathFieldController,
      onChanged: (value) {
        setState(() {
          typedExpression = value;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter an expression w.r.t. X',
        labelText: 'Expression',
      ),
      opensKeyboard: false,
    );
  }

  Widget threeColorPicker() {
    return Row(
      children: [
        ButtonBar(
          children: [
            ColorPickerActionButton(
              text: "Point Border",
              selected: colorPickerIndex == 0,
              onPressed: () {
                setState(() {
                  colorPickerIndex = 0;
                });
              },
              sampleDisplay:
                  PointBorderSample(scatterBorderColor: scatterBorderColor),
              resetFunction: () {
                setState(() {
                  scatterBorderColor = Colors.purple;
                });
              },
            ),
            const Text('|', style: TextStyle(fontSize: 30, color: Colors.grey)),
            ColorPickerActionButton(
              text: "Point Fill",
              selected: colorPickerIndex == 1,
              onPressed: () {
                setState(() {
                  colorPickerIndex = 1;
                });
              },
              sampleDisplay: FilledPointSample(
                  scatterBorderColor: scatterBorderColor,
                  scatterFillColor: scatterFillColor),
              resetFunction: () {
                setState(() {
                  scatterFillColor = Colors.white;
                });
              },
            ),
            const Text('|', style: TextStyle(fontSize: 30, color: Colors.grey)),
            ColorPickerActionButton(
              text: "Regression Line",
              selected: colorPickerIndex == 2,
              onPressed: () {
                setState(() {
                  colorPickerIndex = 2;
                });
              },
              sampleDisplay: RegressionColorSample(
                  regressionLineColor: regressionLineColor),
              resetFunction: () {
                setState(() {
                  regressionLineColor = Colors.blue;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: ColorPicker(
            borderColor: Colors.black,
            hasBorder: true,
            enableShadesSelection: false,
            onColorChanged: (Color color) {
              if (colorPickerIndex == 0) {
                setState(() {
                  scatterBorderColor = color;
                });
              } else if (colorPickerIndex == 1) {
                setState(() {
                  scatterFillColor = color;
                });
              } else if (colorPickerIndex == 2) {
                setState(() {
                  regressionLineColor = color;
                });
              }
            },
            color: Colors.transparent,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.accent: false,
            },
          ),
        ),
      ],
    );
  }

  void saveChart() {
    screenshotController.capture().then((Uint8List? image) async {
      final blob = html.Blob([image], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'scatter_chart.png';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    });
  }

  void generateData() {
    if (typedExpression == null) {
      return;
    }
    if (typedExpression!.isEmpty) {
      _snackBar("Expression is empty");
      throw Exception("Expression is empty");
    }
    if (lowerXAxis >= upperXAxis) {
      _snackBar("X axis is invalid");
      throw Exception("X axis is invalid");
    }
    if (lowerDomain != null && upperDomain != null) {
      if (lowerDomain! >= upperDomain!) {
        _snackBar("Domain is invalid");
        throw Exception("Domain is invalid");
      }
    }
    if (lowerYAxis != null && upperYAxis != null) {
      if (lowerYAxis! >= upperYAxis!) {
        _snackBar("Y axis is invalid");
        throw Exception("Y axis is invalid");
      }
    }
    if (selectedRegressionOption != null) {
      setState(() {
        selectedRegressionOption = null;
        regressionEquationString = null;
        rSquaredString = null;
        rSquared = null;
      });
    }
    String texExpression;
    try {
      texExpression = '${TeXParser(typedExpression!).parse()}';
    } catch (e) {
      _snackBar("Invalid expression");
      throw Exception("Invalid expression");
    }
    Expression functionExpression;
    try {
      functionExpression = Parser().parse(texExpression);
    } catch (e) {
      _snackBar("Invalid expression");
      throw Exception("Invalid expression");
    }
    Variable expressionVariable = Variable('X');
    ContextModel contextModel = ContextModel();
    contextModel.bindVariable(expressionVariable, functionExpression);

    setState(() {
      // set x values based on domain and number of points
      xValues = List.generate(
          numPoints,
          (index) =>
              lowerXAxis + (upperXAxis - lowerXAxis) * index / numPoints);
      // calculate true y values based on expression
      // generate yValuesWithNoise based on true y values and randomness
      yValues = xValues.map((x) {
        contextModel.bindVariable(expressionVariable, Number(x));
        return functionExpression.evaluate(EvaluationType.REAL, contextModel)
            as double;
      }).toList();
      // remove from xValues and yValues if yValue[i] is NaN or infinite
      for (int i = 0; i < yValues.length; i++) {
        if (!yValues[i].isFinite || yValues[i].isNaN) {
          xValues.removeAt(i);
          yValues.removeAt(i);
          i -= 1;
        }
      }
    });
    _makeNoisyData();
    _filterNoisyData();
  }

  _makeNoisyData() {
    final math.Random random = math.Random();
    double yMin = yValues.reduce(math.min);
    double yMax = yValues.reduce(math.max);
    double yRange = yMax - yMin;

    if (yRange == 0) {
      yRange = yMax;
    }

    List<double> yValuesWithNoise = yValues.map((y) {
      int sign = random.nextBool() ? 1 : -1;
      double noise = random.nextDouble() * yRange * 0.1 * randomnessStrength;
      noise *= sign;
      return y + noise;
    }).toList();

    double yMinNoisy = yValuesWithNoise.reduce(math.min);
    double yMaxNoisy = yValuesWithNoise.reduce(math.max);
    double yRangeNoisy = yMaxNoisy - yMinNoisy;
    // Scale the noisy data to fit within the original range
    setState(() {
      yValuesNoisy = yValuesWithNoise.map((y) {
        return ((y - yMinNoisy) / yRangeNoisy) * yRange + yMin;
      }).toList();
    });
  }

  // _makeNoisyData() {
  //   final Random random = Random();
  //   double yRange = yValues.reduce(math.max) - yValues.reduce(math.min);
  //   if (yRange == 0) {
  //     yRange = yValues.reduce(math.max);
  //   }
  //   setState(() {
  //     // TODO Fix this, try to constrain the noise to the range of the data
  //     yValuesNoisy = yValues.map((y) {
  //       int sign = random.nextBool() ? 1 : -1;
  //       double noise =
  //           random.nextDouble() * yRange * 0.1 * (randomnessStrength);
  //       noise *= sign;
  //       return y + noise;
  //     }).toList();

  //   });
  // }

  _filterNoisyData() {
    List<double> newXValues = [];
    List<double> newYValuesNoisy = [];

    if (yValuesNoisy.isEmpty) {
      return;
    }

    for (int i = 0; i < yValuesNoisy.length; i++) {
      var xValue = xValues[i];
      var yValue = yValuesNoisy[i];
      if (xValue < lowerXAxis) {
        continue;
      }
      if (xValue > upperXAxis) {
        continue;
      }
      if (lowerYAxis != null && yValue < lowerYAxis!) {
        continue;
      }
      if (upperYAxis != null && yValue > upperYAxis!) {
        continue;
      }
      if (lowerDomain != null && xValue < lowerDomain!) {
        continue;
      }
      if (upperDomain != null && xValue > upperDomain!) {
        continue;
      }
      if (!yValue.isFinite || yValue.isNaN) {
        continue;
      }
      newXValues.add(xValue);
      newYValuesNoisy.add(yValue);
    }

    setState(() {
      xValuesFiltered = newXValues;
      yValuesNoisyFiltered = newYValuesNoisy;
    });
  }

  _getScatterSpots() {
    if (yValuesNoisy.isEmpty || yValuesNoisyFiltered.isEmpty) {
      return fakeScatterPoints;
    }
    List<ScatterSpot> result = [];
    for (int i = 0; i < yValuesNoisyFiltered.length; i++) {
      result.add(ScatterSpot(
        xValuesFiltered[i],
        yValuesNoisyFiltered[i],
        radius: 8,
        color: scatterBorderColor,
      ));
    }
    if (scatterBorderColor != scatterFillColor) {
      for (int i = 0; i < yValuesNoisyFiltered.length; i++) {
        result.add(ScatterSpot(xValuesFiltered[i], yValuesNoisyFiltered[i],
            radius: 3, color: scatterFillColor));
      }
    }
    return result;
  }

  void _snackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      message,
      style: const TextStyle(
        fontSize: 20,
      ),
    )));
  }

  void _getRegressionEquation() {
    if (selectedRegressionOption == null) {
      return;
    }

    if (selectedRegressionOption == 0) {
      final result = PolynomialRegression(degree: polynomialDegree).fit(
          xs: xValuesFiltered.toVector(), ys: yValuesNoisyFiltered.toVector());

      // Calculate R-squared
      setState(() {
        regressionEquationFunction = result.function;
      });
      _calculateRSquared();

      // Format the regression equation
      String stringResult = result.polynomial.format(
        variable: 'X',
      );
      String formattedResult = _formatPolyEquationString(stringResult);

      setState(() {
        regressionEquationString = formattedResult;
      });
    } else if (selectedRegressionOption == 1) {
      // Transform y values by taking the natural logarithm
      List<double> logYValues =
          yValuesNoisyFiltered.map((y) => log(y)).toList();

      // Perform linear regression on transformed data
      final fitter = PolynomialRegression(degree: 1);
      final result =
          fitter.fit(xs: xValuesFiltered.toVector(), ys: logYValues.toVector());
      print(result.polynomial.format());
      return;
      // TODO: Fix this, probably will only work for positive values and be a headache
      // Extract the coefficients
      // final double b = result.coefficients[1];
      // final double lnA = result.coefficients[0];
      // final double a = exp(lnA);

      // // Calculate R-squared
      // setState(() {
      //   regressionEquationFunction = (x) => a * exp(b * x);
      // });
      // _calculateRSquared();

      // // Format the regression equation
      // String formattedResult =
      //     'y = ${a.toStringAsFixed(2)} * e^(${b.toStringAsFixed(2)}x)';
      // setState(() {
      //   regressionEquationString = formattedResult;
      // });
    }
  }

  String _formatPolyEquationString(String equation) {
    String formattedResult = "";
    var terms = equation.split(" + ");
    for (var term in terms) {
      double coefficient;
      if (!term.contains("X") && !term.contains("T")) {
        coefficient = double.parse(term);
        if (coefficient.abs() <= 0.001) continue;
        formattedResult += coefficient < 0 ? " - " : " + ";
        formattedResult += coefficient.abs().toStringAsFixed(3);
        continue;
      } else if (term.contains("X")) {
        coefficient = double.parse(term.split("X")[0]);
        if (coefficient.abs() <= 0.001) continue;
        formattedResult += coefficient < 0 ? " - " : " + ";
        formattedResult += coefficient.abs().toStringAsFixed(3);
        formattedResult += "X${term.split("X")[1]}";
      } else if (term.contains("T")) {
        coefficient = double.parse(term.split("T")[0]);
        if (coefficient.abs() <= 0.001) continue;
        formattedResult += coefficient < 0 ? " - " : " + ";
        formattedResult += coefficient.abs().toStringAsFixed(3);
        formattedResult += "T${term.split("T")[1]}";
      }
    }
    if (formattedResult.startsWith(" + ")) {
      formattedResult = formattedResult.substring(3);
    }
    return "Ŷ = $formattedResult";
  }

  void _calculateRSquared() {
    // Calculate the mean of y
    final int n = yValuesNoisyFiltered.length;
    final double meanY = yValuesNoisyFiltered.arithmeticMean();
    // Calculate the total sum of squares (SST)
    final double sst = yValuesNoisyFiltered.fold(
        0, (prev, yi) => prev + (yi - meanY) * (yi - meanY));

    // Calculate the residual sum of squares (SSE)
    double sse = 0;
    for (int i = 0; i < n; i++) {
      final double predictedY = regressionEquationFunction!(xValuesFiltered[i]);
      final double error = yValuesNoisyFiltered[i] - predictedY;
      sse += error * error;
    }

    // Calculate R-squared
    final double r2 = 1 - (sse / sst);

    // Update the state
    setState(() {
      if (r2.isNaN || r2 < .0001) {
        rSquared = 0.0;
      }
      rSquared = r2.toPrecision(4);
      rSquaredString = "R² = $rSquared";
    });
  }

  List<ScatterSpot> _regressionLine() {
    if (!plotRegressionEquation) {
      return [];
    }
    if (regressionEquationFunction == null ||
        regressionEquationString == null) {
      return [];
    }
    if (xValuesFiltered.isEmpty) {
      return [];
    }
    List<ScatterSpot> result = [];
    for (int i = 0; i < 500; i++) {
      double x = xValuesFiltered.first +
          (xValuesFiltered.last - xValuesFiltered.first) * i / 500;
      double y = regressionEquationFunction!(x);
      if (y.isNaN) {
        continue;
      }
      if (lowerYAxis != null && y < lowerYAxis!) {
        continue;
      }
      if (upperYAxis != null && y > upperYAxis!) {
        continue;
      }
      result.add(ScatterSpot(x, y, radius: 2, color: regressionLineColor));
    }
    return result;
  }
}
