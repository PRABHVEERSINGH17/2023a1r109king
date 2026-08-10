import 'dart:math';

import '../models/faq.dart';

class _FaqEntry {
  _FaqEntry({
    required this.question,
    required this.answer,
    required this.categoryName,
    required this.corpusText,
  });

  final String question;
  final String answer;
  final String categoryName;
  final String corpusText;
}

class ChatbotService {
  ChatbotService(this._college);

  static const double confidenceThreshold = 0.25;
  static const Set<String> stopWords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'must', 'shall', 'can', 'need', 'to', 'of',
    'in', 'for', 'on', 'with', 'at', 'by', 'from', 'as', 'into', 'through',
    'during', 'before', 'after', 'above', 'below', 'between', 'under',
    'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where',
    'why', 'how', 'all', 'each', 'few', 'more', 'most', 'other', 'some',
    'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too',
    'very', 'just', 'and', 'but', 'if', 'or', 'because', 'until', 'while',
    'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'i',
    'me', 'my', 'we', 'our', 'you', 'your', 'he', 'she', 'it', 'they', 'them',
  };

  final CollegeData _college;
  late final List<_FaqEntry> _entries;
  late final List<String> _vocabulary;
  late final List<Map<String, double>> _idf;
  late final List<Map<String, double>> _tfidfVectors;

  void initialize() {
    _entries = [];
    for (final category in _college.categories) {
      for (final faq in category.faqs) {
        final keywords = faq.keywords.join(' ');
        final corpus = _normalize('${faq.question} $keywords');
        _entries.add(
          _FaqEntry(
            question: faq.question,
            answer: faq.answer,
            categoryName: category.name,
            corpusText: corpus,
          ),
        );
      }
    }

    final tokenizedDocs = _entries.map((e) => _tokenize(e.corpusText)).toList();
    final vocabSet = <String>{};
    for (final doc in tokenizedDocs) {
      vocabSet.addAll(doc);
    }
    _vocabulary = vocabSet.toList()..sort();

    final docCount = tokenizedDocs.length;
    _idf = List.generate(docCount, (_) => {});

    for (final term in _vocabulary) {
      var docsWithTerm = 0;
      for (final doc in tokenizedDocs) {
        if (doc.contains(term)) docsWithTerm++;
      }
      final idfValue = log((docCount + 1) / (docsWithTerm + 1)) + 1;
      for (var i = 0; i < docCount; i++) {
        if (tokenizedDocs[i].contains(term)) {
          _idf[i][term] = idfValue;
        }
      }
    }

    _tfidfVectors = [];
    for (var i = 0; i < docCount; i++) {
      _tfidfVectors.add(_computeTfidf(tokenizedDocs[i], _idf[i]));
    }
  }

  List<String> getSuggestedQuestions({int limit = 8}) {
    return _entries.take(limit).map((e) => e.question).toList();
  }

  ChatResult chat(String userMessage) {
    final normalized = _normalize(userMessage);
    if (normalized.isEmpty) return _fallback();

    const greetings = {'hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening', 'namaste'};
    if (greetings.contains(normalized) ||
        normalized.startsWith('hi ') ||
        normalized.startsWith('hello ') ||
        normalized.startsWith('hey ')) {
      return ChatResult(
        answer:
            "Hello! Welcome to ${_college.collegeName} FAQ Assistant. "
            "I can help you with admissions, fees, exams, hostel, placements, and more. "
            "What would you like to know?",
        confidence: 1.0,
        suggestions: getSuggestedQuestions(limit: 5),
      );
    }

    final queryTokens = _tokenize(normalized);
    final queryVector = _computeTfidf(queryTokens, {});

    var bestIdx = 0;
    var bestScore = 0.0;
    final scores = <double>[];

    for (var i = 0; i < _tfidfVectors.length; i++) {
      final score = _cosineSimilarity(queryVector, _tfidfVectors[i]);
      scores.add(score);
      if (score > bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }

    if (bestScore < confidenceThreshold) return _fallback();

    final match = _entries[bestIdx];
    final indexedScores = List.generate(scores.length, (i) => MapEntry(i, scores[i]));
    indexedScores.sort((a, b) => b.value.compareTo(a.value));

    final suggestions = <String>[];
    for (final entry in indexedScores.take(4)) {
      if (entry.key != bestIdx && entry.value >= confidenceThreshold * 0.5) {
        suggestions.add(_entries[entry.key].question);
      }
    }

    return ChatResult(
      answer: match.answer,
      matchedQuestion: match.question,
      category: match.categoryName,
      confidence: double.parse(bestScore.toStringAsFixed(3)),
      suggestions: suggestions.take(3).toList(),
    );
  }

  ChatResult _fallback() {
    return ChatResult(
      answer:
          "I'm sorry, I couldn't find a specific answer to that question. "
          "Please try rephrasing, pick a suggested question, or contact "
          "the college office at info@abcit.edu.in or call +91-20-12345678.",
      confidence: 0,
      suggestions: getSuggestedQuestions(limit: 5),
    );
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _tokenize(String text) {
    return text
        .split(' ')
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  Map<String, double> _computeTfidf(List<String> tokens, Map<String, double> idfMap) {
    if (tokens.isEmpty) return {};

    final tf = <String, int>{};
    for (final token in tokens) {
      tf[token] = (tf[token] ?? 0) + 1;
    }

    final total = tokens.length.toDouble();
    final vector = <String, double>{};

  for (final entry in tf.entries) {
      final term = entry.key;
      final tfValue = entry.value / total;
      final idfValue = idfMap[term] ?? 1.0;
      vector[term] = tfValue * idfValue;
    }

    return vector;
  }

  double _cosineSimilarity(Map<String, double> a, Map<String, double> b) {
    if (a.isEmpty || b.isEmpty) return 0;

    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;

    final keys = {...a.keys, ...b.keys};
    for (final key in keys) {
      final av = a[key] ?? 0;
      final bv = b[key] ?? 0;
      dot += av * bv;
      normA += av * av;
      normB += bv * bv;
    }

    if (normA == 0 || normB == 0) return 0;
    return dot / (sqrt(normA) * sqrt(normB));
  }
}
