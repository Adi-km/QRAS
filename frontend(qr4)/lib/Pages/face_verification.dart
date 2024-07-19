import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class FaceRecognitionPage extends StatefulWidget {
  final String userId;

  const FaceRecognitionPage({super.key, required this.userId});

  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  late Interpreter _interpreter;
  late List<double> _storedFaceVector;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
    _loadModel();
    _fetchStoredFaceVector(widget.userId);
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {});
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(enableContours: true, enableClassification: true),
    );
  }

  void _loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  void _fetchStoredFaceVector(String userId) async {
    const API = '';
    final response = await http.get(Uri.parse('$API/face_vector?id=$userId'));
    if (response.statusCode == 200) {
      setState(() {
        _storedFaceVector = List<double>.from(json.decode(response.body));
      });
    } else {
      // Handle error

    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    _interpreter.close();
    super.dispose();
  }

  Future<void> _detectAndMatchFace() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }
    final image = await _cameraController.takePicture();
    final inputImage = InputImage.fromFilePath(image.path);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces.first;
      final boundingBox = face.boundingBox;
      final imageBytes = await image.readAsBytes();
      final img.Image originalImage = img.decodeImage(imageBytes)!;
      final faceCrop = img.copyCrop(
        originalImage,
        x : boundingBox.left.toInt(),
        y : boundingBox.top.toInt(),
        width : boundingBox.width.toInt(),
        height : boundingBox.height.toInt(),
      );

      const modelOutSize = 128;  //Fix model size
      final input = _preprocessFace(faceCrop);
      final output = List.filled(modelOutSize, 0.0).reshape([1, modelOutSize]); //
      _interpreter.run(input, output);

      // Perform matching with the stored face vector
      final currentFaceVector = output[0];
      final isMatch = _compareFaceVectors(currentFaceVector, _storedFaceVector);
      bool isFaceVerified = false;
      if (isMatch) {
        isFaceVerified = true;
        Navigator.pop(context, isFaceVerified);
      } else {
        Navigator.pop(context, isFaceVerified);
      }
    }
  }

  List<List<List<List<double>>>> _preprocessFace(img.Image faceCrop) {
    final input = List.generate(
      1,
          (index) => List.generate(
        faceCrop.height,
            (y) => List.generate(
          faceCrop.width,
              (x) {
            final pixel = faceCrop.getPixel(x, y);
            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          },
        ),
      ),
    );
    return input;
  }

  bool _compareFaceVectors(List<double> vector1, List<double> vector2, {double threshold = 0.0}) { //Set threshold
    double distance = 0.0;
    for (int i = 0; i < vector1.length; i++) {
      distance += (vector1[i] - vector2[i]) * (vector1[i] - vector2[i]);
    }
    distance = math.sqrt(distance);
    return distance < threshold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _cameraController.value.isInitialized
          ? CameraPreview(_cameraController)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _detectAndMatchFace,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
