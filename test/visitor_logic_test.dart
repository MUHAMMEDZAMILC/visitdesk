import 'package:flutter_test/flutter_test.dart';
import 'package:visitdesk/core/network/api_exception.dart';
import 'package:visitdesk/core/utils/date_helper.dart';
import 'package:visitdesk/core/utils/validators.dart';
import 'package:visitdesk/data/models/visitor.dart';
import 'package:visitdesk/data/repositories/visitor_repository.dart';
import 'package:visitdesk/providers/visitor_provider.dart';

class FakeRepo extends VisitorRepository {
  final List<Visitor> data;
  FakeRepo(this.data);

  @override
  Future<List<Visitor>> getVisitors() async => data;

  @override
  Future<Visitor> checkIn(String id, DateTime time) async => data
      .firstWhere((v) => v.id == id)
      .copyWith(status: VisitorStatus.checkedIn, checkInTime: time);

  @override
  Future<Visitor> checkOut(String id, DateTime time) async => data
      .firstWhere((v) => v.id == id)
      .copyWith(status: VisitorStatus.checkedOut, checkOutTime: time);
}

Visitor make(String id, {VisitorStatus s = VisitorStatus.registered}) => Visitor(
      id: id,
      name: 'Rahul $id',
      mobile: '98765432${id.padLeft(2, '0')}',
      visitorType: 'Customer',
      project: 'Project A',
      purpose: 'Site Visit',
      status: s,
      createdAt: DateTime.now(),
    );

void main() {
  test('mobile validator', () {
    expect(Validators.mobile(''), isNotNull);
    expect(Validators.mobile('12345'), isNotNull);
    expect(Validators.mobile('98765abcde'), isNotNull);
    expect(Validators.mobile('9876543210'), isNull);
  });

  test('optional email validator', () {
    expect(Validators.optionalEmail(''), isNull);
    expect(Validators.optionalEmail('bad'), isNotNull);
    expect(Validators.optionalEmail('a@b.com'), isNull);
  });

  test('isToday', () {
    expect(DateHelper.isToday(DateTime.now()), isTrue);
    expect(DateHelper.isToday(DateTime.now().subtract(const Duration(days: 2))),
        isFalse);
    expect(DateHelper.isToday(null), isFalse);
  });

  test('visitor json round trip keeps snake_case keys', () {
    final v = Visitor.fromJson({
      'id': 'VIS001',
      'name': 'Rahul Sharma',
      'mobile': '9876543210',
      'email': null,
      'visitor_type': 'Customer',
      'project': 'Project A',
      'purpose': 'Site Visit',
      'status': 'Checked In',
      'created_at': '2026-10-26T10:00:00+05:30',
      'check_in_time': '2026-10-26T10:30:00+05:30',
      'check_out_time': null,
    });
    expect(v.status, VisitorStatus.checkedIn);
    expect(v.canCheckOut, isTrue);
    expect(v.toJson()['visitor_type'], 'Customer');
  });

  test('workflow: no double check-in, no check-out before check-in', () async {
    final p = VisitorProvider(repository: FakeRepo([make('1')]));
    await p.fetchVisitors();

    await expectLater(p.checkOut('1'), throwsA(isA<ApiException>()));
    await p.checkIn('1');
    expect(p.checkedInNow, 1);
    await expectLater(p.checkIn('1'), throwsA(isA<ApiException>()));
    await p.checkOut('1');
    expect(p.checkedInNow, 0);
    expect(p.checkedOutToday, 1);
    await expectLater(p.checkIn('1'), throwsA(isA<ApiException>()));
  });

  test('search by name or mobile', () async {
    final p = VisitorProvider(repository: FakeRepo([make('1'), make('2')]));
    await p.fetchVisitors();
    p.setSearchQuery('rahul 2');
    expect(p.filteredVisitors.length, 1);
    p.setSearchQuery('987654320');
    expect(p.filteredVisitors.length, 2);
  });
}
