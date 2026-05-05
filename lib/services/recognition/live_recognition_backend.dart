import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';
import '../../models/artifact_result.dart';
import 'recognition_backend.dart';

// On-device recognition using the YOLOv8 ONNX model (best.onnx).
//
// Model details (inspected via onnxruntime Python):
//   Input  — 'images' : float32 [1, 3, 640, 640]  (NCHW, normalised 0–1)
//   Output — 'output0': float32 [1, 16, 8400]
//             16 = 4 bbox coords + 12 class scores
//             8400 = detection proposals across all grid scales
//
// Class labels (from model metadata):
//   0: woman_doves    1: woman_smoke     2: woman_fish
//   3: woman_horse    4: butterfly_women 5: musician_women
//   6: fish_net       7: seashell        8: abstract_colorburst
//   9: abstract_landscape  10: night_sky 11: bridge_sunset
class LiveRecognitionBackend implements RecognitionBackend {
  static const String _modelAsset = 'assets/models/best.onnx';
  static const int _inputSize = 640;
  static const int _numClasses = 12;
  static const double _confidenceThreshold = 0.30;

  // Maps class index → painting key (must match paintings.json and model order)
  static const List<String> _classLabels = [
    'woman_doves', 'woman_smoke', 'woman_fish', 'woman_horse',
    'butterfly_women', 'musician_women', 'fish_net', 'seashell',
    'abstract_colorburst', 'abstract_landscape', 'night_sky', 'bridge_sunset',
  ];

  OrtSession? _session;
  bool _loaded = false;

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> load() async {
    try {
      OrtEnv.instance.init();
      final sessionOptions = OrtSessionOptions();
      final rawAsset = await rootBundle.load(_modelAsset);
      final bytes = rawAsset.buffer.asUint8List();
      _session = OrtSession.fromBuffer(bytes, sessionOptions);
      _loaded = true;
      dev.log('Model loaded from $_modelAsset', name: 'LiveRecognitionBackend');
    } catch (e) {
      dev.log('Failed to load model: $e', name: 'LiveRecognitionBackend');
      _loaded = false;
    }
  }

  @override
  Future<ArtifactResult?> recognize(List<int>? frameBytes) async {
    if (!_loaded || _session == null || frameBytes == null) return null;

    try {
      // 1. Decode and resize image to 640×640
      final decoded = img.decodeImage(Uint8List.fromList(frameBytes));
      if (decoded == null) return null;

      final resized = img.copyResize(decoded,
          width: _inputSize, height: _inputSize,
          interpolation: img.Interpolation.linear);

      // 2. Convert to NCHW float32 tensor, normalised 0–1
      //    Layout: [R channel plane] [G channel plane] [B channel plane]
      final inputData = Float32List(_inputSize * _inputSize * 3);
      final planeSize = _inputSize * _inputSize;

      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          final offset = y * _inputSize + x;
          inputData[offset]               = pixel.r / 255.0; // R
          inputData[planeSize + offset]   = pixel.g / 255.0; // G
          inputData[2 * planeSize + offset] = pixel.b / 255.0; // B
        }
      }

      // 3. Run inference
      final inputTensor = OrtValueTensor.createTensorWithDataList(
        inputData, [1, 3, _inputSize, _inputSize],
      );
      final runOptions = OrtRunOptions();
      final outputs = await _session!.runAsync(
        runOptions, {'images': inputTensor},
      );

      inputTensor.release();
      runOptions.release();

      if (outputs == null || outputs.isEmpty) return null;

      // 4. Parse output [1, 16, 8400]
      //    outputs[0].value → List<List<List<double>>> shape [1][16][8400]
      final raw = outputs[0]?.value as List?;
      if (raw == null || raw.isEmpty) return null;

      // Shape: raw[0] is [16][8400]
      final channels = raw[0] as List; // 16 channels

      double maxConfidence = 0.0;
      int bestClass = -1;

      // Find the proposal with the highest single class score
      // channels[4..15] are the 12 class scores for each of 8400 proposals
      for (int proposal = 0; proposal < 8400; proposal++) {
        for (int c = 0; c < _numClasses; c++) {
          final score =
              (channels[4 + c] as List)[proposal] as double;
          if (score > maxConfidence) {
            maxConfidence = score;
            bestClass = c;
          }
        }
      }

      outputs[0]?.release();

      // 5. Apply confidence threshold
      if (bestClass < 0 || maxConfidence < _confidenceThreshold) return null;

      final key = _classLabels[bestClass];
      // Format key as readable display name: "woman_doves" → "Woman Doves"
      final displayName = key
          .split('_')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');

      return ArtifactResult(
        id: key,
        name: displayName,
        confidence: maxConfidence,
      );
    } catch (e) {
      dev.log('Inference error: $e', name: 'LiveRecognitionBackend');
      return null;
    }
  }
}
