import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class ImageLabels{
  final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

  pegarImagem() async {
    File response = await ImagePicker.pickImage(source: ImageSource.camera);
    String text;
    try{
      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(response);
      VisionText visionText = await textRecognizer.processImage(visionImage);
      text = visionText.text;
    }catch(e){
      text = "Sem foto";
    }
    return text;
  }
}