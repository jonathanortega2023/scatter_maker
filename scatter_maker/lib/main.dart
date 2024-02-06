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

const donateLink =
    "https://www.paypal.com/donate/?business=C8ES9DJA6YMBQ&no_recurring=0&currency_code=USD";
final donateURI = Uri.parse(donateLink);

final domainFormatters = [
  LengthLimitingTextInputFormatter(7),
  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
];

void main() {
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  List<ScatterSpot> fakeScatterPoints = [
    ScatterSpot(1, 1),
    ScatterSpot(2, 2),
    ScatterSpot(3, 3),
    ScatterSpot(4, 4),
    ScatterSpot(5, 5),
    ScatterSpot(6, 6),
    ScatterSpot(7, 7),
    ScatterSpot(8, 8),
    ScatterSpot(9, 9),
    ScatterSpot(10, 10),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("y =", style: TextStyle(fontSize: 25)),
              Expanded(child: equationField(), flex: 2),
              Expanded(child: variableToggle()),
              Expanded(child: lowerDomainForm()),
              Expanded(child: upperDomainForm()),
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
              Expanded(child: horizontalAxisMax()),
              Expanded(child: horizontalAxisInterval()),
              Expanded(child: xAxisLabelForm(), flex: 2),
              Expanded(child: verticalAxisMin()),
              Expanded(child: verticalAxisMax()),
              Expanded(child: verticalAxisInterval()),
              Expanded(child: yAxisLabelForm(), flex: 2),
              Expanded(child: titleLabelForm(), flex: 3),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: threeColorPicker()),
            ],
          ),
          const Divider(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              flex: 2,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                regressionOptions(),
                randomnessSlider(),
                const Divider(),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    donateButton(),
                    Row(
                      children: [
                        generateButton(),
                        saveButton(),
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

  Slider randomnessSlider() {
    return Slider(
      value: randomnessStrength * 10,
      onChanged: (value) {
        setState(() {
          randomnessStrength = value / 10;
        });
        _makeDataNoisy();
        _filterNoisyData();
      },
      min: 0,
      max: 100,
      divisions: 20,
      label: randomnessStrength.toStringAsFixed(2),
    );
  }

  ElevatedButton saveButton() {
    return ElevatedButton(
      onPressed: () {
        saveChart();
      },
      child: const Text("Save", style: TextStyle(fontSize: 20)),
    );
  }

  ElevatedButton generateButton() {
    return ElevatedButton(
        onPressed: () {
          try {
            generateData();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        },
        child: const Text("Generate", style: TextStyle(fontSize: 20)),
    );
  }

  ElevatedButton donateButton() {
    return ElevatedButton(
        onPressed: () {
          html.window.open(donateLink, 'new tab');
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.paypal),
            Text(
              "Donate",
              style: TextStyle(fontSize: 20),
            )
          ],
        ));
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
        hintText: '*Enter an expression w.r.t. X or T',
        labelText: 'Expression',
      ),
      opensKeyboard: false,
    );
  }

  Widget variableToggle() {
    return Switch(
        value: isTExpression,
        onChanged: (bool value) {
          setState(() {
            isTExpression = !isTExpression;
          });
        },
        thumbIcon: MaterialStateProperty.resolveWith<Icon>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Icon(MdiIcons.alphaT);
          }
          return Icon(MdiIcons.alphaX);
        }));
  }
Widget threeColorPicker() {
  return Row(
    children: [
      ButtonBar(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                colorPickerIndex = 0;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  colorPickerIndex == 0
                      ? Colors.blue.withOpacity(.25)
                      : Colors.white),
            ),
            child: const Text("Point Border"),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: scatterBorderColor,
              shape: BoxShape.circle,
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  scatterBorderColor = Colors.purple;
                });
              },
              icon: Transform.flip(
                  flipX: true, child: const Icon(Icons.refresh))),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                colorPickerIndex = 1;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  colorPickerIndex == 1
                      ? Colors.blue.withOpacity(.25)
                      : Colors.white),
            ),
            child: const Text("Point Fill"),
          ),
          Stack(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: scatterBorderColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: scatterFillColor,
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.translationValues(5, 5, 0))
            ],
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  scatterFillColor = Colors.white;
                });
              },
              icon: Transform.flip(
                  flipX: true, child: const Icon(Icons.refresh))),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                colorPickerIndex = 2;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  colorPickerIndex == 2
                      ? Colors.blue.withOpacity(.25)
                      : Colors.white),
            ),
            child: const Text("Regression Line"),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: regressionLineColor,
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  regressionLineColor = Colors.blue;
                });
              },
              icon: Transform.flip(
                  flipX: true, child: const Icon(Icons.refresh))),
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
          color: colorPickerIndex == 0
              ? scatterBorderColor
              : colorPickerIndex == 1
                  ? scatterFillColor
                  : regressionLineColor,
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.accent: false,
          },
        ),
      ),
    ],
  );
}

  // TODO Fix chart saving, currently only saves the grid without labels
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
      throw Exception("Expression is null");
    }
    if (typedExpression!.isEmpty) {
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
    setState(() {
      typedExpression = '${TeXParser(typedExpression!).parse()}';
      Expression functionExpression = Parser().parse(typedExpression!);
      print(functionExpression);
      ContextModel contextModel = ContextModel();
      Variable expressionVariable = Variable(isTExpression ? 'T' : 'X');
      contextModel.bindVariable(expressionVariable, functionExpression);
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

    _makeDataNoisy();
    _filterNoisyData();
  }

  _makeDataNoisy() {
    final Random random = Random();
    double yRange = yValues.reduce(math.max) - yValues.reduce(math.min);

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

    Set<int> removalIndices = {};

    for (int i = 0; i < yValuesNoisy.length; i++) {
      if ((lowerRange != null && yValuesNoisy[i] < lowerRange!) ||
          (upperRange != null && yValuesNoisy[i] > upperRange!) ||
          (lowerXAxis != null && xValues[i] < lowerXAxis!) ||
          (upperXAxis != null && xValues[i] > upperXAxis!) ||
          (lowerYAxis != null && yValuesNoisy[i] < lowerYAxis!) ||
          (upperYAxis != null && yValuesNoisy[i] > upperYAxis!)) {
        removalIndices.add(i);
      } else {
        newXValues.add(xValues[i]);
        newYValuesNoisy.add(yValuesNoisy[i]);
      }
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
      result.add(ScatterSpot(xValues[i], yValuesNoisyFiltered[i],
          radius: 8, color: scatterBorderColor));
    }
    if (scatterBorderColor != scatterFillColor) {
      for (int i = 0; i < yValuesNoisyFiltered.length; i++) {
        result.add(ScatterSpot(xValues[i], yValuesNoisyFiltered[i],
            radius: 3, color: scatterFillColor));
      }
    }
    return result;
  }
}
