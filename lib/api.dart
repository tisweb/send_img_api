import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

Map<String, String> headers = {
  'Content-Type': 'application/json;charset=UTF-8',
  'Charset': 'utf-8'
};

Future getData(Uri url) {
  Future<http.Response> response = http.get(url, headers: headers);
  return response.then((value) => value.body);
}
