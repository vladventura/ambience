import "dart:convert";
import "dart:io" show File;
import "package:ambience/api/geolocate_api.dart";
import "package:ambience/api/weather_api.dart";
import "package:ambience/handlers/request_handler.dart";
import "package:flutter/foundation.dart";
import 'package:path/path.dart' as path;
import "package:flutter_test/flutter_test.dart";
import "package:ambience/handlers/wallpaper_handler.dart";
import 'package:http/http.dart' as http;
import "package:flutter_dotenv/flutter_dotenv.dart";

import "mock/mock_data.dart";

class MockRequestHandler extends Handler {
  @override
  Future<dynamic> requestGeolocationData(String? cityName) async {
    return fakeGeo;
  }

  @override
  Future<dynamic> requestWeatherData(String? input, List<dynamic> cords) async {
    return http.Response(json.encode(fakeWeatherResponse['body']), 200);
  }
}

void main() {
  group('Wallpaper Handler', () {
    test('Should find shared library', () {
      String pathToSO = path.normalize(WallpaperHandler.dyLibPath);
      File soFile = File(pathToSO);
      expect(soFile.existsSync(), true);
    });
    test('Should throw exception for any Apple OS', () {
      TargetPlatform targetPlatform = TargetPlatform.macOS;
      expect(
          () => WallpaperHandler.setWallpaper("Mock Path",
              platform: targetPlatform),
          throwsA(isA<InvalidPlatformException>()));
    });
  });
  group('Request Handler', () {
    test('Should load API Key properly', () {
      dotenv.testLoad(fileInput: "APIKEY=$mockKey");
      RequestHandler handler = const RequestHandler();
      expect(handler.apiKey, mockKey);
    });
  });
  group('Geolocate API', () {
    test('Should return mock geolocation', () async {
      Handler mockHandler = MockRequestHandler();
      dynamic geo = await geolocate("Mock City", handler: mockHandler);
      expect(geo, [fakeGeo[0]['lat'], fakeGeo[0]['lon']]);
    });
  });
  group('Weather API', () {
    test('Should return mock weather', () async {
      Handler mockHandler = MockRequestHandler();
      List<dynamic> geo = await geolocate("Mock City", handler: mockHandler);
      http.Response response =
          await getWeather("Mock City", latlon: geo, handler: mockHandler);
      Map<String, dynamic> result = json.decode(response.body);
      expect(result, fakeWeatherResponse['body']);
    });
  });
}
