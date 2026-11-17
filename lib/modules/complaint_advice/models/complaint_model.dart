class ComplaintItem {
  final int id;
  final int? userId;
  final String name;
  final String phone;
  final String? address;
  final String message;
  final String status;
  final String statusLabel;
  final String? adminNote;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ComplaintItem({
    required this.id,
    this.userId,
    required this.name,
    required this.phone,
    this.address,
    required this.message,
    required this.status,
    required this.statusLabel,
    this.adminNote,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return ComplaintItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? (json['status']?.toString().toUpperCase() ?? 'PENDING'),
      adminNote: json['admin_note']?.toString(),
      reviewedBy: json['reviewed_by'] is int ? json['reviewed_by'] : int.tryParse(json['reviewed_by']?.toString() ?? ''),
      reviewedAt: parseDate(json['reviewed_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

class ComplaintListResponse {
  final List<ComplaintItem> complaints;
  final int currentPage;
  final int lastPage;
  final int total;

  ComplaintListResponse({
    required this.complaints,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

