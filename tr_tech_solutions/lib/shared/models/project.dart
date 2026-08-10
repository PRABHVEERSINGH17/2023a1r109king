class ProjectModel {
  final String id;
  final String userId;
  final String? clientId;
  final String title;
  final String? description;
  final String status;
  final DateTime? dueDate;
  final double budget;
  final String? clientName;

  const ProjectModel({
    required this.id,
    required this.userId,
    this.clientId,
    required this.title,
    this.description,
    this.status = 'in_progress',
    this.dueDate,
    this.budget = 0,
    this.clientName,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'in_progress',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      clientName: json['clients'] != null
          ? (json['clients'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'client_id': clientId,
        'title': title,
        'description': description,
        'status': status,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'budget': budget,
      };
}
