class GeminiResponse {
  final String text;
  final Map<String, dynamic>? metadata;

  GeminiResponse({required this.text, this.metadata});
}

class GeminiService {
  Future<GeminiResponse> analyzeData(
      {required String prompt, required String data}) async {
    // TODO: Implement actual Gemini API integration
    return GeminiResponse(
      text: "Sample analysis of the data: $data\nPrompt used: $prompt",
      metadata: {},
    );
  }
} 