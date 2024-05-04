import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getHTTPResponse(
    String destination, String gameType,
    {String option = ""}) async {
  // Get the response from a certain http request
  String endpoint = "";
  if (option == "") {
    endpoint =
        "http://10.10.2.97:8000/create_story??category=$gameType&dest=$destination";
    print(endpoint);
  } else {
    endpoint = "http://10.10.2.97:8000/story_response?choice=$option";
    print(endpoint);
  }
  // temp result
  // TODO: Remove this line
  bool test = false;
  if (test) {
    print(option);
    if (option == "") {
      String story =
          "在古老的東方王國，一場神秘的詛咒籠罩了整個城市。你是一名年輕的武士，被召喚前來解開這場詛咒的謎團。傳說中，唯有尋得神聖的水晶鑰匙才能解除詛咒。當你踏入城市，四條路徑展開在你面前：向神祕的龍族求助，探索古老的地下墓穴，尋找智慧的仙人，或者冒險闖蕩荒蕪之地。";
      List<Map<String, dynamic>> options = [
        {"idx": 1, "option": "向神祕的龍族求助"},
        {"idx": 2, "option": "探索古老的地下墓穴"},
        {"idx": 3, "option": "尋找智慧的仙人"},
        {"idx": 4, "option": "冒險闖蕩荒蕪之地"},
      ];
      Map<String, dynamic> data = {'story': story, 'options': options};
      return data; // Return the generated response}
    } else {
      String story =
          "年輕武士踏入城市，選擇尋求龍族的幫助。在龍族的寶藏中，他發現了水晶鑰匙，但龍族卻要求他為此付出代價。武士決定勇敢地面對，最終通過考驗，得到了鑰匙。解除詛咒後，城市重獲生機。武士成為英雄，與龍族結下永久的友誼，共同守護著古老的東方王國。";
      List<Map<String, dynamic>> options = [
        {"": ""}
      ];
      Map<String, dynamic> data = {'story': story, 'options': options};
      return data; // Return the generated response
    }
  }
  // Send POST request to OpenAI API
  var response = await http.get(
    Uri.parse(endpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  // // Parse the response
  if (response.statusCode == 200) {
    // If the request was successful, parse the response JSON
    Map<String, dynamic> responseData = json.decode(response.body);
    List<Map<String, dynamic>> options = [];
    print(responseData);
    print(responseData["story"]);
    print(responseData["options"]);
    if ((responseData["options"] as List).isEmpty) {
      print("empty");
      options = [
        {"": ""}
      ];
    }
    for (int i = 0; i < responseData["options"].length; i++) {
      options.add({"idx": i + 1, "option": responseData["options"][i]});
    }
    Map<String, dynamic> data = {
      'story': responseData["story"],
      'options': options
    };
    return data; // Return the generated response
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from Server');
  }
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
