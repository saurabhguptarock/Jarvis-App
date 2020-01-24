import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _query = ' ';
  List<Application> _apps;

  void speak(String text) async {
    setState(() {
      _query = text;
    });
    await flutterTts.speak(text);
  }

  void openApps(String appName) {
    String packageName = '';
    appName = appName.replaceAll(RegExp(r'open '), '');
    _apps.forEach((app) {
      print(app.appName);
      if (app.appName.toLowerCase() == appName) packageName = app.packageName;
    });
    print(appName);
    if (packageName == '')
      speak('Sorry cannot open $appName');
    else
      DeviceApps.openApp(packageName);
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
      setState(() {
        _query = s.recognizedWords;
      });
      if (s.finalResult) {
        setState(() {
          _isListening = false;
        });
        analyze(s.recognizedWords.toLowerCase());
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
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true);
    setState(() {
      _apps = apps;
    });
    await flutterTts.setLanguage('hi-IN');
    await flutterTts.setSpeechRate(0.6);
  }

  void speakYourAge() {
    DateTime now = DateTime.now();
    DateTime yearsOld = DateTime.utc(2020, 1, 20, 19, 38, 34);
    if (now.year - yearsOld.year > 0) {
      speak('i am ${now.year - yearsOld.year} years old');
    } else if (now.month - yearsOld.month > 0) {
      speak('i am ${now.month - yearsOld.month} months old');
    } else if (now.day - yearsOld.day > 0) {
      speak('i am ${now.day - yearsOld.day} days old');
    } else if (now.hour - yearsOld.hour > 0) {
      speak('i am ${now.hour - yearsOld.hour} hours old');
    } else if (now.minute - yearsOld.minute > 0) {
      speak('i am ${now.minute - yearsOld.minute} minutes old');
    } else if (now.second - yearsOld.second > 0) {
      speak('i am ${now.second - yearsOld.second} seconds old');
    }
  }

  void checkWeekDay() {
    if (DateTime.now().weekday == 0)
      speak('it is sunday');
    else if (DateTime.now().weekday == 1)
      speak('it is monday');
    else if (DateTime.now().weekday == 2)
      speak('it is tuesday');
    else if (DateTime.now().weekday == 3)
      speak('it is wednesday');
    else if (DateTime.now().weekday == 4)
      speak('it is thursday');
    else if (DateTime.now().weekday == 5)
      speak('it is friday');
    else if (DateTime.now().weekday == 6) speak('it is saturday');
  }

  void analyze(String text) {
    if (text == 'how are you' || text == 'how you doing')
      speak('i am good thank you');
    else if (text == 'what are you' || text == 'who are you')
      speak('i am an AI powered chatbot made by saurabh');
    else if (text == 'what made you' || text == 'who made you')
      speak('i was made by saurabh');
    else if (text == 'how old are you' ||
        text == 'what is your age' ||
        text == "what's your age")
      speakYourAge();
    else if (text == 'what laguages can you speak' ||
        text == 'what laguage can you speak')
      speak('currently i only speak english');
    else if (text == 'what day it is' || text == 'what day is it')
      checkWeekDay();
    else if (text.contains('open '))
      openApps(text);
    else if (text.contains('open'))
      speak('open what, please say it again');
    else
      speak("Sorry, I didn't understand that");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff4C4DF1),
        elevation: 0,
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
      body: Stack(
        children: <Widget>[
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 40,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  _query.length > 0
                      ? _query[0].toUpperCase() + _query.substring(1)
                      : _query,
                  maxLines: 3,
                  style: GoogleFonts.lato(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              child: FlareActor("assets/flare/Animatedorb.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "Aura"),
            ),
          ),
        ],
      ),
    );
  }
}
