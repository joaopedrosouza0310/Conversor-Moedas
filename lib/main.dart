import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key= API_KEY_HERE";

void main() async {
  runApp(MaterialApp(
      home: HomeConversorMoedas(),
      theme: ThemeData(
          hintColor: Colors.amber,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))))));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class HomeConversorMoedas extends StatefulWidget {
  @override
  _HomeConversorMoedasState createState() => _HomeConversorMoedasState();
}

class _HomeConversorMoedasState extends State<HomeConversorMoedas> {
  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void realChanged(String text) {

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * dolar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {

    if(text.isEmpty) {
      _clearAll();
      return;
    }
    
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text(
          "\$ Conversor de Moedas \$",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$", realController, realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$", dolarController, dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    onChanged: function,
    style: TextStyle(color: Colors.amber, fontSize: 25),
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixText: prefix,
        labelStyle: TextStyle(color: Colors.amber)),
  );
}
