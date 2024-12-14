import 'dart:convert';
import 'package:dental_app/api_keys.dart';
import 'package:http/http.dart' as http;

Future<String> sendMessageAndGetResponse(
    String message, List<Map<String, String>> previousMessages) async {
  const String apiKey = ChatGPT_API_KEY;
  final apiUrl = 'https://api.openai.com/v1/chat/completions';
  var messages = [
    {
      "role": "system",
      "content":
          "You are a dentist and can only respond to questions about dental health, treatments, and oral care."
    },
    ...previousMessages
        .map((message) =>
            {"role": message["role"], "content": message["content"]})
        .toList(),
    {"role": "user", "content": message}
  ];

  var requestBody = jsonEncode({
    "model": "gpt-4",
    "messages": messages,
    "temperature": 0.5,
  });

  var response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: requestBody,
  );

  if (response.statusCode == 200) {
    var utf8Response = utf8.decode(response.bodyBytes);
    var data = jsonDecode(utf8Response);
    var content = data['choices'][0]['message']['content'].toString();
    return content;
  } else {
    throw Exception('Failed to get response from OpenAI');
  }
}
