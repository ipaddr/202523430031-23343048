import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tflite Image Classifier',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TFLiteHome(),
    );
  }
}

class TFLiteHome extends StatefulWidget {
  const TFLiteHome({super.key});

  @override
  State<TFLiteHome> createState() => _TFLiteHomeState();
}

class _TFLiteHomeState extends State<TFLiteHome> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  List<dynamic>? _recognitions;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Fungsi memuat model dan label
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      print("Model loaded state: $res");
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print("Gagal memuat model: $e");
    }
  }

  // Fungsi klasifikasi gambar
  Future<void> runModelOnImage(File image) async {
    if (!_isModelLoaded) return;

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );

    setState(() {
      _recognitions = recognitions;
    });
  }

  // Fungsi memilih gambar (Kamera/Galeri)
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _recognitions = null;
      });
      runModelOnImage(imageFile);
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Klasifikasi Gambar"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const Text(
                    'Pilih gambar untuk diklasifikasi',
                    style: TextStyle(fontSize: 16),
                  )
                : Image.file(
                    _image!,
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  ),

            const SizedBox(height: 20),

            // Area hasil deteksi
            _recognitions != null
                ? Column(
                    children: _recognitions!.map((res) {
                      return Text(
                        "${res["label"]} - ${(res["confidence"] * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  )
                : Container(),
          ],
        ),
      ),

      // Floating Button
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_kamera",
            onPressed: () => pickImage(ImageSource.camera),
            tooltip: "Ambil Foto",
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn_galeri",
            onPressed: () => pickImage(ImageSource.gallery),
            tooltip: "Dari Galeri",
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
