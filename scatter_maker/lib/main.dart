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
        sliderTheme: SliderThemeData(
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

  MathFieldEditingController? mathFieldController =
      MathFieldEditingController();
  String? typedExpression;
  bool isTExpression = false;
  double lowerDomain = -10;
  double upperDomain = 10;

  double? lowerXAxis;
  double? upperXAxis;
  double? lowerYAxis;
  double? upperYAxis;

  int numPoints = 50;

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

  double chartAspectRatio = 1.8;
  List<double> xValues = [];
  List<double> yValues = [];
  List<double> yValuesWithNoise = [];

  // TODO Fix chart saving, currently only saves the grid without labels
  RenderRepaintBoundary? chartRenderBoundary;

  List<ScatterSpot> fakeScatterData = [
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
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("y = ", style: TextStyle(fontSize: 25)),
                ),
                equationField(),
                variableToggle(),
                lowerDomainForm(),
                upperDomainForm(),
                pointNumberForm(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                horizontalAxisMin(),
                horizontalAxisMax(),
                xAxisLabelForm(),
                verticalAxisMin(),
                verticalAxisMax(),
                yAxisLabelForm(),
                titleLabelForm(),
              ],
            ),
          ),
          const Divider(),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  scatterPointBorderPicker(),
                  scatterPointFillPicker(),
                  regressionLineColorPicker(),
                ],
              )),
          const Divider(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(children: [
                Flexible(
                  child: Column(
                    children: [
                      regressionOptions(),
                      // TODO Implement randomness
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
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      // Text("Aspect Ratio"),
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
                      scatterChartGraph(),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Slider randomnessSlider() {
    return Slider(
      value: 0,
      min: 0,
      max: 1,
      divisions: 1,
      label: "Randomness",
      onChanged: (value) {},
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

  Padding generateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: ElevatedButton(
        // TODO Implement scattering
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
      ),
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
      child: AspectRatio(
        aspectRatio: chartAspectRatio,
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: fakeScatterData,
            scatterTouchData: ScatterTouchData(enabled: false),
            showingTooltipIndicators: null,
            scatterLabelSettings: ScatterLabelSettings(showLabel: false),
            backgroundColor: Colors.white,
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                  axisNameWidget: Text(chartTitle ?? "Title",
                      style: const TextStyle(fontSize: 30)),
                  axisNameSize: 40),
              leftTitles: AxisTitles(
                  sideTitles:
                      const SideTitles(showTitles: true, reservedSize: 50),
                  axisNameWidget:
                      Text(yLabel ?? "Y", style: const TextStyle(fontSize: 20)),
                  axisNameSize: 30),
              bottomTitles: AxisTitles(
                  sideTitles:
                      const SideTitles(showTitles: true, reservedSize: 50),
                  axisNameWidget:
                      Text(xLabel ?? "X", style: const TextStyle(fontSize: 20)),
                  axisNameSize: 30),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }

  Widget regressionOptions() {
    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Regression equation: ${regressionEquation ?? "Calculated upon generation"}"),
          ),
          ListTile(
            title: Text("Polynomial Regression"),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    title: Text('Show Equation on Graph'),
                    value: showPolynomialEquation,
                    onChanged: (value) {
                      setState(() {
                        showPolynomialEquation = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Show Correlation on Graph'),
                    value: showPolynomialCorrelation,
                    onChanged: (value) {
                      setState(() {
                        showPolynomialCorrelation = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ListTile(
            title: Text("Exponential Regression"),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text('Show Equation on Graph'),
                    value: showExponentialEquation,
                    onChanged: (value) {
                      setState(() {
                        showExponentialEquation = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Show Correlation on Graph'),
                    value: showExponentialCorrelation,
                    onChanged: (value) {
                      setState(() {
                        showExponentialCorrelation = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget regressionLineColorPicker() {
    return Flexible(
        child: ColorPicker(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      heading: ButtonBar(children: [
        const Text("Regression line color:"),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: regressionLineColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              regressionLineColor = Colors.blue;
            });
          },
        ),
      ]),
      borderColor: Colors.black,
      hasBorder: true,
      color: regressionLineColor,
      enableShadesSelection: false,
      onColorChanged: updateRegressionLineColor,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.accent: false,
      },
    ));
  }

  ColorPicker scatterPointColorPicker(heading, color, onColorChanged) {
    return ColorPicker(
        // showColorCode: true,
        // showColorName: true,
        // showColorValue: true,
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        heading: heading,
        borderColor: Colors.black,
        hasBorder: true,
        color: color,
        enableShadesSelection: false,
        onColorChanged: onColorChanged,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.accent: false,
        });
  }

  Widget scatterPointBorderPicker() {
    return Flexible(
        child: scatterPointColorPicker(
            ButtonBar(children: [
              const Text("Scatter point border:"),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: scatterBorderColor,
                  shape: BoxShape.circle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    scatterBorderColor = Colors.purple;
                  });
                },
              ),
            ]),
            scatterBorderColor,
            updatePointBorderColor));
  }

  Widget scatterPointFillPicker() {
    return Flexible(
        child: scatterPointColorPicker(
            ButtonBar(children: [
              const Text("Scatter point fill:"),
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
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    scatterFillColor = Colors.white;
                  });
                },
              ),
            ]),
            scatterFillColor,
            updatePointFillColor));
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

  Flexible titleLabelForm() {
    return Flexible(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              chartTitle = text;
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Title',
              labelText: 'Title'),
        ),
      ),
    );
  }

  Flexible yAxisLabelForm() {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              yLabel = text;
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Y label',
              labelText: 'Y label'),
        ),
      ),
    );
  }

  Flexible xAxisLabelForm() {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              xLabel = text;
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'X label',
              labelText: 'X label'),
        ),
      ),
    );
  }

  Widget pointNumberForm() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
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
        ),
      ),
    );
  }

  Widget verticalAxisMax() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              upperYAxis = double.parse(text);
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Y axis max',
              labelText: 'Y axis max'),
          inputFormatters: domainFormatters,
        ),
      ),
    );
  }

  Widget verticalAxisMin() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              lowerYAxis = double.parse(text);
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Y axis min',
              labelText: 'Y axis min'),
          inputFormatters: domainFormatters,
        ),
      ),
    );
  }

  Widget horizontalAxisMax() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              upperDomain = double.parse(text);
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'X axis max',
              labelText: 'X axis max'),
          inputFormatters: domainFormatters,
        ),
      ),
    );
  }

  Widget horizontalAxisMin() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          onChanged: (text) {
            setState(() {
              lowerDomain = double.parse(text);
            });
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'X axis min',
              labelText: 'X axis min'),
          inputFormatters: domainFormatters,
        ),
      ),
    );
  }

  Widget upperDomainForm() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
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
        ),
      ),
    );
  }

  Widget lowerDomainForm() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
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
        ),
      ),
    );
  }

  Flexible equationField() {
    return Flexible(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MathField(
              variables: const ['X', 'T'],
              controller: mathFieldController,
              onChanged: (value) {
                setState(() {
                  typedExpression = value;
                });
              },
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter an expression w.r.t. X or T',
                labelText: 'Expression',
              ),
              opensKeyboard: false,
            )));
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
    double yRange = yValues.reduce(math.max) - yValues.reduce(math.min);
    // Generate yValuesWithNoise based on true y values and randomness.
    final Random random = Random();
    // yValuesWithNoise = trueYValues.map((y) {
    //   double noise = random.nextDouble() * yRange * 0.1;
    //   return y + noise;
    // }).toList();
    setState(() {
      fakeScatterData = List.generate(numPoints,
          (index) => ScatterSpot(xValues[index], yValues[index].toDouble()));
    });
  }
}
