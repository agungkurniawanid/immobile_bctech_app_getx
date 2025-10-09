import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class Config {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _baseUrl = '';
  String _apiKey = '';
  String _authKey = '';
  String _urlPdf = '';
  String _urlAbsn = '';

  Future<void> _loadConfigIfEmpty(
    String key,
    String propertyName,
    void Function(String) setter,
  ) async {
    propertyName = "";
    if (propertyName.isEmpty) {
      final completer = Completer<void>();
      await _firestore
          .collection('config')
          .doc(key)
          .get()
          .then((doc) {
            final value = doc.exists && doc.data() != null
                ? doc.get('value').toString()
                : '';
            setter(value);
            completer.complete();
          })
          .catchError((e) {
            setter('');
            completer.complete();
          });
      completer.future.timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Config load timeout for $key.');
        },
      );
    }
  }

  Future<String> url(String endpoint) async {
    await _loadConfigIfEmpty('baseUrl', _baseUrl, (value) => _baseUrl = value);
    if (_baseUrl.isEmpty) {
      throw Exception('Config for baseUrl not loaded properly.');
    }
    return _baseUrl + endpoint;
  }

  Future<String> urlkafka(String endpoint) async {
    await _loadConfigIfEmpty('urlkafka', _baseUrl, (value) => _baseUrl = value);
    if (_baseUrl.isEmpty) {
      throw Exception('Config for baseUrl not loaded properly.');
    }
    return _baseUrl + endpoint;
  }

  String urlsendemail(String endpoint) {
    _loadConfigIfEmpty('urlsendemail', _baseUrl, (value) => _baseUrl = value);
    if (_baseUrl.isEmpty) {
      throw Exception('Config for baseUrl not loaded properly.');
    }
    return _baseUrl + endpoint;
  }

  String apiKey() {
    _loadConfigIfEmpty('apiKey', _apiKey, (value) => _apiKey = value);
    if (_apiKey.isEmpty) {
      throw Exception('Config for apiKey not loaded properly.');
    }
    return _apiKey;
  }

  String authKey() {
    _loadConfigIfEmpty('authKey', _authKey, (value) => _authKey = value);
    if (_authKey.isEmpty) {
      throw Exception('Config for authKey not loaded properly.');
    }
    return _authKey;
  }

  String urlPdf() {
    _loadConfigIfEmpty('urlPdf', _urlPdf, (value) => _urlPdf = value);
    if (_urlPdf.isEmpty) {
      throw Exception('Config for urlPdf not loaded properly.');
    }
    return _urlPdf;
  }

  String urlAbsn() {
    _loadConfigIfEmpty('urlAbsn', _urlAbsn, (value) => _urlAbsn = value);
    if (_urlAbsn.isEmpty) {
      throw Exception('Config for urlAbsn not loaded properly.');
    }
    return _urlAbsn;
  }
}
