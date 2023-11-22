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
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  lowerDomainForm(),
                  upperDomainForm(),
                  // Flexible(child: horizontalAxisMin()),
                  // Flexible(child: horizontalAxisMax()),
                  pointNumberForm(),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(children: [
                xAxisLabelForm(),
                yAxisLabelForm(),
                titleLabelForm(),
              ]),
            ),
            const Divider(),
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    scatterPointBorderPicker(),
                    scatterPointFillPicker(),
                  ],
                )),
            Divider(),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Row(children: [
                  RegressionOptionsWidget(),
                  ScatterChartGraph(
                      chartTitle: chartTitle, yLabel: yLabel, xLabel: xLabel)
                ]),
              ),
            ),
          ],
        ),
      ),
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

  Widget horizontalAxisMax() {
    return TextField(
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
    );
  }

  Widget horizontalAxisMin() {
    return TextField(
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
}

class RegressionOptionsWidget extends StatefulWidget {
  @override
  _RegressionOptionsWidgetState createState() =>
      _RegressionOptionsWidgetState();
}

class _RegressionOptionsWidgetState extends State<RegressionOptionsWidget> {
  int _selectedOption =
      0; // 0: Color Picker, 1: Polynomial Regression, 2: Exponential Regression

  Color _regressionLineColor = Colors.blue;
  int _polynomialDegree = 2;
  bool _showPolynomialEquation = false;
  bool _showPolynomialCorrelation = false;
  bool _showExponentialEquation = false;
  bool _showExponentialCorrelation = false;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          ListTile(
            title: Text("Regression Line Color"),
            trailing: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _regressionLineColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              _selectOption(0);
            },
          ),
          ListTile(
            title: Text("Polynomial Regression"),
            trailing: Radio(
              value: 1,
              groupValue: _selectedOption,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                _selectOption(value);
              },
            ),
            onTap: () {
              _selectOption(1);
            },
          ),
          if (_selectedOption == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Polynomial Degree'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _polynomialDegree = int.tryParse(value) ?? 2;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Show Equation on Graph'),
                    value: _showPolynomialEquation,
                    onChanged: (value) {
                      setState(() {
                        _showPolynomialEquation = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Show Correlation on Graph'),
                    value: _showPolynomialCorrelation,
                    onChanged: (value) {
                      setState(() {
                        _showPolynomialCorrelation = value ?? false;
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
              groupValue: _selectedOption,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                _selectOption(value);
              },
            ),
            onTap: () {
              _selectOption(2);
            },
          ),
          if (_selectedOption == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text('Show Equation on Graph'),
                    value: _showExponentialEquation,
                    onChanged: (value) {
                      setState(() {
                        _showExponentialEquation = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Show Correlation on Graph'),
                    value: _showExponentialCorrelation,
                    onChanged: (value) {
                      setState(() {
                        _showExponentialCorrelation = value ?? false;
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

  void _selectOption(int option) {
    setState(() {
      _selectedOption = option;
    });
  }
}

class ScatterChartGraph extends StatelessWidget {
  const ScatterChartGraph({
    super.key,
    required this.chartTitle,
    required this.yLabel,
    required this.xLabel,
  });

  final String? chartTitle;
  final String? yLabel;
  final String? xLabel;

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
            scatterLabelSettings: ScatterLabelSettings(showLabel: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                  axisNameWidget: Text(chartTitle ?? "Title",
                      style: TextStyle(fontSize: 30)),
                  axisNameSize: 40),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  axisNameWidget:
                      Text(yLabel ?? "Y", style: TextStyle(fontSize: 20)),
                  axisNameSize: 30),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  axisNameWidget:
                      Text(xLabel ?? "X", style: TextStyle(fontSize: 20)),
                  axisNameSize: 30),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            )),
      ),
    );
  }
}
