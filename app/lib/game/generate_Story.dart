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
        "在古老的東方王國，一場神秘的詛咒籠罩了整個城市。你是一名年輕的武士，被召喚前來解開這場詛咒的謎團。傳說中，唯有尋得神聖的水晶鑰匙才能解除詛咒。當你踏入城市，四條路徑展開在你面前：向神祕的龍族求助，探索古老的地下墓穴，尋找智慧的仙人，或者冒險闖蕩荒蕪之地。";
    List<Map<String, dynamic>> options = [
      {"idx": 1, "option": "向神祕的龍族求助"},
      {"idx": 2, "option": "探索古老的地下墓穴"},
      {"idx": 3, "option": "尋找智慧的仙人"},
      {"idx": 4, "option": "冒險闖蕩荒蕪之地"},
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

String idx2Str(int idx, String language) {
  switch (idx) {
    case 1:
      if (language == "en") {
        return "one";
      } else if (language == "zh") {
        return "一";
      } else {
        return "unknown";
      }
    case 2:
      if (language == "en") {
        return "two";
      } else if (language == "zh") {
        return "二";
      } else {
        return "unknown";
      }
    case 3:
      if (language == "en") {
        return "three";
      } else if (language == "zh") {
        return "三";
      } else {
        return "unknown";
      }
    case 4:
      if (language == "en") {
        return "four";
      } else if (language == "zh") {
        return "四";
      } else {
        return "unknown";
      }
    default:
      return "unknown";
  }
}

String voice2str(Map<String, dynamic> option, String language) {
  if (language == "en") {
    return "Your choice is : option${idx2Str(option['idx'], "en")}:${option['option']}";
  } else if (language == "zh") {
    return "你的選擇是： 選項${idx2Str(option['idx'], "zh")}：${option['option']}";
  } else {
    return "unknown";
  }
}
