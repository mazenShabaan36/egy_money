import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
//import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_tts/flutter_tts.dart';



class CurrPage {
  static File? currImage;
  static BuildContext? context;

  // ignore: unused_field
  static List? _output;
  static final FlutterTts flutterTts = FlutterTts();

  static void currencyDetect(BuildContext buildContext, File img) {
    loadModel().then((value) {
      // setState(() {});
    });
    context = buildContext;
    currImage = img;
    speakCurrencyValue();
  }

  static classifyCurrency(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 1,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    print("This is the $output");
    print("This is the ${output![0]['label']}");
    dynamic label = output[0]['label'];
    print(label.runtimeType);
    _speak(label);
    _output = output;
    showCaptionDialog(label, image);
  }

  static loadModel() async {
    try {
      await Tflite.loadModel(
        model:
            "assets/model_unquant.tflite", //"assets/currency_classifier2.tflite",
        labels: "assets/labels.txt", //"assets/egyptian_money.txt",
      );
    } catch (e) {
      print('Failed to load TFLite model: $e');
    }
  }

  static speakCurrencyValue() {
    classifyCurrency(currImage!);
  }

  static Future _speak(String output) async {
     await flutterTts.speak(output);
  }

  static Future<void> showCaptionDialog(String text, File picture) async {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text('Currency Label',style: TextStyle(
                 // color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 23,
                  letterSpacing: 1.1,
                ),),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Container(
                        width: 300.0,
                        height: 20,
                      ),
                      new Image.file(picture),
                       SizedBox(
                        height: MediaQuery.of(context).size.height*0.04,
                      ),
                      new Text("$text".substring(2),style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context as BuildContext,
        // ignore: missing_return
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  // ignore: unused_element
  static void _stopTts() {
     flutterTts.stop();
  }
}
//