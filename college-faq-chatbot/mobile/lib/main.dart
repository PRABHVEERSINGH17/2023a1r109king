import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/faq.dart';
import 'screens/chat_screen.dart';
import 'services/chatbot_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jsonString = await rootBundle.loadString('assets/faq_data.json');
  final college = CollegeData.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  final chatbot = ChatbotService(college);
  chatbot.initialize();

  runApp(CollegeFaqApp(college: college, chatbot: chatbot));
}

class CollegeFaqApp extends StatelessWidget {
  const CollegeFaqApp({super.key, required this.college, required this.chatbot});

  final CollegeData college;
  final ChatbotService chatbot;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College FAQ Chatbot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: ChatScreen(college: college, chatbot: chatbot),
    );
  }
}
