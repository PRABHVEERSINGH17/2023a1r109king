class LeadModel {
  final String id;
  final String userId;
  final String? clientId;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String stage;
  final double value;
  final String? source;
  final String? notes;
  final DateTime createdAt;

  const LeadModel({
    required this.id,
    required this.userId,
    this.clientId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.stage = 'new',
    this.value = 0,
    this.source,
    this.notes,
    required this.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      stage: json['stage'] as String? ?? 'new',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_id': clientId,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'stage': stage,
        'value': value,
        'source': source,
        'notes': notes,
      };
}
