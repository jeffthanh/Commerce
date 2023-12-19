import 'dart:convert';

import 'package:client/models/slider_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SliderProvider extends ChangeNotifier {
  Future<List<Sli>> getSlider() async {
    const url = 'http://192.168.1.31:5000/slider';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);
      List<Sli> data = List<Sli>.from(
          jsonData.map((slider) => Sli.fromJson(jsonEncode(slider)))).toList();
      return data;
    } catch (e) {
      return Future.error(e);
    }
  }
}
