import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText speech = stt.SpeechToText();
  bool _isListening = false;

  void speak(String text) async {
    await flutterTts.speak(text);
  }

  void listen() async {
    await speech.initialize(onStatus: (txt) {}, onError: (error) {});
    if (_isListening) {
      speech.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }
    setState(() {
      _isListening = true;
    });
    speech.listen(onResult: (s) {
      if (s.finalResult) {
        setState(() {
          _isListening = false;
        });
        analyze(s.recognizedWords);
      }
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech?.cancel();
    speech?.stop();
    super.dispose();
  }

  void initialize() async {
    await flutterTts.setLanguage('hi-IN');
  }

  void analyze(String text) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: listen,
        child: _isListening
            ? Icon(
                Icons.mic_off,
                size: 30,
              )
            : Icon(
                Icons.mic,
                size: 30,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: SizedBox(
          child: FlareActor("assets/flare/Animated orb.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "Aura"),
        ),
      ),
    );
  }
}
