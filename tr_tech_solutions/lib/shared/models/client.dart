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
    final company = json['company'] ?? json['contact_person'];
    final createdRaw = json['created_at'] ?? json['createdAt'];
    return ClientModel(
      id: json['id']?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      name: (json['name'] ?? json['client_name'] ?? 'Unnamed').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      company: company?.toString(),
      address: json['address']?.toString(),
      status: (json['status'] as String?) ?? 'active',
      notes: json['notes']?.toString(),
      createdAt: createdRaw != null
          ? (DateTime.tryParse(createdRaw.toString()) ?? DateTime.now())
          : DateTime.now(),
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
