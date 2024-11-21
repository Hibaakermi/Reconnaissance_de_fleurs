import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imgpicker/home/flower_classifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  String classificationResult = '';
  String flowerDescriptionResult = '';

  final FlowerClassifier flowerClassifier = FlowerClassifier(); // Instance de FlowerClassifier

  // Définir les descriptions de fleurs
  final Map<String, String> flowerDescriptions = {
    'daisy':'La marguerite est une fleur du genre Bellis.',
    'dandelion': 'Le pissenlit est une plante de la famille des Asteraceae.',
    'rose': 'Une rose est une fleur du genre Rosa.',
    'sunflower': 'Le tournesol est une plante de la famille des Asteraceae.',
    'tulip':'La tulipe est une plante à fleurs du genre Tulipa.'
  };

  @override
  void initState() {
    super.initState();
    flowerClassifier.loadModel(); // Charger le modèle lors de l'initialisation
  }

  Future<void> _imageFromCamera() async {
    _image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (_image != null) {
      setState(() {
        file = File(_image!.path);
      });
      await saveInStorage(file!);
      await classifyImage(file!);
    }
  }

  Future<void> _imageFromGallery() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      setState(() {
        file = File(_image!.path);
      });
      await saveInStorage(file!);
      await classifyImage(file!);
    }
  }

  Future<void> classifyImage(File image) async {
    try {
      // ignore: avoid_print
      print('Classifying image: ${image.path}');
      var output = await flowerClassifier.classifyImage(image);
      
      // ignore: avoid_print
      print("Nom de l'image classifiée: $output");
      

      String flowerDescription = flowerDescriptions[output.toLowerCase()] ?? 'Unknown flower';

      setState(() {
        classificationResult = output; // Nom de la fleur
        flowerDescriptionResult = flowerDescription; // Description de la fleur
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error during classification: $e');
      setState(() {
        classificationResult = 'Error classifying image';
      });
    }
  }

  Future<void> _checkPermission() async {
    var statusStorage = await Permission.storage.status;
    if (!statusStorage.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> saveInStorage(File file) async {
    await _checkPermission();
    var statusStorage = await Permission.storage.status;

    if (statusStorage.isGranted) {
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final Directory appDocDirFolder = Directory('${appDocDir.path}/App_demo/Images Media');

        if (!(await appDocDirFolder.exists())) {
          await appDocDirFolder.create(recursive: true);
        }

        var format = file.path.split('.').last;
        await file.copy('${appDocDirFolder.path}/${timestamp()}.$format');

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Successfully saved in the folder App_demo/Images Media',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // ignore: avoid_print
        print(e.toString());
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No permission to save the file',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose photo from gallery'),
                onTap: () {
                  _imageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo with camera'),
                onTap: () {
                  _imageFromCamera();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reconnaissance de fleurs'),
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(15.0),
              width: 300,
              height: 300,
              color: Colors.black26,
              child: file != null
                  ? Image.file(
                      file!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.camera_alt_outlined),
            ),
            if (classificationResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  classificationResult,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            if (flowerDescriptionResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  flowerDescriptionResult,
                  // ignore: prefer_const_constructors
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPicker(context);
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
