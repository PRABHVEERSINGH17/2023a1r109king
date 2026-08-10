class TicketModel {
  final String id;
  final String userId;
  final String? clientId;
  final String ticketNumber;
  final String subject;
  final String? description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final String? clientName;

  const TicketModel({
    required this.id,
    required this.userId,
    this.clientId,
    required this.ticketNumber,
    required this.subject,
    this.description,
    this.status = 'open',
    this.priority = 'medium',
    required this.createdAt,
    this.clientName,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      ticketNumber: json['ticket_number'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['created_at'] as String),
      clientName: json['clients'] != null
          ? (json['clients'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_id': clientId,
        'ticket_number': ticketNumber,
        'subject': subject,
        'description': description,
        'status': status,
        'priority': priority,
      };
}
