import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel model;

  GeminiService(String apiKey) : model = GenerativeModel(model: 'gemini-2.0-flash-exp', apiKey: apiKey);

  Future<String> generateSummary(String text, String detailLevel, {String? language}) async {
    String prompt = 'Create a $detailLevel summary of the following text. Focus on the main ideas, key points, and essential details. Make it concise, clear, and objective. Use bullet points for better readability and structure.';
    if (language != null && language != 'English') {
      prompt += ' Translate the summary to $language.';
    }
    prompt += ' Return only the summary text, without any introductory phrases, explanations, or additional comments:\n\n$text';

    int retryCount = 0;
    while (true) {
      try {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Unable to generate summary.';
      } catch (e) {
        if (e.toString().contains('the model is overloaded') && retryCount < 3) {
          retryCount++;
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        throw Exception('Error generating summary: $e');
      }
    }
  }

  Future<String> improveWriting(String text, String tone, {int alternatives = 1}) async {
    String prompt = 'Based on the following description or draft, write a complete and well-structured $tone email or text. Expand on the ideas provided to create a full, professional, clear, and engaging piece. Make it natural, flowing, and appropriate for the context.';
    if (alternatives > 1) {
      prompt += ' Provide $alternatives alternative versions, clearly numbered as Version 1, Version 2, etc.';
    }
    prompt += ' Return only the written text(s) without any introductory phrases, explanations, or additional comments:\n\n$text';

    int retryCount = 0;
    while (true) {
      try {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? 'Unable to improve writing.';
      } catch (e) {
        if (e.toString().contains('the model is overloaded') && retryCount < 3) {
          retryCount++;
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        throw Exception('Error improving writing: $e');
      }
    }
  }
}
