import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_keyboard/math_keyboard.dart';
import "package:math_expressions/math_expressions.dart";
import "package:simple_icons/simple_icons.dart";
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fl_chart/fl_chart.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class EquationField extends StatefulWidget {
  const EquationField({super.key});

  @override
  State<EquationField> createState() => _EquationFieldState();
}

class _EquationFieldState extends State<EquationField> {
  String? typedExpression;
  late MathField mathField;
  MathFieldEditingController? mathFieldController =
      MathFieldEditingController();

  @override
  void initState() {
    super.initState();
    mathField = MathField(
      variables: const ['X', 'T'],
      controller: mathFieldController,
      onChanged: updateExpression,
      autofocus: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter an expression w.r.t. X or T',
        labelText: 'Expression',
      ),
      opensKeyboard: false,
    );
  }

  void updateExpression(String value) {
    setState(() {
      typedExpression = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return mathField;
  }
}

class VariableSelector extends StatefulWidget {
  const VariableSelector({super.key});

  @override
  State<VariableSelector> createState() => _VariableSelectorState();
}

class _VariableSelectorState extends State<VariableSelector> {
  bool value = false;

  late Switch variableToggle;
  MaterialStateProperty<Icon> thumbIcon =
      MaterialStateProperty.resolveWith<Icon>((Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Icon(MdiIcons.alphaT);
    }
    return Icon(MdiIcons.alphaX);
  });

  @override
  void initState() {
    super.initState();
    variableToggle =
        Switch(value: value, onChanged: onChanged, thumbIcon: thumbIcon);
  }

  void onChanged(bool value) {
    setState(() {
      this.value = !value;
    });
    variableToggle =
        Switch(value: value, onChanged: onChanged, thumbIcon: thumbIcon);
  }

  @override
  Widget build(BuildContext context) {
    return variableToggle;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color scatterBorderColor = Colors.purple;
  Color scatterFillColor = Colors.white;
  late ButtonBar scatterPointColorBorderHeading;

  String? xLabel;
  String? yLabel;
  String? chartTitle;

  double lowerDomain = -10;
  double upperDomain = 10;
  int numPoints = 50;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Text("y = ", style: TextStyle(fontSize: 25)),
                  Flexible(child: EquationField()),
                  VariableSelector(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Flexible(child: lowerDomainForm()),
                  Flexible(child: upperDomainForm()),
                  Flexible(child: pointNumberForm()),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(children: [
                Flexible(
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
                Flexible(
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
                Flexible(
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
              ]),
            ),
            Divider(),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Flexible(
                        child: scatterPointColorPicker(
                            ButtonBar(children: [
                              Text("Scatter point border:"),
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
                            updatePointBorderColor)),
                    Flexible(
                        child: scatterPointColorPicker(
                            ButtonBar(children: [
                              Text("Scatter point fill:"),
                              Stack(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    // border with fill
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
                                      transform:
                                          Matrix4.translationValues(5, 5, 0))
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
                            updatePointFillColor)),
                  ],
                )),
            Divider(),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: ScatterChart(
                  ScatterChartData(
                      scatterSpots: [
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
                      ],
                      scatterTouchData: ScatterTouchData(enabled: false),
                      showingTooltipIndicators: null,
                      scatterLabelSettings:
                          ScatterLabelSettings(showLabel: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                            axisNameWidget: Text(chartTitle ?? "Title",
                                style: TextStyle(fontSize: 30)),
                            axisNameSize: 40),
                        leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 30),
                            axisNameWidget: Text(yLabel ?? "Y",
                                style: TextStyle(fontSize: 20)),
                            axisNameSize: 30),
                        bottomTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 30),
                            axisNameWidget: Text(xLabel ?? "X",
                                style: TextStyle(fontSize: 20)),
                            axisNameSize: 30),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AxisTitles createAxisTitles({String? xLabel, String? yLabel}) {
    return AxisTitles();
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

  ColorPicker scatterPointColorPicker(heading, color, onColorChanged) {
    return ColorPicker(
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
}
