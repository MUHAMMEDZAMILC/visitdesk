import '../../core/utils/date_helper.dart';

enum VisitorStatus {
  registered('Registered'),
  checkedIn('Checked In'),
  checkedOut('Checked Out');

  final String label;
  const VisitorStatus(this.label);

  static VisitorStatus fromLabel(String? v) => VisitorStatus.values.firstWhere(
    (s) => s.label == v,
    orElse: () => VisitorStatus.registered,
  );
}

class Visitor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final VisitorStatus status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  bool get canCheckIn => status == VisitorStatus.registered;
  bool get canCheckOut => status == VisitorStatus.checkedIn;

  factory Visitor.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toLocal() : null;
    final email = json['email'] as String?;

    return Visitor(
      id: json['id'].toString(),
      name: json['name'] as String,
      mobile: json['mobile'].toString(),
      email: (email == null || email.isEmpty) ? null : email,
      visitorType: json['visitor_type'] as String,
      project: json['project'] as String,
      purpose: json['purpose'] as String,
      status: VisitorStatus.fromLabel(json['status'] as String?),
      createdAt: parse(json['created_at']) ?? DateTime.now(),
      checkInTime: parse(json['check_in_time']),
      checkOutTime: parse(json['check_out_time']),
    );
  }

  /// Full body, used for POST.
  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'email': email,
    'visitor_type': visitorType,
    'project': project,
    'purpose': purpose,
    'status': status.label,
    'created_at': DateHelper.toIsoWithOffset(createdAt),
    'check_in_time': checkInTime == null
        ? null
        : DateHelper.toIsoWithOffset(checkInTime!),
    'check_out_time': checkOutTime == null
        ? null
        : DateHelper.toIsoWithOffset(checkOutTime!),
  };

  /// Full body including id, used for the local cache.
  Map<String, dynamic> toCacheJson() => {'id': id, ...toJson()};

  /// Only the editable fields, used for PUT on edit (status and
  /// timestamps are preserved server-side).
  Map<String, dynamic> toEditJson() => {
    'name': name,
    'mobile': mobile,
    'email': email,
    'visitor_type': visitorType,
    'project': project,
    'purpose': purpose,
  };

  Visitor copyWith({
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    VisitorStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) => Visitor(
    id: id,
    name: name ?? this.name,
    mobile: mobile ?? this.mobile,
    email: email ?? this.email,
    visitorType: visitorType ?? this.visitorType,
    project: project ?? this.project,
    purpose: purpose ?? this.purpose,
    status: status ?? this.status,
    createdAt: createdAt,
    checkInTime: checkInTime ?? this.checkInTime,
    checkOutTime: checkOutTime ?? this.checkOutTime,
  );
}
