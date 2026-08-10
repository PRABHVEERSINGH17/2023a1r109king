class FaqItem {
  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.keywords = const [],
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  final String id;
  final String question;
  final String answer;
  final List<String> keywords;
}

class FaqCategory {
  FaqCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.faqs,
  });

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      faqs: (json['faqs'] as List<dynamic>)
          .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String name;
  final String icon;
  final List<FaqItem> faqs;
}

class CollegeData {
  CollegeData({required this.collegeName, required this.categories});

  factory CollegeData.fromJson(Map<String, dynamic> json) {
    return CollegeData(
      collegeName: json['college_name'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => FaqCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String collegeName;
  final List<FaqCategory> categories;
}

class ChatResult {
  ChatResult({
    required this.answer,
    this.matchedQuestion,
    this.category,
    required this.confidence,
    this.suggestions = const [],
  });

  final String answer;
  final String? matchedQuestion;
  final String? category;
  final double confidence;
  final List<String> suggestions;
}
