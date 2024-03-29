import 'package:ambience/weatherEntry/weather_entry.dart';

const fakeGeo = [
  {
    'lat': 0.011,
    'lon': 1.11,
  }
];

const Map<String, dynamic> fakeCityInfo = {
  "cityName": "Incheon",
  "countryCode": 207,
  'lat': 0.011,
  'lon': 1.11,
  'id': 1843561,
};

const Map<String, dynamic> fakeGeoSingleComplete = {
  "cityName": "Incheon",
  "countryCode": 207,
  'lat': 0.011,
  'lon': 1.11,
};

Map<String, dynamic> fakeWeatherEntry = {
  "startTimeHour": 8,
  "startTimeMinute": 10,
  "endTimeHour": 9,
  "endTimeMinute": 10,
  "dayOfWeek": DayOfWeek.friday.index,
  "wallpaperFilepath": "fake/path",
  "weatherCondition": WeatherCondition.Rain.index,
  "idSchema": "ambience_daemon_fakentry",
  "city": "Incheon",
  "cityId": 1843561
};

const String mockKey = "fakepi-key";

const fakeWeatherResponse = {
  "body": {
    "cod": "200",
    "message": 0,
    "cnt": 40,
    "list": [
      {
        "dt": 1679238000,
        "main": {
          "temp": 273.78,
          "feels_like": 267.64,
          "temp_min": 273.78,
          "temp_max": 273.78,
          "pressure": 1015,
          "sea_level": 1015,
          "grnd_level": 1014,
          "humidity": 37,
          "temp_kf": 0
        },
        "weather": [
          {
            "id": 802,
            "main": "Clouds",
            "description": "scattered clouds",
            "icon": "03d"
          }
        ],
        "clouds": {"all": 32},
        "wind": {"speed": 8.02, "deg": 275, "gust": 13.76},
        "visibility": 10000,
        "pop": 0,
        "dt_txt": "2023-03-19 15:00:00"
      }
    ],
    "city": {
      "id": 4930956,
      "name": "Boston",
      "coord": {"lat": 42.3581, "lon": -71.0636},
      "country": "US",
      "population": 617594,
      "timezone": -14400,
      "sunrise": 1678791509,
      "sunset": 1678834121
    }
  }
};
