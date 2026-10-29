import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/utils/date_helper.dart';
import '../core/utils/local_cache.dart';
import '../data/models/visitor.dart';
import '../data/repositories/visitor_repository.dart';

enum LoadState { loading, success, empty, error }

class VisitorProvider extends ChangeNotifier {
  final VisitorRepository _repo;

  VisitorProvider({VisitorRepository? repository})
    : _repo = repository ?? VisitorRepository();

  List<Visitor> _visitors = [];
  LoadState loadState = LoadState.loading;
  String? errorMessage;
  String _searchQuery = '';
  final Set<String> _busyIds = {};
  VisitorStatus? _statusFilter;
  String? _projectFilter;

  /// True when the list on screen came from the local cache.
  bool isOffline = false;

  VisitorStatus? get statusFilter => _statusFilter;
  String? get projectFilter => _projectFilter;

  List<Visitor> get visitors => List.unmodifiable(_visitors);
  String get searchQuery => _searchQuery;

  bool isBusy(String id) => _busyIds.contains(id);

  List<Visitor> get filteredVisitors {
    final q = _searchQuery.trim().toLowerCase();
    return _visitors.where((v) {
      if (_statusFilter != null && v.status != _statusFilter) return false;
      if (_projectFilter != null && v.project != _projectFilter) return false;
      return q.isEmpty ||
          v.name.toLowerCase().contains(q) ||
          v.mobile.contains(q);
    }).toList();
  }

  int get totalToday =>
      _visitors.where((v) => DateHelper.isToday(v.createdAt)).length;

  int get checkedInNow =>
      _visitors.where((v) => v.status == VisitorStatus.checkedIn).length;

  int get checkedOutToday =>
      _visitors.where((v) => DateHelper.isToday(v.checkOutTime)).length;

  Visitor? getVisitorById(String id) {
    for (final v in _visitors) {
      if (v.id == id) return v;
    }
    return null;
  }

  void setStatusFilter(VisitorStatus? s) {
    _statusFilter = s;
    notifyListeners();
  }

  void setProjectFilter(String? p) {
    _projectFilter = p;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  /// [silent] keeps current content visible (pull-to-refresh).
  Future<void> fetchVisitors({bool silent = false}) async {
    if (!silent || _visitors.isEmpty) {
      loadState = LoadState.loading;
      notifyListeners();
    }
    try {
      final list = await _repo.getVisitors();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _visitors = list;
      errorMessage = null;
      isOffline = false;
      loadState = list.isEmpty ? LoadState.empty : LoadState.success;
      LocalCache.saveVisitors(list);
    } on ApiException catch (e) {
      errorMessage = e.message;
      // Fall back to the last cached list instead of showing a dead end.
      if (_visitors.isEmpty) _visitors = await LocalCache.loadVisitors();
      isOffline = _visitors.isNotEmpty;
      loadState = _visitors.isEmpty ? LoadState.error : LoadState.success;
      if (silent && _visitors.isNotEmpty) rethrow;
    } finally {
      notifyListeners();
    }
  }

  /// Fetches a single visitor from the API (scan lookup) and syncs it into
  /// the local list. Throws [ApiException] (404 -> isNotFound).
  Future<Visitor> lookupVisitor(String id) async {
    final visitor = await _repo.getVisitor(id);
    _upsert(visitor);
    return visitor;
  }

  Future<Visitor> createVisitor(Visitor draft) async {
    final created = await _repo.createVisitor(draft);
    _upsert(created);
    return created;
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    final updated = await _repo.updateVisitor(visitor);
    _upsert(updated);
    return updated;
  }

  Future<void> deleteVisitor(String id) async {
    await _runBusy(id, () async {
      await _repo.deleteVisitor(id);
      _visitors.removeWhere((v) => v.id == id);
      if (_visitors.isEmpty) loadState = LoadState.empty;
      LocalCache.saveVisitors(_visitors);
    });
  }

  Future<Visitor> checkIn(String id) => _transition(id, (v) {
    if (!v.canCheckIn) {
      throw const ApiException(
        'Check-in is only allowed for registered visitors.',
      );
    }
    return _repo.checkIn(id, DateTime.now());
  });

  Future<Visitor> checkOut(String id) => _transition(id, (v) {
    if (!v.canCheckOut) {
      throw const ApiException('Check-out is only allowed after check-in.');
    }
    return _repo.checkOut(id, DateTime.now());
  });

  /// Re-validates the transition against the latest state and ignores
  /// taps while a request for the same visitor is in flight.
  Future<Visitor> _transition(
    String id,
    Future<Visitor> Function(Visitor) action,
  ) async {
    final current = getVisitorById(id);
    if (current == null) throw const ApiException('Visitor not found.');
    if (isBusy(id)) throw const ApiException('Please wait…');

    late Visitor result;
    await _runBusy(id, () async {
      result = await action(current);
      _upsert(result);
    });
    return result;
  }

  Future<void> _runBusy(String id, Future<void> Function() body) async {
    _busyIds.add(id);
    notifyListeners();
    try {
      await body();
    } finally {
      _busyIds.remove(id);
      notifyListeners();
    }
  }

  void _upsert(Visitor v) {
    final i = _visitors.indexWhere((e) => e.id == v.id);
    if (i >= 0) {
      _visitors[i] = v;
    } else {
      _visitors.insert(0, v);
    }
    loadState = LoadState.success;
    LocalCache.saveVisitors(_visitors);
    notifyListeners();
  }
}
