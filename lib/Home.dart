import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List <bool> _isSelected;
  String _baixas = "", _casosRegistrados = "", _pacientesRecuperados = "";
  String _baixasMundo = "", _casosRegistradosMundo = "", _pacientesRecuperadosMundo = "";
  String _baixasBrasil = "", _casosRegistradosBrasil = "", _pacientesRecuperadosBrasil = "";
  String _imagemCentral;

  _buscarDados() async{
    http.Response _response;
    String url = "https://api.covid19api.com/summary";
    _response = await http.get(url);
    Map<String, dynamic> _dadosMundo = json.decode(_response.body);

    _baixasMundo = _dadosMundo["Global"]["TotalDeaths"].toString();
    _casosRegistradosMundo = _dadosMundo["Global"]["TotalConfirmed"].toString();
    _pacientesRecuperadosMundo = _dadosMundo["Global"]["TotalRecovered"].toString();

    _buscarDadosMundo();
    url = "https://api.covid19api.com/country/brazil";
    _response = await http.get(url);
    List _dadosBrasil = json.decode(_response.body);

    _baixasBrasil = _dadosBrasil[_dadosBrasil.length-1]["Deaths"].toString();
    _casosRegistradosBrasil = _dadosBrasil[_dadosBrasil.length-1]["Confirmed"].toString();
    _pacientesRecuperadosBrasil = _dadosBrasil[_dadosBrasil.length-1]["Recovered"].toString();

  }

  _buscarDadosMundo(){
    setState(() {
      _baixas = _baixasMundo;
      _casosRegistrados = _casosRegistradosMundo;
      _pacientesRecuperados = _pacientesRecuperadosMundo;
      _imagemMortes = "images/mortes.png";
      _imagemCasos = "images/casos.png";
      _imagemRecuperados = "images/recuperados.png";
      _textoRecuperados = " Pacientes recuperados.";
      _textoMortes = " Baixas.";
      _textoCasos = " Casos registrados.";
      if (_imagemCentral != "mundo") {
        _imagemCentral = "mundo";
      }
    });
  }

  _buscarDadosBrasil(){
    setState(() {
      _baixas = _baixasBrasil;
      _casosRegistrados = _casosRegistradosBrasil;
      _pacientesRecuperados = _pacientesRecuperadosBrasil;
      if (_imagemCentral != "brasil"){
        _imagemCentral = "brasil";
      }
    });
  }
  _formatarValor(String valor) {
    String _novoValor = "";
    for(int i = 0, pontos = 0; i < valor.length; i++){
      _novoValor = "${valor.substring((valor.length - i - 1) ,(valor.length - i))}$_novoValor";
      if((_novoValor.length - pontos) % 3 == 0 && (_novoValor.length - pontos) != valor.length ){
        _novoValor = "." + _novoValor;
        pontos = pontos + 1;
      }
    }
    return _novoValor;
  }
  _alterarVisualizacao(index){
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
      if(_isSelected[0]){
        _buscarDadosMundo();
      } else {
        _buscarDadosBrasil();
      }
    });
  }

  @override
  void initState(){
    _buscarDados();
    _isSelected = [true, false];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff252525),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.png"),
            fit: BoxFit.scaleDown,
          ),
        ),
        padding: EdgeInsets.only(top: 60),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "COVID",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w100),
                ),
                Text(
                  "19",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              "REPORT",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 26),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
            ),
            ToggleButtons(
              //borderColor: Colors.black,
              fillColor: Color(0xFF303030),
              borderWidth: 1,
              selectedBorderColor: Color.fromRGBO(235, 235, 235, 0.5),
              selectedColor: Color(0xFFE4E4E4),
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(228, 228, 228, 0.25),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 12, 45, 12),
                  child: Text(
                    'Mundo',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 12, 45, 12),
                  child: Text(
                    'Brasil',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
              onPressed: (int index) {
                _alterarVisualizacao(index);
              },
              isSelected: _isSelected,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset("images/$_imagemCentral.png", key: UniqueKey()),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
              ),
            ),
            AnimatedSwitcher(
              child: _casosBaixas(UniqueKey()),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              duration: Duration(milliseconds: 500),
            ),
            AnimatedSwitcher(
              child: _linhaCasosRegistrados(UniqueKey()),
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
            ),
            AnimatedSwitcher(
              child: _casosRecuperados(UniqueKey()),
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
            ),
          ],
        ),
      ),
    );
  }
  String _imagemMortes = "", _textoMortes = "";
  Row _casosBaixas(_key){
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(60, 0, 10, 0),
          child: Image.asset(_imagemMortes),
        ),
        Text(
          _formatarValor(_baixas),
          style: TextStyle(
              color: Color(0xFFE4E4E4),
              fontSize: 16,
              fontWeight: FontWeight.w800),
        ),
        Text(
          _textoMortes,
          style: TextStyle(
              color: Color(0xFFE4E4E4),
              fontSize: 16,
              fontWeight: FontWeight.w300),
        )
      ],
      key: _key,
    );
  }

  String _imagemCasos = "", _textoCasos = "";
  Padding _linhaCasosRegistrados(_key){
    return Padding(
      padding: EdgeInsets.fromLTRB(60, 32, 0, 32),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Image.asset(_imagemCasos),
          ),
          Text(
            _formatarValor(_casosRegistrados),
            style: TextStyle(
                color: Color(0xFFE4E4E4),
                fontSize: 16,
                fontWeight: FontWeight.w800),
          ),
          Text(
            _textoCasos,
            style: TextStyle(
                color: Color(0xFFE4E4E4),
                fontSize: 16,
                fontWeight: FontWeight.w300),
          )
        ],
      ),
      key: _key,
    );
  }

  String _imagemRecuperados = "", _textoRecuperados = "";
  Row _casosRecuperados(_key){
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(60, 0, 10, 0),
          child: Image.asset(_imagemRecuperados),
        ),
        Text(
          _formatarValor(_pacientesRecuperados),
          style: TextStyle(
              color: Color(0xFFE4E4E4),
              fontSize: 16,
              fontWeight: FontWeight.w800),
        ),
        Text(
          _textoRecuperados,
          style: TextStyle(
              color: Color(0xFFE4E4E4),
              fontSize: 16,
              fontWeight: FontWeight.w300),
        )
      ],
      key: _key,
    );
  }

}