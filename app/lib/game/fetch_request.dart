import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rpg_game/game/game_main/userState/actions.dart';
import 'package:rpg_game/game/game_main/userState/store.dart';

Future<Map<String, dynamic>> getHTTPResponse(
    String destination, String gameType,
    {String option = "", String start = "松菸"}) async {
  // Get the response from a certain http request
  String endpoint = "";
  if (userStateStore.state.action == "create") {
    endpoint =
        "http://10.10.2.97:8000/create_story?category=$gameType&dest=$destination&start=$start";
    print(endpoint);
    userStateStore.dispatch(SetHTTPAction("continue"));
  } else {
    endpoint = "http://10.10.2.97:8000/story_response?choice=$option";
    print(endpoint);
  }

  return {
    'story':
        "在一個遙遠的地方，有一隻小貓，牠的名字叫做米克。他是一隻非常可愛的小貓，總是在家裡的陽台上曬太陽。有一天，米克決定要去探險，於是他走出了家門，開始了他的冒險之旅。",
    'options': [
      {"idx": 1, "option": "米可貓"},
      {"idx": 2, "option": "米可貓"},
      {"idx": 3, "option": "米可狗"},
      {"idx": 4, "option": "米可誅"}
    ],
    'status': 'end'
  };

  // return {
  //   'story':
  //       "在一個遙遠的地方，有一隻小貓，牠的名字叫做米克。他是一隻非常可愛的小貓，總是在家裡的陽台上曬太陽。有一天，米克決定要去探險，於是他走出了家門，開始了他的冒險之旅。",
  //   'options': [
  //     {"idx": -1, "option": "error"}
  //   ]
  // };

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
        {"idx": -1, "option": "error"}
      ];
    }
    for (int i = 0; i < responseData["options"].length; i++) {
      options.add({"idx": i + 1, "option": responseData["options"][i]});
    }
    Map<String, dynamic> data = {
      'story': responseData["story"],
      'options': options,
      'status': responseData["status"]
    };

    return data; // Return the generated response
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from Server');
  }
}

Future<void> postHTTPResponse() async {
  // Post the response to a certain http request
  String endpoint = "http://10.10.2.97:8000/ready_battle";
  print(endpoint);

  var response = await http.post(
    Uri.parse(endpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    // If the request was successful, parse the response JSON
    print("Success");
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from Server');
  }
}

Future<String> getBattleResult() async {
  // Get the response from a certain http request
  String endpoint = "http://10.10.2.97:8000/game_is_ended";
  print(endpoint);
  var response = await http.get(
    Uri.parse(endpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    // If the request was successful, parse the response JSON
    String responseData = response.body;
    print(responseData);
    print(responseData.runtimeType);
    return responseData; // Return the generated response
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from Server');
  }
}

Future fetchAllImages() async {
  // Fetch all images from the server
  String endpoint = "http://10.10.2.97:8000/get_all_pics";
  print(endpoint);
  var response = await http.get(
    Uri.parse(endpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    // If the request was successful, parse the response JSON
    String responseData = response.body;
    return responseData.split("\n");
    // "filename 1\nfilename 2\nfilename 3"
  } else {
    // If the request failed, return an error message
    throw Exception('Failed to get response from Server');
  }
}

Future fetchMemoirs() async {
  // Fetch all images from the server
  // String endpoint = "http://
  return [
    {
      "image": "assets/images/taipei-101.png",
      "title": "Taipei",
      "date": "2024-04-25",
      "destination": "Taipei 101"
    },
    {
      "image": "assets/images/river.png",
      "title": "Kaohsiung",
      "date": "2024-05-02",
      "destination": "Kaohsiung Love River"
    },
  ];
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
