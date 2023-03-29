import "dart:convert";
import "dart:io" show File, Directory, FileSystemEntity;
import "package:ambience/constants.dart";
import "package:ambience/storage/storage.dart";
import "package:flutter/foundation.dart";
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_test/flutter_test.dart";
import "package:ambience/api/geolocate_api.dart";
import "package:ambience/api/weather_api.dart";
import "package:ambience/handlers/file_handler.dart" as FileHandler;
import "package:ambience/handlers/request_handler.dart";
import "package:ambience/handlers/wallpaper_handler.dart";
import "package:ambience/models/geolocation_model.dart";
import "package:ambience/models/weather_model.dart";

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
  group('Weather Model', () {
    test("Should parse data properly", () {
      Map<String, dynamic> weatherDataListItem =
          (fakeWeatherResponse['body']?['list'] as List)[0];
      WeatherModel modelFromJson = WeatherModel.fromJson(weatherDataListItem);
      expect(modelFromJson.visibility, weatherDataListItem['visibility']);
    });
  });

  group('Geolocation Model', () {
    Map<String, dynamic> geolocationDataListItem = fakeGeo[0];
    GeolocationModel modelFromJson;
    test("Should parse geolocation data properly", () {
      modelFromJson = GeolocationModel.fromJson(geolocationDataListItem);
      expect(modelFromJson.lat, geolocationDataListItem['lat']);
    });
    test("Should allow to late initialize city name", () {
      modelFromJson = GeolocationModel.fromJson(geolocationDataListItem);
      modelFromJson.cityName = fakeCityInfo['cityName'];
      expect(modelFromJson.cityName, fakeCityInfo['cityName']);
    });
    test("Should allow to late initialize country code", () {
      modelFromJson = GeolocationModel.fromJson(geolocationDataListItem);
      modelFromJson.countryCode = fakeCityInfo['countryCode'];
      expect(modelFromJson.countryCode, fakeCityInfo['countryCode']);
    });
  });
  group('Storage', () {
    test('Should take weather data path from constants file', () {
      Storage storage = Storage();
      expect(storage.weatherDataPath, weatherDataPath);
    });
    test('Should take log file path from constants file', () {
      Storage storage = Storage();
      expect(storage.logFilePath, logFilePath);
    });
    test('Should take config file path from constants file', () {
      Storage storage = Storage();
      expect(storage.configPath, configPath);
    });
    test('Should take app\'s data directory name from constants file', () {
      Storage storage = Storage();
      expect(storage.appDataDirName, appDataDirName);
    });
  });
  group('Scripts', () {
    Directory scriptsDir;
    late List<FileSystemEntity> allFiles;
    setUp(() async {
      scriptsDir = Directory(
          path.normalize(path.join(Directory.current.path, 'scripts')));
      allFiles = await scriptsDir.list().toList();
    });
    test('Should find Windows scripts', () async {
      bool found = false;
      for (FileSystemEntity fse in allFiles) {
        if (fse.path.contains('win')) {
          found = true;
          break;
        }
      }
      expect(found, true);
    });
    test('Should find Ubuntu scripts', () async {
      bool found = false;
      for (FileSystemEntity fse in allFiles) {
        if (fse.path.contains('Ubuntu')) {
          found = true;
          break;
        }
      }
      expect(found, true);
    });
  });
}
