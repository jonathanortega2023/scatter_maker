// ignore_for_file: sort_child_properties_last

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:math_keyboard/math_keyboard.dart';
import "package:math_expressions/math_expressions.dart";
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scatter_maker/widgets/web_ads.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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

Offset getRegressionOffset(int index, Size size) {
  final widthStep = size.width / 16;
  final heightStep = size.height / 16;
  // goes by column
  switch (index) {
    case 0:
      return Offset(widthStep * 2, heightStep * 2);
    case 1:
      return Offset(widthStep * 2, heightStep * 5);
    case 2:
      return Offset(widthStep * 2, heightStep * 9);
    case 3:
      return Offset(widthStep * 2, heightStep * 13);
    case 4:
      return Offset(widthStep * 5, heightStep * 2);
    case 5:
      return Offset(widthStep * 5, heightStep * 5);
    case 6:
      return Offset(widthStep * 5, heightStep * 9);
    case 7:
      return Offset(widthStep * 5, heightStep * 13);
    case 8:
      return Offset(widthStep * 9, heightStep * 2);
    case 9:
      return Offset(widthStep * 9, heightStep * 5);
    case 10:
      return Offset(widthStep * 9, heightStep * 9);
    case 11:
      return Offset(widthStep * 9, heightStep * 13);
    case 12:
      return Offset(widthStep * 13, heightStep * 2);
    case 13:
      return Offset(widthStep * 13, heightStep * 5);
    case 14:
      return Offset(widthStep * 13, heightStep * 9);
    case 15:
      return Offset(widthStep * 13, heightStep * 13);
    default:
      return const Offset(0, 0);
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
      themeMode: ThemeMode.system,
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

  int _regressionPrecision = 3;
  // map between 0-3 and 1-0.001
  static const Map<int, double> _precisionLookup = {
    0: 1,
    1: 0.1,
    2: 0.01,
    3: 0.001,
  };
  bool plotRegressionEquation = true;
  bool showRegressionEquation = true;
  bool showRSquared = true;
  // RegressionLocation regressionLocation = RegressionLocation.topLeft;
  int regressionLocationIndex = 5;
  double? rSquared;
  String? rSquaredString;
  String? regressionEquationString;
  UnaryFunction<double>? regressionEquationFunction;

  double randomnessStrength = 0;

  int _aspectRatioMenuValue = 4;
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

  // tutorial keys
  final mathFieldKey = GlobalKey();
  final domainKey = GlobalKey();
  final numPointsKey = GlobalKey();
  final chartAspectRatioKey = GlobalKey();
  final generateDataKey = GlobalKey();
  final colorPickerKey = GlobalKey();
  final noiseLevelKey = GlobalKey();
  final polynomailRegressionKey = GlobalKey();
  final regressionPlacementKey = GlobalKey();
  final saveChartKey = GlobalKey();

  final AssetImage mathFieldImage =
      const AssetImage('assets/tutorial_screenshots/mathFieldKey.png');
  final AssetImage domainImage =
      const AssetImage('assets/tutorial_screenshots/domainKey.png');
  final AssetImage chartAspectRatioImage =
      const AssetImage('assets/tutorial_screenshots/chartAspectRatioKey.png');
  final AssetImage portraitAspectRatioImage =
      const AssetImage('assets/tutorial_screenshots/portraitChart.png');
  final AssetImage landscapeAspectRatioImage =
      const AssetImage('assets/tutorial_screenshots/landscapeChart.png');
  final AssetImage regressionPlacementImage1 = const AssetImage(
      'assets/tutorial_screenshots/regressionPlacementKey1.png');
  final AssetImage regressionPlacementImage2 = const AssetImage(
      'assets/tutorial_screenshots/regressionPlacementKey2.png');
  final AssetImage regressionPlacementImage3 = const AssetImage(
      'assets/tutorial_screenshots/regressionPlacementKey3.png');
  final AssetImage saveChartImage =
      const AssetImage('assets/tutorial_screenshots/saveChartKey.png');

  List<TargetFocus> getTargets() {
    return [
      TargetFocus(
        identify: "Math Field",
        keyTarget: mathFieldKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              alignment: Alignment.bottomRight,
              child: Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    """The expression box takes in a regular mathematical expression in terms of X.
                    It also opens an on-screen math keyboard for more advanced inputs.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _kSizedBoxH40,
                  Image(
                    width: 500,
                    image: mathFieldImage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Domain",
        keyTarget: domainKey,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Container(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    const Text(
                      """The domain values are used to truncate values from the x axis of the chart, they are not required.

                      Below, the domain max was set to 8.""",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _kSizedBoxH20,
                    Image(image: domainImage, width: 800)
                  ],
                ),
              )),
        ],
      ),
      TargetFocus(
        identify: "Num Points",
        keyTarget: numPointsKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: const Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    """The number of points defaults to 200. Modify with caution, as calculating too many points may slow down or crash the page.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Chart Aspect Ratio",
        keyTarget: chartAspectRatioKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                children: [
                  const Text(
                    """The chart aspect ratio changes the shape of the chart, defaults to wide.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _kSizedBoxH20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image(image: portraitAspectRatioImage, width: 400),
                      Image(image: chartAspectRatioImage, width: 200),
                      Image(image: landscapeAspectRatioImage, width: 600),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Generate Data",
        keyTarget: generateDataKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: const Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    """Once your chart options are set, click the Generate Data button to plot the regular expression.\n
                    Most chart options can be modified without regenerating the data.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Color Picker",
        keyTarget: colorPickerKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: const Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    """The color picker allows you to change the color of the scatter points, their fill, and the regression line.
                    Pick an option to modify with the respective button, then choose the color you'd like to use. Arrow resets to default color.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Noise Level",
        keyTarget: noiseLevelKey,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            child: Container(
              child: const Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    """
                    The noise level slider adjusts the amount of noise added to the data points.
                    Noisy data is normalized to stay within the range of the original function.

                    Approximate noise levels / R² values with the appropriate polynomial:
                    10%-20% -> 0.9 | 30% -> 0.7 | 50%-60% -> 0.5 | 70% -> 0.3
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Polynomial Regression",
        keyTarget: polynomailRegressionKey,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            child: Container(
              child: const Column(
                children: [
                  const SizedBox(
                    height: 200,
                  ),
                  const Text(
                    """Polynomial regression is the only option at this time. It can be adjusted to fit any degree from 0-5.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Regression Placement",
        keyTarget: regressionPlacementKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                children: [
                  const Text(
                    """Use this to place the regression equation on the relative region of the chart.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(image: regressionPlacementImage1, width: 500),
                      Image(image: regressionPlacementImage2, width: 500),
                      Image(image: regressionPlacementImage3, width: 500),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Save Chart",
        keyTarget: saveChartKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const Text(
                    """Click the Save Chart button to download the chart as a timestamped image.
                    """,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image(image: saveChartImage, width: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    ];
  }

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
              _kSizedBoxW20,
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
                      const Row(
                        children: [
                          PaypalDonateButton(),
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
          ]),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Created by Jonathan Ortega',
              ),
              Row(
                children: [
                  IconButton(
                      tooltip: 'GitHub',
                      onPressed: () {
                        html.window.open(
                            'https://github.com/jonathanortega2023/scatter_maker',
                            'blank');
                      },
                      icon: Icon(MdiIcons.github)),
                  IconButton(
                      tooltip: 'Website',
                      onPressed: () {
                        html.window.open('https://jonathan-ortega.me', 'blank');
                      },
                      icon: Icon(MdiIcons.web)),
                  IconButton(
                    tooltip: 'Info',
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      showAboutDialog(
                        context: context,
                        applicationLegalese: "",
                        applicationName: 'Scatter Maker',
                        applicationVersion: '1.0.0',
                        applicationIcon: const ImageIcon(
                            AssetImage('assets/icons/scatter_maker_logo.png')),
                        children: [
                          const Text(
                              'Scatter Maker is a tool for creating scatter plots, designed while I was teaching HS intro stats.'),
                          const Text(
                              'The tool is free to use and open source. If you like it, please consider donating.'),
                          _kSizedBoxH20,
                          const Divider(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Built with Flutter',
                                style: TextStyle(color: Colors.black54),
                              ),
                              FlutterLogo()
                            ],
                          )
                        ],
                      );
                    },
                  ),
                  _kSizedBoxW5,
                  ElevatedButton.icon(
                    onPressed: () {
                      showTutorial();
                    },
                    label: const Text('Tutorial'),
                    icon: const Icon(
                      Icons.question_mark,
                      size: 20,
                    ),
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        foregroundColor: WidgetStateProperty.all(Colors.white)),
                  ),
                  // IconButton(
                  //     tooltip: 'Tutorial',
                  //     onPressed: () {
                  //       showTutorial();
                  //     },
                  //     icon: const Icon(Icons.question_mark))
                ],
              )
            ],
          ).animate(effects: [
            const SlideEffect(
              delay: Duration(milliseconds: 250),
              duration: Duration(milliseconds: 1000),
              curve: Curves.bounceOut,
              begin: Offset(0, 2),
            )
          ])
        ]),
      ),
    ));
  }

  randomnessSlider() {
    // lock the slider if regression selected
    return AbsorbPointer(
      key: noiseLevelKey,
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
        stepSize: 0.05,
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
        key: saveChartKey,
        text: 'Save Chart',
        icon: Icons.download,
        onPressed: saveChart);
  }

  IconActionButton generateDataButton() {
    return IconActionButton(
        key: generateDataKey,
        text: 'Generate Data',
        icon: Icons.refresh,
        onPressed: generateData);
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
                      offset: getRegressionOffset(
                          regressionLocationIndex, chartSize),
                      // offset: Offset(
                      //     dotX * chartSize.width, dotY * chartSize.height),
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
    );
  }

  Widget regressionOptions() {
    return Column(
      children: [
        const Divider(),
        // TODO, precalculate all degrees and store them in a lookup
        CheckboxListTile(
            key: polynomailRegressionKey,
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
          title: const Text('Regression Equation Options'),
          children: [
            ListTile(
              // add option to change decimal precision
              title: const Text('Adjust regression decimal precision'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _regressionPrecision == 0
                        ? null
                        : () {
                            if (_regressionPrecision > 0) {
                              setState(() {
                                _regressionPrecision--;
                              });
                              _formatPolyEquationString();
                            }
                          },
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 20,
                  ),
                  Text("$_regressionPrecision",
                      style: const TextStyle(fontSize: 14)),
                  IconButton(
                    onPressed: _regressionPrecision == 3
                        ? null
                        : () {
                            if (_regressionPrecision < 3) {
                              setState(() {
                                _regressionPrecision++;
                              });
                              _formatPolyEquationString();
                            }
                          },
                    icon: const Icon(Icons.arrow_forward),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
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
            dense: false,
            visualDensity: VisualDensity.comfortable,
            // 8-direction dpad to move the regression equation around the graph
            trailing: Container(
                key: regressionPlacementKey,
                height: 50,
                width: 50,
                child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 4,
                    children: List.generate(16, (index) {
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              regressionLocationIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(0.5),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.5),
                                  color: regressionLocationIndex == index
                                      ? Colors.black
                                      : Colors.grey[200]),
                            ),
                          ));
                    }))),
            // trailing: GestureDetector(
            //     onPanUpdate: (details) {
            //       if (selectedRegressionOption == null) {
            //         return;
            //       }
            //       setState(() {
            //         dotX += details.delta.dx / 250;
            //         dotY += details.delta.dy / 250;
            //         dotX = dotX.clamp(0, 1);
            //         dotY = dotY.clamp(0, 1);
            //       });
            //     },
            //     onTapDown: (details) {
            //       if (selectedRegressionOption == null) {
            //         return;
            //       }
            //       setState(() {
            //         dotX = details.localPosition.dx / 50;
            //         dotY = details.localPosition.dy / 50;
            //       });
            //     },
            //     child: Container(
            //       width: 50,
            //       height: 50,
            //       decoration: BoxDecoration(
            //         border: Border.all(width: 1, color: Colors.black),
            //       ),
            //       child: Stack(
            //         children: [
            //           Positioned(
            //             left: dotX * 50 - 10,
            //             top: dotY * 50 - 10,
            //             child: const Icon(Icons.circle, size: 20),
            //           ),
            //         ],
            //       ),
            //     )),
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
      key: chartAspectRatioKey,
      isExpanded: true,
      hint: const Row(children: [
        Icon(Icons.screen_rotation),
        _kSizedBoxW5,
        Text('Chart Aspect Ratio')
      ]),
      items: [
        DropdownMenuItem<int>(
          value: 0,
          child: Row(children: [
            Transform.scale(
              scaleY: 1.25,
              child: const Icon(Icons.crop_portrait_sharp),
            ),
            _kSizedBoxW5,
            const Text('Tall'),
          ]),
        ),
        const DropdownMenuItem<int>(
          value: 1,
          child: Row(children: [
            Icon(Icons.crop_portrait_sharp),
            _kSizedBoxW5,
            Text('Portrait'),
          ]),
        ),
        const DropdownMenuItem<int>(
          value: 2,
          child: Row(children: [
            Icon(Icons.crop_square_sharp),
            _kSizedBoxW5,
            Text('Square'),
          ]),
        ),
        const DropdownMenuItem<int>(
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
            Transform.scale(
              scaleX: 1.25,
              child: const Icon(Icons.crop_landscape_sharp),
            ),
            _kSizedBoxW5,
            const Text('Wide'),
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
          border: OutlineInputBorder(), labelText: 'Title'),
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
          border: OutlineInputBorder(), labelText: 'Y label'),
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
          border: OutlineInputBorder(), labelText: 'X label'),
    );
  }

  Widget pointNumberForm() {
    return TextField(
      key: numPointsKey,
      onChanged: (text) {
        setState(() {
          numPoints = int.parse(text);
        });
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: "Data Points"),
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
          border: OutlineInputBorder(), labelText: 'Y axis interval'),
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
          border: OutlineInputBorder(), labelText: 'Y axis max'),
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
          border: OutlineInputBorder(), labelText: 'Y axis min'),
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
          border: OutlineInputBorder(), labelText: 'X axis interval'),
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
          border: OutlineInputBorder(), labelText: 'X axis max'),
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
          border: OutlineInputBorder(), labelText: 'X axis min'),
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
          border: OutlineInputBorder(), labelText: 'Range max'),
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
          border: OutlineInputBorder(), labelText: 'Range min'),
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
          border: OutlineInputBorder(), labelText: 'Domain max'),
      inputFormatters: domainFormatters,
    );
  }

  Widget lowerDomainForm() {
    return TextField(
      key: domainKey,
      onChanged: (text) {
        setState(() {
          lowerDomain = double.parse(text);
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Domain min',
      ),
      inputFormatters: domainFormatters,
    );
  }

  Widget equationField() {
    return MathField(
      key: mathFieldKey,
      variables: const ['X'],
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
      opensKeyboard: true,
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
              key: colorPickerKey,
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
    // get current time
    final now = DateTime.now();
    final filename =
        'scatter_chart_${now.hour % 12}_${now.minute}_${now.second}.png';
    screenshotController.capture().then((Uint8List? image) async {
      final blob = html.Blob([image], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
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
          // numPoints + 1 to include the upper bound
          numPoints + 1,
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
      setState(() {
        stringResult = result.polynomial.format(
          variable: 'X',
        );
      });
      _formatPolyEquationString();
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

  String? stringResult;

  _formatPolyEquationString() {
    if (stringResult == null) {
      return;
    }
    double precision = _precisionLookup[_regressionPrecision]!;
    String formattedResult = "";
    var terms = stringResult!.split(" + ");
    for (var term in terms) {
      double coefficient;
      if (!term.contains("X") && !term.contains("T")) {
        coefficient = double.parse(term);
        if (coefficient.abs() <= precision) continue;
        formattedResult += coefficient < 0 ? " - " : " + ";
        formattedResult +=
            coefficient.abs().toPrecision(_regressionPrecision).toString();
        continue;
      } else if (term.contains("X")) {
        coefficient = double.parse(term.split("X")[0]);
        if (coefficient.abs() <= precision) continue;
        formattedResult += coefficient < 0 ? " - " : " + ";
        formattedResult +=
            coefficient.abs().toPrecision(_regressionPrecision).toString();
        formattedResult += "X${term.split("X")[1]}";
      } else if (term.contains("T")) {
        coefficient = double.parse(term.split("T")[0]);
        if (coefficient.abs() <= precision) continue;
        formattedResult += coefficient < 0 ? " - " : " + ";
        formattedResult +=
            coefficient.abs().toPrecision(_regressionPrecision).toString();
        formattedResult += "T${term.split("T")[1]}";
      }
    }
    if (formattedResult.startsWith(" + ")) {
      formattedResult = formattedResult.substring(3);
    }
    // remove trailing zeroes
    formattedResult = formattedResult.replaceAll(RegExp(r"(\.0+)(?=\D)"), "");
    setState(() {
      regressionEquationString = "Ŷ = $formattedResult";
    });
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

  showTutorial() {
    TutorialCoachMark(
      targets: getTargets(),
      skipWidget: const Text(
        "Skip",
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    ).show(context: context);
  }
}
