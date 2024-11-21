import 'package:flutter/material.dart';
import 'home/home_page.dart'; // Assurez-vous que ce chemin est correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flower Recognition App', // Titre personnalisé
      theme: ThemeData(
        primarySwatch: Colors.green, // Couleur primaire
        visualDensity: VisualDensity.adaptivePlatformDensity, // Ajustement de la densité visuelle
        brightness: Brightness.dark, // Thème sombre
      ),
      home: const HomeScreen(), // Page d'accueil
    );
  }
}
