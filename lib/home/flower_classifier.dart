// ignore: file_names

import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

class FlowerClassifier {
  // Variable pour savoir si le modèle est chargé
  bool _isModelLoaded = false;

  // Charge le modèle TFLite
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/flower_classifier.tflite",
        labels: "assets/flower_labels.txt",
      );
      // ignore: avoid_print
      print("Modèle chargé: $res");
      _isModelLoaded = true;  // Marquer le modèle comme chargé
    } catch (e) {
      // ignore: avoid_print
      print("Erreur lors du chargement du modèle: $e");
    }
  }

  // Fonction pour vérifier si le modèle est chargé
  bool isModelLoaded() {
    return _isModelLoaded;
  }

  // Fonction de classification
  Future<String> classifyImage(File image) async {
    try {
      if (!_isModelLoaded) {
        return 'Modèle non chargé';
      }

      // Charger l'image et la redimensionner à la taille appropriée pour le modèle (par exemple, 224x224)
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
      img.Image resizedImage = img.copyResize(imageInput!, width: 224, height: 224);

      // Convertir l'image redimensionnée en format utilisé par le modèle
      var recognitions = await Tflite.runModelOnBinary(
        binary: resizedImage.getBytes(),
        numResults: 1, // Nombre de résultats souhaités
        threshold: 0.5, // Confiance minimum
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        var label = recognitions[0]["label"] as String;
        return label;
      } else {
        return "Fleur non reconnue";
      }
    } catch (e) {
      return "Erreur";
    }
  }

  // Décharge le modèle pour libérer de la mémoire
  Future<void> dispose() async {
    await Tflite.close();
    _isModelLoaded = false; // Réinitialiser l'état du modèle
  }
}
