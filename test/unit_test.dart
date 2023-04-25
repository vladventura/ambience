import "dart:convert";
import "dart:io" show File, Directory, FileSystemEntity;
import "package:ambience/constants.dart";
import "package:ambience/storage/storage.dart";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/foundation.dart";
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_test/flutter_test.dart";
import "package:ambience/api/geolocate_api.dart";
import "package:ambience/api/weather_api.dart";
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
  Future<dynamic> requestWeatherDataForecast(
      int? locationId) async {
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
      dotenv.testLoad(fileInput: "OpenweatherAPI=$mockKey");
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
      http.Response response = await getWeatherForecast(fakeCityInfo['cityId'], handler: mockHandler);
      Map<String, dynamic> result = json.decode(response.body);
      expect(result, fakeWeatherResponse['body']);
    });
  });
  group('Weather Model', () {
    Map<String, dynamic> weatherDataListItem =
        (fakeWeatherResponse['body']?['list'] as List)[0];
    late WeatherModel modelFromJson;
    setUp(() {
      modelFromJson = WeatherModel.fromJson(weatherDataListItem);
    });
    test("Should parse from Json properly", () {
      expect(modelFromJson.visibility, weatherDataListItem['visibility']);
    });
    test("Should parse to Json properly", () {
      expect(modelFromJson.toJson(), weatherDataListItem);
    });
  });

  group('Geolocation Model', () {
    Map<String, dynamic> geolocationDataListItem = fakeGeo[0];
    late GeolocationModel modelFromJson;

    setUp(() {
      modelFromJson = GeolocationModel.fromJson(geolocationDataListItem);
      modelFromJson.cityName = fakeCityInfo['cityName'];
      modelFromJson.countryCode = fakeCityInfo['countryCode'];
    });
    test("Should parse from Json properly", () {
      expect(modelFromJson.lat, geolocationDataListItem['lat']);
    });
    test("Should allow to late initialize city name", () {
      expect(modelFromJson.cityName, fakeCityInfo['cityName']);
    });
    test("Should allow to late initialize country code", () {
      expect(modelFromJson.countryCode, fakeCityInfo['countryCode']);
    });
    test('Should parse to Json properly', () {
      expect(modelFromJson.toJson(), fakeGeoSingleComplete);
    });
  });
  group('Weather Entry Model', () {
    test('Should parse from Json properly', () {
      WeatherEntry weatherEntry = WeatherEntry.fromJson(fakeWeatherEntry);
      expect(weatherEntry.city, fakeWeatherEntry['city']);
    });
    test('Should parse to Json properly', () {
      WeatherEntry weatherEntry = WeatherEntry.fromJson(fakeWeatherEntry);
      Map<String, dynamic> asJson = weatherEntry.toJson();
      expect(asJson['city'], fakeWeatherEntry['city']);
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
  group('Native bindings', () {
    test("Should find generated_bindings.dart file", () async {
      bool found = false;
      Directory nativeDir = Directory(
          path.normalize(path.join(Directory.current.path, 'lib', 'native')));
      List<FileSystemEntity> allFiles = await nativeDir.list().toList();
      for (FileSystemEntity fse in allFiles) {
        if (fse.path.contains('generated_bindings.dart')) {
          found = true;
          break;
        }
      }
      expect(found, true);
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
