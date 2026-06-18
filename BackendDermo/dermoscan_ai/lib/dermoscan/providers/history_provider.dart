import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/analysis_result.dart';

final currentUidProvider = StreamProvider<String?>((ref) {
  return FirebaseAuth.instance
      .authStateChanges()
      .map((user) => user?.uid);
});

class HistoryNotifier extends StateNotifier<List<AnalysisResult>> {
  HistoryNotifier() : super([]) {
    _initFuture = _loadHistory();
  }

  late final Future<void> _initFuture;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('analyses');
  }

  Future<void> _loadHistory() async {
    try {
      final col = _collection;
      if (col == null) {
        if (mounted) state = [];
        return;
      }

      final snapshot = await col
          .orderBy('analyzed_at', descending: true)
          .limit(20)
          .get();

      final results = snapshot.docs
          .map((doc) => AnalysisResult.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>,
              ))
          .toList();

      if (mounted) state = results;
    } catch (e) {
      debugPrint('Erreur loadHistory: $e');
      if (mounted) state = [];
    }
  }

  Future<void> loadHistory() => _initFuture;

  Future<void> saveResult(AnalysisResult result) async {
    await _initFuture;

    try {
      final col = _collection;
      if (col == null) return;

      await col.doc(result.id).set(result.toFirestore());

      final updated = [result, ...state].take(20).toList();
      if (mounted) state = updated;
    } catch (e) {
      debugPrint('Erreur saveResult: $e');
    }
  }

  Future<void> deleteResult(String id) async {
    try {
      await _collection?.doc(id).delete();
      if (mounted) {
        state = state.where((e) => e.id != id).toList();
      }
    } catch (e) {
      debugPrint('Erreur deleteResult: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final col = _collection;
      if (col == null) return;

      final snapshot = await col.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) state = [];
    } catch (e) {
      debugPrint('Erreur clearHistory: $e');
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<AnalysisResult>>(
  (ref) {
    ref.watch(currentUidProvider);
    return HistoryNotifier();
  },
);