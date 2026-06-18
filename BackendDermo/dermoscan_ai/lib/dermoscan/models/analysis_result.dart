import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisResult {
  final String id;
  final String label;
  final String labelFr;
  final double confidence;
  final double probability;
  final double threshold;
  final String advice;
  final String riskLevel;
  final String imagePath;
  final String imageBase64;
  final DateTime analyzedAt;

  const AnalysisResult({
    required this.id,
    required this.label,
    required this.labelFr,
    required this.confidence,
    required this.probability,
    required this.threshold,
    required this.advice,
    required this.riskLevel,
    required this.imagePath,
    required this.imageBase64,
    required this.analyzedAt,
  });

  bool get isMalignant => label == 'malignant';

  Map<String, dynamic> toFirestore() => {
    'label':       label,
    'label_fr':    labelFr,
    'confidence':  confidence,
    'probability': probability,
    'threshold':   threshold,
    'advice':      advice,
    'risk_level':  riskLevel,
    'image_path':  imagePath,
    'image_base64': imageBase64,
    'analyzed_at': Timestamp.fromDate(analyzedAt), 
  };

  factory AnalysisResult.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data()!;
    return AnalysisResult(
      id:          doc.id,
      label:       map['label']       ?? 'benign',
      labelFr:     map['label_fr']    ?? 'Bénin',
      confidence:  (map['confidence'] ?? 0.0).toDouble(),
      probability: (map['probability'] ?? 0.0).toDouble(),
      threshold:   (map['threshold']  ?? 0.5).toDouble(),
      advice:      map['advice']      ?? '',
      riskLevel:   map['risk_level']  ?? 'low',
      imagePath:   map['image_path']  ?? '',
      imageBase64: map['image_base64'] ?? '',
      analyzedAt:  (map['analyzed_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id':           id,
    'label':        label,
    'label_fr':     labelFr,
    'confidence':   confidence,
    'probability':  probability,
    'threshold':    threshold,
    'advice':       advice,
    'risk_level':   riskLevel,
    'image_path':   imagePath,
    'image_base64': imageBase64,
    'analyzed_at':  analyzedAt.toIso8601String(),
  };

  factory AnalysisResult.fromMap(Map<String, dynamic> map) => AnalysisResult(
    id:          map['id']           ?? '',
    label:       map['label']        ?? 'benign',
    labelFr:     map['label_fr']     ?? 'Bénin',
    confidence:  (map['confidence']  ?? 0.0).toDouble(),
    probability: (map['probability'] ?? 0.0).toDouble(),
    threshold:   (map['threshold']   ?? 0.5).toDouble(),
    advice:      map['advice']       ?? '',
    riskLevel:   map['risk_level']   ?? 'low',
    imagePath:   map['image_path']   ?? '',
    imageBase64: map['image_base64'] ?? '',
    analyzedAt:  DateTime.parse(
      map['analyzed_at'] ?? DateTime.now().toIso8601String(),
    ),
  );
}