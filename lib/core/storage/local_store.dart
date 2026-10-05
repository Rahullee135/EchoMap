import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Tiny JSON-file persistence layer rooted in the app documents directory.
class LocalStore {
  LocalStore._(this._root, this.audioDir);

  final Directory _root;
  final Directory audioDir;

  static Future<LocalStore> open() async {
    final root = await getApplicationDocumentsDirectory();
    final audio = Directory('${root.path}/echoes');
    if (!audio.existsSync()) audio.createSync(recursive: true);
    return LocalStore._(root, audio);
  }

  File _file(String name) => File('${_root.path}/$name');

  Future<Object?> readJson(String name) async {
    final file = _file(name);
    if (!file.existsSync()) return null;
    try {
      return jsonDecode(await file.readAsString());
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String name, Object data) =>
      _file(name).writeAsString(jsonEncode(data), flush: true);

  String audioPathFor(String id) => '${audioDir.path}/$id.m4a';
}
