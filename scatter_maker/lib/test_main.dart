import "package:math_expressions/math_expressions.dart";
import "package:math_keyboard/math_keyboard.dart";

String latexEquation = "19{x}^{2}+2{x}+1";
void main() {
  var mathExpression = TeXParser(latexEquation).parse();
  print("Virgin equation");
  print(mathExpression);
  print(mathExpression.runtimeType);
  print("Simplified equation");
  Expression simplifiedExpression = mathExpression.simplify();
  print(simplifiedExpression);
  print(simplifiedExpression.runtimeType);
  print("Simplified equation evaluated");
  ContextModel cm = ContextModel();
  cm.bindVariable(Variable("x"), Number(2));
  double result = simplifiedExpression.evaluate(EvaluationType.REAL, cm);
  print(result);
}