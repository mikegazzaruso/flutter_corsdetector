import 'package:flutter_web/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CORS Detector',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Titillium Web',
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() {
    return _MyHomePage();
  }
}

class _MyHomePage extends State<MyHomePage> {
  final _myController = TextEditingController();
  bool _canVerify;
  bool _isBusy;
  String _message;

  @override
  void initState() {
    _canVerify = false;
    _isBusy = false;
    _message = '';
    super.initState();
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CORS Detector - Made in Flutter For Web'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        onChanged: (value) => _handleOnChanged(value),
                        controller: _myController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          helperText: "Enter a valid http(s) URL",
                          hintText: "Ex.: https://server.to.test",
                          helperStyle: TextStyle(
                            fontSize: 18.0,
                          ),
                          hintStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: !_isBusy
                        ? RaisedButton(
                            color: Theme.of(context).accentColor,
                            textColor: Colors.black,
                            child: Text('VERIFY'),
                            onPressed:
                                _canVerify ? () => _verifyEndpoint() : null,
                          )
                        : CircularProgressIndicator(),
                  )
                ],
              ),
            ),
            Flexible(
              child: Text(
                _message,
                style: TextStyle(
                  fontSize: 22.0,
                  color: _message.contains('allow') ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleOnChanged(String value) {
    const urlPattern =
        r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    final match = RegExp(urlPattern, caseSensitive: false).firstMatch(value);
    setState(() {
      _canVerify = match != null;
    });
  }

  _verifyEndpoint() {
    final URL = _myController.text;
    setState(() {
      _isBusy = true;
    });
    http.get(URL).then((response) {
      final u = SpeechSynthesisUtterance();
      u.lang = 'en-US';
      u.rate = 1.0;
      _isBusy = false;
      print(response.body);
      if (response.body == 'Not Found') {
        _message = "Sorry: can't resolve this endpoint";
      } else {
        _message = response.statusCode != null
            ? 'This server seems to allow cross origin requests'
            : 'This server seems to deny cross origin requests';
      }
      setState(() {});
      u.text = _message;
      window.speechSynthesis.speak(u);
    }).catchError((error) {
      final u = SpeechSynthesisUtterance();
      u.lang = 'en-US';
      u.rate = 1.0;
      setState(() {
        _isBusy = false;
        _message = "This server seems to deny cross origin requests";
      });
      u.text = _message;
      window.speechSynthesis.speak(u);
    });
  }
}
