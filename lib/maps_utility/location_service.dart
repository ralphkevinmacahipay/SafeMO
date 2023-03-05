import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:developer' as devtool show log;

const String googleAPI = "AIzaSyABH--keESh9Hwo_HsO8QPQKc0V-KJfiKc";

class LocationService {
  final String key = 'AIzaSyABH--keESh9Hwo_HsO8QPQKc0V-KJfiKc';

  Future<String> getPlaceId(String input) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;
    devtool.log(placeId);

    return placeId;
  }

  //  Future<Map<String, dynamic>>getPlace(String input) async{}
}
