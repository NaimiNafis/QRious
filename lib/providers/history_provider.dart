import 'package:flutter/material.dart';
import '../api/db_helper.dart';
import '../models/qr_code_model.dart';

class HistoryProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<QRCodeModel> _history = [];
  List<QRCodeModel> get history => _history;

  HistoryProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    _history = await _dbHelper.getQRCodes();
    notifyListeners();
  }

  Future<void> addQRCode(String content, String type, {bool isSafe = true}) async {
    final newCode = QRCodeModel(
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isSafe: isSafe,
    );
    await _dbHelper.insertQRCode(newCode);
    await fetchHistory();
  }

  Future<void> toggleFavorite(int id) async {
    final code = _history.firstWhere((element) => element.id == id);
    final updatedCode = QRCodeModel(
      id: code.id,
      content: code.content,
      type: code.type,
      isFavorite: !code.isFavorite,
      timestamp: code.timestamp,
      isSafe: code.isSafe,
    );
    await _dbHelper.updateQRCode(updatedCode);
    await fetchHistory();
  }

  Future<void> deleteQRCode(int id) async {
    await _dbHelper.deleteQRCode(id);
    await fetchHistory();
  }

  Future<void> deleteMultipleQRCodes(List<int> ids) async {
    await _dbHelper.deleteMultipleQRCodes(ids);
    await fetchHistory();
  }

  Future<void> toggleFavoriteMultiple(List<int> ids, bool makeFavorite) async {
    for (int id in ids) {
      final code = _history.firstWhere(
        (element) => element.id == id,
        orElse: () => throw Exception('QR Code not found'),
      );
      
      // Only update if the favorite status is different
      if (code.isFavorite != makeFavorite) {
        final updatedCode = QRCodeModel(
          id: code.id,
          content: code.content,
          type: code.type,
          isFavorite: makeFavorite,
          timestamp: code.timestamp,
          isSafe: code.isSafe,
        );
        await _dbHelper.updateQRCode(updatedCode);
      }
    }
    await fetchHistory();
  }
}

// Manages history/favorites state and logic