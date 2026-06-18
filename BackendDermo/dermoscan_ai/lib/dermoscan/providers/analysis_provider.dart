import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; 
import 'dart:convert';
import '../models/analysis_result.dart';
import 'dart:convert';

enum AnalysisStatus { idle, loading, success, error }

class AnalysisState {
  final AnalysisStatus status;
  final AnalysisResult? result;
  final String? errorMessage;
  final Uint8List? selectedImageBytes;
  final String? selectedImageName;

  const AnalysisState({
    this.status = AnalysisStatus.idle,
    this.result,
    this.errorMessage,
    this.selectedImageBytes,
    this.selectedImageName,
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    AnalysisResult? result,
    String? errorMessage,
    Uint8List? selectedImageBytes,
    String? selectedImageName,
  }) =>
      AnalysisState(
        status:             status             ?? this.status,
        result:             result             ?? this.result,
        errorMessage:       errorMessage       ?? this.errorMessage,
        selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
        selectedImageName:  selectedImageName  ?? this.selectedImageName,
      );
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier() : super(const AnalysisState());

  static const String _baseUrl = 'http://localhost:8000/api/v1';

  void selectImage(Uint8List imageBytes, String fileName) {
    state = state.copyWith(
      selectedImageBytes: imageBytes,
      selectedImageName:  fileName,
      status:             AnalysisStatus.idle,
      result:             null,
      errorMessage:       null,
    );
  }

  Future<void> analyzeImage({Uint8List? imageBytes}) async {
    final bytes = imageBytes ?? state.selectedImageBytes;
    if (bytes == null) {
      state = state.copyWith(
        status:       AnalysisStatus.error,
        errorMessage: 'Aucune image sélectionnée',
      );
      return;
    }

    state = state.copyWith(status: AnalysisStatus.loading);

    try {
      final fileName  = state.selectedImageName ?? 'image.jpg';
      final ext       = fileName.split('.').last.toLowerCase();
      final mediaType = _resolveMediaType(ext);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/predict'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename:    fileName,
          contentType: mediaType,   
        ),
      );

      final streamed  = await request.send()
          .timeout(const Duration(seconds: 30));
      final response  = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data   = jsonDecode(response.body) as Map<String, dynamic>;
        final result = AnalysisResult(
          id:          DateTime.now().millisecondsSinceEpoch.toString(),
          label:       data['label']      as String,
          labelFr:     data['label_fr']   as String,
          confidence:  (data['confidence'] as num).toDouble(),
          probability: (data['probability'] as num).toDouble(),
          threshold:   (data['threshold']   as num).toDouble(),
          advice:      data['advice']     as String,
          riskLevel:   data['risk_level'] as String,
          imagePath:   '',
          imageBase64: base64Encode(bytes),             
          analyzedAt:  DateTime.now(),
        );

        state = state.copyWith(
          status: AnalysisStatus.success,
          result: result,
        );
      } else {
        String detail = 'Erreur serveur (${response.statusCode})';
        try {
          detail = (jsonDecode(response.body) as Map)['detail'] ?? detail;
        } catch (_) {}
        state = state.copyWith(
          status:       AnalysisStatus.error,
          errorMessage: detail,
        );
      }
    } on http.ClientException catch (e) {
      state = state.copyWith(
        status:       AnalysisStatus.error,
        errorMessage: 'Erreur de connexion : ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        status:       AnalysisStatus.error,
        errorMessage: 'Erreur inattendue : $e',
      );
    }
  }

  MediaType _resolveMediaType(String ext) {
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  void reset() => state = const AnalysisState();
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) => AnalysisNotifier(),
);