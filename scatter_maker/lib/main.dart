// ignore_for_file: sort_child_properties_last

import 'dart:html';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:math_keyboard/math_keyboard.dart';
import "package:math_expressions/math_expressions.dart";
import "package:simple_icons/simple_icons.dart";
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'dart:html' as html;
import 'dart:math' as math;
import 'package:screenshot/screenshot.dart';
import './widgets/buttons/icon_action_buttons.dart';
import './widgets/buttons/color_action_buttons.dart';

final domainFormatters = [
  LengthLimitingTextInputFormatter(7),
  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

const SizedBox _kSizedBoxW5 = SizedBox(width: 5);
const SizedBox _kSizedBoxW20 = SizedBox(width: 20);
const SizedBox _kSizedBoxW40 = SizedBox(width: 40);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScreenshotController screenshotController = ScreenshotController();

  Color scatterBorderColor = Colors.purple;
  Color scatterFillColor = Colors.white;
  Color regressionLineColor = Colors.blue;
  int colorPickerIndex = 0;

  MathFieldEditingController? mathFieldController =
      MathFieldEditingController();
  String? typedExpression;
  bool isTExpression = false;
  double lowerDomain = -10;
  double upperDomain = 10;
  double? lowerRange;
  double? upperRange;

  double? lowerXAxis;
  double? upperXAxis;
  double? xAxisInterval;

  double? lowerYAxis;
  double? upperYAxis;
  double? yAxisInterval;

  int numPoints = 200;

  String? xLabel;
  String? yLabel;
  String? chartTitle;

  int? selectedOption;
  int polynomialDegree = 2;
  bool showPolynomialEquation = false;
  bool showPolynomialCorrelation = false;
  bool showExponentialEquation = false;
  bool showExponentialCorrelation = false;
  String? regressionEquation;
  double randomnessStrength = 0;

  double chartAspectRatio = 1.8;
  List<double> xValues = [];
  List<double> yValues = [];
  List<double> yValuesNoisy = [];
  List<double> xValuesFiltered = [];
  List<double> yValuesNoisyFiltered = [];

  List<ScatterSpot> fakeScatterPoints = List.generate(51, (index) {
    return ScatterSpot(index.toDouble(), index.toDouble(),
        radius: 8, color: Colors.accents[index % Colors.accents.length]);
  });

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
              Expanded(child: equationField(), flex: 2),
              _kSizedBoxW20,
              Expanded(child: lowerDomainForm()),
              _kSizedBoxW40,
              Expanded(child: upperDomainForm()),
              _kSizedBoxW40,
              // lowerRangeForm(),
              // upperRangeForm(),
              Expanded(child: pointNumberForm()),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: horizontalAxisMin()),
              _kSizedBoxW20,
              Expanded(child: horizontalAxisMax()),
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
              Expanded(child: titleLabelForm(), flex: 3),
            ],
          ),
          const Divider(),
          threeColorPicker(),
          const Divider(),
          Row(children: [
            Expanded(
              flex: 2,
              child: Column(children: [
                regressionOptions(),
                randomnessSlider(),
                const Divider(
                  color: Colors.black,
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PaypalDonateButton(),
                    Row(
                      children: [
                        generateDataButton(),
                        _kSizedBoxW5,
                        saveChartButton(),
                      ],
                    )
                  ],
                ),
              ]),
            ),
            const VerticalDivider(),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  const Text("Chart Aspect Ratio",
                      style: TextStyle(fontSize: 20)),
                  SfSlider(
                    value: chartAspectRatio,
                    onChanged: (value) {
                      setState(() {
                        chartAspectRatio = value;
                      });
                    },
                    min: 0.6,
                    max: 2.2,
                    interval: 0.2,
                    stepSize: 0.2,
                    showTicks: true,
                    showLabels: true,
                  ),
                  const Divider(color: Colors.transparent),
                  scatterChartGraph(),
                ],
              ),
            )
          ])
        ]),
      ),
    ));
  }

  randomnessSlider() {
    return AbsorbPointer(
      absorbing: yValues.isEmpty,
      child: Slider(
        value: randomnessStrength * 10,
        onChanged: (value) {
          setState(() {
            randomnessStrength = value / 10;
          });
          _makeNoisyData();
          _filterNoisyData();
        },
        min: 0,
        max: 100,
        divisions: 20,
        label: randomnessStrength.toStringAsFixed(2),
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
    return Screenshot(
      controller: screenshotController,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 800),
        color: Colors.white,
        child: AspectRatio(
          aspectRatio: chartAspectRatio,
          child: ScatterChart(
            ScatterChartData(
              minX: lowerXAxis,
              maxX: upperXAxis,
              minY: lowerYAxis,
              maxY: upperYAxis,
              scatterSpots: _getScatterSpots(),
              scatterTouchData: ScatterTouchData(enabled: false),
              showingTooltipIndicators: null,
              scatterLabelSettings: ScatterLabelSettings(showLabel: false),
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
                    axisNameWidget: Text(yLabel ?? "Y",
                        style: const TextStyle(fontSize: 20)),
                    axisNameSize: 30),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: xAxisInterval),
                    axisNameWidget: Text(xLabel ?? "X",
                        style: const TextStyle(fontSize: 20)),
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
        ),
      ),
    );
  }

  Widget regressionOptions() {
    return Column(
      children: [
        Text(
            "Regression equation: ${regressionEquation ?? "Calculated upon generation"}"),
        ListTile(
          title: const Text("Polynomial Regression"),
          trailing: Radio(
            value: 1,
            groupValue: selectedOption,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                selectedOption = value;
              });
            },
          ),
          onTap: () {
            setState(() {
              selectedOption = 1;
            });
          },
        ),
        if (selectedOption == 1)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Polynomial Degree"),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: SfSlider(
                  value: polynomialDegree.toInt(),
                  onChanged: (value) {
                    setState(() {
                      polynomialDegree = value.toInt();
                    });
                  },
                  min: 0,
                  max: 5,
                  stepSize: 1,
                  interval: 1,
                  showTicks: true,
                  showLabels: true,
                ),
              ),
              CheckboxListTile(
                title: const Text('Show Equation on Graph'),
                value: showPolynomialEquation,
                onChanged: (value) {
                  setState(() {
                    showPolynomialEquation = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Show Correlation on Graph'),
                value: showPolynomialCorrelation,
                onChanged: (value) {
                  setState(() {
                    showPolynomialCorrelation = value ?? false;
                  });
                },
              ),
            ],
          ),
        ListTile(
          title: const Text("Exponential Regression"),
          trailing: Radio(
            value: 2,
            groupValue: selectedOption,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                selectedOption = value;
              });
            },
          ),
          onTap: () {
            setState(() {
              selectedOption = 2;
            });
          },
        ),
        if (selectedOption == 2)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: const Text('Show Equation on Graph'),
                value: showExponentialEquation,
                onChanged: (value) {
                  setState(() {
                    showExponentialEquation = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Show Correlation on Graph'),
                value: showExponentialCorrelation,
                onChanged: (value) {
                  setState(() {
                    showExponentialCorrelation = value ?? false;
                  });
                },
              ),
            ],
          ),
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
          hintText: 'Number of points',
          labelText: "Number of points"),
      inputFormatters: [
        LengthLimitingTextInputFormatter(4),
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget verticalAxisInterval() {
    return TextField(
      onChanged: (text) {
        setState(() {
          yAxisInterval = double.parse(text);
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Y axis interval',
          labelText: 'Y axis interval'),
      inputFormatters: domainFormatters,
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
        setState(() {
          xAxisInterval = double.parse(text);
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X axis interval',
          labelText: 'X axis interval'),
      inputFormatters: domainFormatters,
    );
  }

  Widget horizontalAxisMax() {
    return TextField(
      onChanged: (text) {
        setState(() {
          if (text.isEmpty) {
            upperXAxis = null;
          } else if (text == "-") {
            upperXAxis = null;
          } else {
            upperXAxis = double.parse(text);
          }
        });
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X axis max',
          labelText: 'X axis max'),
      inputFormatters: domainFormatters,
    );
  }

  Widget horizontalAxisMin() {
    return TextField(
      onChanged: (text) {
        setState(() {
          if (text.isEmpty) {
            lowerXAxis = null;
          } else if (text == "-") {
            lowerXAxis = null;
          } else {
            lowerXAxis = double.parse(text);
          }
        });
        _filterNoisyData();
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'X axis min',
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
          labelText: '*Domain max'),
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
          labelText: '*Domain min'),
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
        hintText: '*Enter an expression w.r.t. X',
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
        Switch(
            value: isTExpression,
            onChanged: (bool value) {
              setState(() {
                isTExpression = !isTExpression;
              });
            },
            thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Icon(MdiIcons.alphaT);
              }
              return Icon(MdiIcons.alphaX);
            })),
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
    if (lowerDomain >= upperDomain) {
      throw Exception("Domain is invalid");
    }
    if (lowerRange != null && upperRange != null) {
      if (lowerRange! >= upperRange!) {
        throw Exception("Range is invalid");
      }
    }
    if (lowerXAxis != null && upperXAxis != null) {
      if (lowerXAxis! >= upperXAxis!) {
        _snackBar("X axis is invalid");
        throw Exception("X axis is invalid");
      }
    }
    String texExpression;
    try {
      texExpression = '${TeXParser(typedExpression!).parse()}';
    } catch (e) {
      // snackbar
      _snackBar("Invalid expression");
      throw Exception("Invalid expression");
    }
    Expression functionExpression;
    try {
      functionExpression = Parser().parse(texExpression);
    } catch (e) {
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
              lowerDomain + (upperDomain - lowerDomain) * index / numPoints);
      // calculate true y values based on expression
      // generate yValuesWithNoise based on true y values and randomness
      yValues = xValues.map((x) {
        contextModel.bindVariable(expressionVariable, Number(x));
        return functionExpression.evaluate(EvaluationType.REAL, contextModel)
            as double;
      }).toList();
    });

    _makeNoisyData();
    _filterNoisyData();
  }

  _makeNoisyData() {
    final Random random = Random();
    double yRange = yValues.reduce(math.max) - yValues.reduce(math.min);
    if (yRange == 0) {
      yRange = yValues.reduce(math.max);
    }
    setState(() {
      yValuesNoisy = yValues.map((y) {
        int sign = random.nextBool() ? 1 : -1;
        double noise =
            random.nextDouble() * yRange * 0.1 * (randomnessStrength);
        noise *= sign;
        return y + noise;
      }).toList();
    });
  }

  _filterNoisyData() {
    List<double> newXValues = [];
    List<double> newYValuesNoisy = [];

    if (yValuesNoisy.isEmpty) {
      return;
    }

    for (int i = 0; i < yValuesNoisy.length; i++) {
      if (lowerXAxis != null && xValues[i] < lowerXAxis!) {
        continue;
      }
      if (upperXAxis != null && xValues[i] > upperXAxis!) {
        continue;
      }
      if (lowerYAxis != null && yValuesNoisy[i] < lowerYAxis!) {
        continue;
      }
      if (upperYAxis != null && yValuesNoisy[i] > upperYAxis!) {
        continue;
      }
      newXValues.add(xValues[i]);
      newYValuesNoisy.add(yValuesNoisy[i]);
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
      result.add(ScatterSpot(xValuesFiltered[i], yValuesNoisyFiltered[i],
          radius: 8, color: scatterBorderColor));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
