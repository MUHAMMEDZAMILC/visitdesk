import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/utils/date_helper.dart';
import '../models/visitor.dart';

/// Stores each visitor as a JSON file:
/// `<app documents>/visitdesk_data/visitors/<id>.json`.
/// On first launch the folder is seeded from `assets/data/visitors/`.
class VisitorRepository {
  static const _seedAssetDir = 'assets/data/visitors/';
  static const _rootName = 'visitdesk_data';

  Directory? _dir;

  /// Absolute path of the visitors folder (created and seeded on first use).
  Future<String> get dataPath async => (await _visitorsDir()).path;

  Future<Directory> _visitorsDir() async {
    if (_dir != null) return _dir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_rootName/visitors');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      await _seed(dir);
    }
    debugPrint('VisitDesk data folder: ${dir.path}');
    return _dir = dir;
  }

  Future<void> _seed(Directory dir) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final asset in manifest.listAssets()) {
      if (!asset.startsWith(_seedAssetDir) || !asset.endsWith('.json')) {
        continue;
      }
      final name = asset.substring(_seedAssetDir.length);
      await File('${dir.path}/$name')
          .writeAsString(await rootBundle.loadString(asset));
    }
  }

  File _file(Directory dir, String id) => File('${dir.path}/$id.json');

  Future<Visitor> _read(File f) async => Visitor.fromJson(
    jsonDecode(await f.readAsString()) as Map<String, dynamic>,
  );

  /// Writes the file and returns the record as it will be read back
  /// (e.g. an empty email becomes null).
  Future<Visitor> _write(Directory dir, Visitor v) async {
    final json = v.toCacheJson();
    await _file(
      dir,
      v.id,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    return Visitor.fromJson(json);
  }

  Future<Visitor> _require(Directory dir, String id) async {
    final f = _file(dir, id);
    if (!await f.exists()) {
      throw const ApiException('Record not found.', statusCode: 404);
    }
    return _read(f);
  }

  Future<List<Visitor>> getVisitors() => _guard(() async {
    final dir = await _visitorsDir();
    final list = <Visitor>[];
    await for (final e in dir.list()) {
      if (e is File && e.path.endsWith('.json')) list.add(await _read(e));
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });

  Future<Visitor> getVisitor(String id) => _guard(() async {
    return _require(await _visitorsDir(), id);
  });

  Future<Visitor> createVisitor(Visitor visitor) => _guard(() async {
    final dir = await _visitorsDir();
    final created = Visitor.fromJson({
      ...visitor.toJson(),
      'id': await _nextId(dir),
    });
    return _write(dir, created);
  });

  Future<Visitor> updateVisitor(Visitor visitor) => _guard(() async {
    final dir = await _visitorsDir();
    final current = await _require(dir, visitor.id);
    final updated = current.copyWith(
      name: visitor.name,
      mobile: visitor.mobile,
      email: visitor.email,
      visitorType: visitor.visitorType,
      project: visitor.project,
      purpose: visitor.purpose,
    );
    return _write(dir, updated);
  });

  Future<Visitor> checkIn(String id, DateTime time) => _guard(() async {
    final dir = await _visitorsDir();
    final updated = (await _require(dir, id)).copyWith(
      status: VisitorStatus.checkedIn,
      checkInTime: DateTime.parse(DateHelper.toIsoWithOffset(time)),
    );
    return _write(dir, updated);
  });

  Future<Visitor> checkOut(String id, DateTime time) => _guard(() async {
    final dir = await _visitorsDir();
    final updated = (await _require(dir, id)).copyWith(
      status: VisitorStatus.checkedOut,
      checkOutTime: DateTime.parse(DateHelper.toIsoWithOffset(time)),
    );
    return _write(dir, updated);
  });

  Future<void> deleteVisitor(String id) => _guard(() async {
    final dir = await _visitorsDir();
    await _require(dir, id);
    await _file(dir, id).delete();
  });

  Future<String> _nextId(Directory dir) async {
    var max = 0;
    await for (final e in dir.list()) {
      final n = int.tryParse(e.uri.pathSegments.last.replaceAll('.json', ''));
      if (n != null && n > max) max = n;
    }
    return '${max + 1}';
  }

  /// Maps file and parsing errors to [ApiException].
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } on FileSystemException {
      throw const ApiException('Could not access local data.');
    } on FormatException {
      throw const ApiException('Invalid data file.');
    } on TypeError {
      throw const ApiException('Invalid data file.');
    }
  }
}
