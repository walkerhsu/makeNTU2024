import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getGPTResponse(
    String destination, String gameType) async {
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
  // temp result
  // TODO: Remove this line
  bool test = true;
  if (test) {
    String story =
        "In the realm of Etheria, a land teeming with magic and mystery, a group of unlikely heroes embarks on an epic quest. Bound by fate, they seek the legendary Crystal of Eternity, said to hold the power to reshape reality itself. Along their journey, they face treacherous dungeons, cunning foes, and moral dilemmas that test their resolve. Each member of the party brings unique skills and backgrounds, from the stoic warrior wielding a mighty blade to the enigmatic sorcerer harnessing arcane forces. As they venture forth, they uncover dark secrets that threaten to unravel the very fabric of existence.";
    List<Map<String, dynamic>> options = [
      {"idx": 1, "option": "The Mysterious Cave"},
      {"idx": 2, "option": "The Forbidden Temple"},
      {"idx": 3, "option": "The Enchanted Forest"},
      {"idx": 4, "option": "The Haunted Ruins"},
    ];
    Map<String, dynamic> data = {'story': story, 'options': options};
    return data; // Return the generated response
  }
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
    Map<String, dynamic> data = {
      'story': responseData['choices'][0]['text']["story"],
      'options': responseData['choices'][0]['text']["options"]
    };
    return data; // Return the generated response
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from OpenAI API');
  }
}

String generatePrompt(String destination, String gameType) {
  // Generate a prompt based on the user's input
  // TODO: DESIGN YOUR OWN PROMPT BASED ON THE GAME TYPE AND DESTINATION
  // TODO: SHOULD ASK THE MODEL TO RETURN WITH THE FOLLOWING STRUCTURE
  // {
  //    "story": ".....",
  //    "options" : [
  //       {"idx": 1, "option": "..."},
  //       {"idx": 2, "option": "..."},
  //       {"idx": 3, "option": "..."},
  //       {"idx": 4, "option": "..."},
  //    ]
  // }
  String prompt =
      "You are a RPG story designer. You have to design a story that begins at ,  and ends at $destination. The game mode is $gameType, so you should generate a story that is $gameType. At last, you have to give 4 choices to let the user choose. ";

  return prompt;
}

String idx2Str(int idx) {
  switch (idx) {
    case 1:
      return "one";
    case 2:
      return "two";
    case 3:
      return "three";
    case 4:
      return "four";
    default:
      return "unknown";
  }
}