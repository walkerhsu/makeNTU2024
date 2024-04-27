import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> getGPTResponse(String destination, String gameType) async {
  // Your OpenAI API key
  String? apiKey = dotenv.env['OPEN_AI_API_KEY'];
  
  // The endpoint for the OpenAI API
  String endpoint = 'https://api.openai.com/v1/completions';

  String userQuery = generatePrompt(destination, gameType);

  // The data to be sent in the request
  Map<String, dynamic> requestData = {
    "model": "text-davinci-002", // The model you want to use
    "prompt": userQuery, // User's input
    "max_tokens": 150, // Maximum number of tokens for the response
    "temperature": 0.7, // Control randomness of the response
    "api_key": apiKey // Your OpenAI API key
  };

  // Encode the data to JSON
  String requestBody = json.encode(requestData);

  // Send POST request to OpenAI API
  var response = await http.post(
    Uri.parse(endpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: requestBody,
  );

  // Parse the response
  if (response.statusCode == 200) {
    // If the request was successful, parse the response JSON
    Map<String, dynamic> responseData = json.decode(response.body);
    return responseData['choices'][0]['text']; // Return the generated response
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from OpenAI API');
  }
}

String generatePrompt(String destination, String gameType) {
  // Generate a prompt based on the user's input
  // TODO: DESIGN YOUR OWN PROMPT BASED ON THE GAME TYPE AND DESTINATION
  String prompt = "You are a RPG story designer. You have to design a story that begins at ,  and ends at $destination. The game mode is $gameType, so you should generate a story that is $gameType. At last, you have to give 4 choices to let the user choose. ";

  return prompt;
}