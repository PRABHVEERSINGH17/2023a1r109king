class InvoiceModel {
  final String id;
  final String userId;
  final String? clientId;
  final String invoiceNumber;
  final double amount;
  final double tax;
  final double total;
  final String status;
  final DateTime? dueDate;
  final DateTime? issuedDate;
  final String? notes;
  final String? clientName;

  const InvoiceModel({
    required this.id,
    required this.userId,
    this.clientId,
    required this.invoiceNumber,
    required this.amount,
    this.tax = 0,
    required this.total,
    this.status = 'pending',
    this.dueDate,
    this.issuedDate,
    this.notes,
    this.clientName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      amount: (json['amount'] as num).toDouble(),
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      issuedDate: json['issued_date'] != null
          ? DateTime.parse(json['issued_date'] as String)
          : null,
      notes: json['notes'] as String?,
      clientName: json['clients'] != null
          ? (json['clients'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_id': clientId,
        'invoice_number': invoiceNumber,
        'amount': amount,
        'tax': tax,
        'status': status,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'issued_date': issuedDate?.toIso8601String().split('T').first,
        'notes': notes,
      };
}
