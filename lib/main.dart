import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:math_expressions/math_expressions.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _answer = '';
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      String recognizedWords = result.recognizedWords.toLowerCase();
      recognizedWords = _processInput(recognizedWords);
      _lastWords = recognizedWords.trim();
      _answer = evaluateExpression(_lastWords);
    });
  }
  String _processInput(String input) {
    input = input.replaceAll('plus', '+');
    input = input.replaceAll('add', '+');
    input = input.replaceAll('minus', '-');
    input = input.replaceAll('subtract', '-');
    input = input.replaceAll('times', '*');
    input = input.replaceAll('multiplied by', '*');
    input = input.replaceAll('divide', '/');
    input = input.replaceAll('divided by', '/');
    input = input.replaceAll(RegExp(r'[^0-9+\-*/\s]'), '');
    return input;
  }
  String evaluateExpression(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      String result = eval.toString();
      if (result.endsWith('.0')) {
        result = result.substring(0, result.length - 2);
      }
      return result;
    } catch (e) {
      return '...';
    }
  }
  Widget _buildButton(String text) {
    bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(text);
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (text == 'C') {
              _lastWords = '';
              _answer = '';
            } else if (text == '⌫') {
              if (_lastWords.isNotEmpty) {
                _lastWords = _lastWords.substring(0, _lastWords.length - 1);
                _answer = evaluateExpression(_lastWords);
              }
            } else {
              _lastWords += text;
              _answer = evaluateExpression(_lastWords);
            }
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isNumeric ? Color(0xFF193a4d) : Color(0xFF193a4d),
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(20.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 40.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 245,right: 16),
              child: Text(
                _answer,
                style: TextStyle(fontSize: 40, color: Colors.amber),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 100),
                  child: Text(
                      _speechToText.isListening
                          ? '$_lastWords'
                          : _answer.isNotEmpty
                              ? '$_lastWords'
                              : _speechEnabled
                                  ? 'Tap the microphone to start listening...'
                                  : 'Speech not available',
                      style: TextStyle(fontSize: 40, color: Colors.amber)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('/'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('*'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('-'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton('0'),
                  _buildButton('00'),
                  _buildButton('C'),
                  _buildButton('+'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: SizedBox(
                      width: 199, // Adjust the width to increase size
                      height: 86, // Adjust the height to increase size
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFF193a4d),
                          onPressed: () {
                            _speechToText.isNotListening
                                ? _startListening()
                                : _stopListening();
                          },
                          tooltip: 'Listen',
                          child: Icon(
                            _speechToText.isNotListening
                                ? Icons.mic_off
                                : Icons.mic,
                            color: Colors.amber,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildButton('.'),
                  _buildButton('⌫'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
