
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlkit/mlkit.dart';
import 'package:pi_gerente/classes/image_labels.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';



class LeitorPlacas extends StatefulWidget {

  @override
  _LeitorPlacasState createState() => _LeitorPlacasState();
}

class _LeitorPlacasState extends State<LeitorPlacas> {
  final imageLabels = ImageLabels();
  FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
  String resultado = "Resultado";
  String pagamento = "false";
  String textoImagem = "";
  var dados;

  //BarcodeScanner scanResult;

  Future _lerQr() async{
    try{
      var scanResult = await BarcodeScanner.scan();
      setState(() {
        pagamento =  scanResult.rawContent;
      });
      if(pagamento == "true"){
        Firestore.instance.collection("cancela").document("i8lmwUc59Ptf4Qpp4LgH").setData({"cancela" : "aberta"});
      };
    }on PlatformException catch(e){
      if(e.code == BarcodeScanner.cameraAccessDenied){
        setState(() {
          pagamento = "Permissão à câmera negada";
        });
        print(pagamento);
      }else{
        setState(() {
          pagamento = "Erro desconhecido! $e";
        });
      }
    } on FormatException{
      setState(() {
        pagamento = "Você pressionou o botão cedo demais!";
      });
    }catch(e) {
      setState(() {
        pagamento = "Erro desconhecido! $e";
      });
    }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  CollectionReference placaRef = Firestore.instance.collection("placa");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leitura de placas", style: TextStyle(color: Colors.black),),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.green,
                    Colors.lime
                  ]
              )
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                      child: resultado == "Resultado" ? Container():
                      StreamBuilder(
                        stream: Firestore.instance.collection("usuarios").document("wkzkIBtrnl2KRxklYlRw")
                        .snapshots(),
                        builder: (context, snapshot){
                          if(!snapshot.hasData){
                            return CircularProgressIndicator();
                          }
                          var documento = snapshot.data;
                          Map<String, dynamic> mapa = {
                            "nome" : documento["nome"],
                            "email" : documento["email"],
                            "placa" : documento["placa"]
                          };
                          return QrImage(
                            data: mapa.toString(),
                            version: QrVersions.auto,
                            size: 200,
                          );
                        },
                      )
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 30,
                child: RaisedButton(
                  color: Colors.green.withOpacity(0.5),
                    child: Text("Leitura da Placa"),
                    onPressed: () async {
                      String textoImagem = await imageLabels.pegarImagem();
                      setState(() {
                        resultado = textoImagem;
                        //dados = jsonDecode(lerDados("jsjjd").toString());
                      });
                    }
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 30,
                child: RaisedButton(
                    color: Colors.green.withOpacity(0.5),
                    child: Text("Leitura QRCode"),
                    onPressed: _lerQr
                ),
              ),
            ),
            pagamento != null ?
            Text(pagamento) :
                Container()
          ],
        ),
      ),
    );
  }
}
