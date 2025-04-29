import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:femaura/core/utils/secure_storage/secure_storage_key_const.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  factory SecureStorage() => _instance;

  SecureStorage._();

  static final SecureStorage _instance = SecureStorage._();

  final _flutterSecureStorage = const FlutterSecureStorage();

  Map<String, String> _data = {};

  Future<void> init() async {
    final stringData = await _flutterSecureStorage.read(key: 'fem-ss');

    if (stringData != null) {
      final decoded = jsonDecode(stringData) as Map<String, dynamic>;
      _data = Map<String, String>.from(decoded);
      log('Secure Storage initialized with data: $_data');
    }
  }

  String? read({required SecureStorageKeys key}) => _data[key.toString()];

  Future<void> write({
    required SecureStorageKeys key,
    required String value,
  }) async {
    _data[key.toString()] = value;
    await _encodeJsonAndWriteToSecureStorage();
  }

  Future<void> delete({required SecureStorageKeys key}) async {
    _data.remove(key.toString());
    await _encodeJsonAndWriteToSecureStorage();
    log('Secure Storage deleted key: ${key.toString()}');
    log('Secure Storage data: $_data');
  }

  Future<void> _encodeJsonAndWriteToSecureStorage() async {
    final jsonData = jsonEncode(_data);
    await _flutterSecureStorage.write(key: 'fem-ss', value: jsonData);
  }
}
