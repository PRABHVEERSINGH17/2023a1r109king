class ClientModel {
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String? address;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const ClientModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.address,
    this.status = 'active',
    this.notes,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'address': address,
        'status': status,
        'notes': notes,
      };

  ClientModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? company,
    String? address,
    String? status,
    String? notes,
  }) {
    return ClientModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
