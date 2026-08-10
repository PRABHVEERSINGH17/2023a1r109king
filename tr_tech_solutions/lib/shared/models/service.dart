class ServiceModel {
  final String id;
  final String userId;
  final String? clientId;
  final String name;
  final String type;
  final String? provider;
  final DateTime? expiryDate;
  final double renewalCost;
  final String status;
  final String? notes;
  final String? clientName;

  const ServiceModel({
    required this.id,
    required this.userId,
    this.clientId,
    required this.name,
    this.type = 'domain',
    this.provider,
    this.expiryDate,
    this.renewalCost = 0,
    this.status = 'active',
    this.notes,
    this.clientName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'domain',
      provider: json['provider'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      renewalCost: (json['renewal_cost'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      clientName: json['clients'] != null
          ? (json['clients'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_id': clientId,
        'name': name,
        'type': type,
        'provider': provider,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'renewal_cost': renewalCost,
        'status': status,
        'notes': notes,
      };
}
