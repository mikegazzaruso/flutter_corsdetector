import 'package:flutter_web/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CORS Detector',
      theme: ThemeData.dark(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dead or Alive - Made with Flutter'),
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
                          helperText: "Enter a FQDN or an URL",
                          hintText: "Ex.: http://server.to.test",
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
              child: Text(_message),
            ),
          ],
        ),
      ),
    );
  }

  _handleOnChanged(String value) {
    setState(() {
      _canVerify = value.isNotEmpty;
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
      _isBusy = false;
      switch (error.toString()) {
        case 'XMLHttpRequest error.':
          _message = 'This server seems to deny cross origin requests';
          break;
        default:
          _message = 'There was an unexpected error';
      }
      setState(() {});
      u.text = _message;
      window.speechSynthesis.speak(u);
    });
  }
}
