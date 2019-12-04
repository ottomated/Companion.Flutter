import 'package:companion/main.dart';
import 'package:companion/models/userModel.dart';
import 'package:companion/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan/barcode_scan.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _bannerVisible = false;
  String _bannerText;
  Icon _bannerIcon;

  hideBanner() {
    setState(() {
      _bannerVisible = false;
    });
  }

  showBanner({String text, IconData icon}) {
    setState(() {
      _bannerVisible = true;
      _bannerText = text;
      _bannerIcon = Icon(icon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CodeDay"),
      ),
      body: Column(
        children: [
          if (_bannerVisible)
            IntrinsicHeight(
              child: MaterialBanner(
                content: Text(_bannerText),
                leading: _bannerIcon,
                forceActionsBelow: true,
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      setState(() {
                        _bannerVisible = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Center(
              child: LoginForm(parent: this),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final _LoginPageState parent;

  LoginForm({this.parent});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showHelp = false;
  TextEditingController _emailController;
  final RegExp _email = new RegExp(
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$");

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  Future<Ticket> logIn(String email) async {
    widget.parent.hideBanner();
    var ticket =
        await Provider.of<UserModel>(context, listen: false).logIn(email);
    return ticket;
  }

  Future<Ticket> logInWithTicket(String code) async {
    widget.parent.hideBanner();
    var ticket = await Provider.of<UserModel>(context, listen: false)
        .logInWithTicket(code);
    return ticket;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Image.asset("assets/codeday_logo.png"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            validator: (value) {
              if (_email.hasMatch(value)) {
                return null;
              } else {
                return "Please enter a valid email";
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
              suffixIcon: IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  setState(() {
                    _showHelp = !_showHelp;
                  });
                },
              ),
            ),
          ),
          if (_showHelp)
            Text(
              "Sign in with the same email you used to register for CodeDay.",
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("SIGN IN WITH EMAIL"),
                color: Color(0xFF80C2DA),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Searching for your ticket...'),
                      ),
                    );
                    Ticket ticket = await logIn(_emailController.text);
                    Scaffold.of(context).hideCurrentSnackBar();
                    if (ticket != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    }
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text("or"),
              ),
              RaisedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text("SCAN TICKET"),
                color: Color(0xFF76C597),
                onPressed: () async {
                  var code = await BarcodeScanner.scan();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Searching for your ticket $code...'),
                    ),
                  );
                  Ticket ticket = await logInWithTicket(code);
                  Scaffold.of(context).hideCurrentSnackBar();
                  if (ticket != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
