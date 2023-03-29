class WeatherModel {
  final int datetime;
  final String datetimeText;
  final num visibility;
  final num pop;

  late WeatherModelMain mainInfo;
  late List<WeatherModelInfo> weathers = [];
  late WeatherModelClouds cloudsInfo;
  late WeatherModelWind windInfo;

  WeatherModel(this.datetime, this.datetimeText, this.visibility, this.pop);

  static WeatherModel fromJson(Map<String, dynamic> incoming) {
    WeatherModel current = WeatherModel(
      incoming['dt'],
      incoming['dt_txt'],
      incoming['visibility'],
      incoming['pop'],
    );
    current._main = incoming['main'];
    current._weather = incoming['weather'];
    current._clouds = incoming['clouds'];
    current._wind = incoming['wind'];
    return current;
  }

  Map<String, dynamic> toJson() {
    return {
      "dt": datetime,
      "main": mainInfo.toJson(),
      "weather": weathers.map((WeatherModelInfo e) => e.toJson()),
      "clouds": cloudsInfo.toJson(),
      "wind": windInfo.toJson(),
      "visibility": visibility,
      "pop": pop,
      "dt_txt": datetimeText,
    };
  }

  set _main(Map<String, dynamic> incoming) =>
      mainInfo = WeatherModelMain.fromJson(incoming);

  set _weather(List<dynamic> incoming) {
    for (dynamic weatherInfo in incoming) {
      weathers
          .add(WeatherModelInfo.fromJson(weatherInfo as Map<String, dynamic>));
    }
  }

  set _clouds(Map<String, dynamic> incoming) =>
      cloudsInfo = WeatherModelClouds.fromJson(incoming);

  set _wind(Map<String, dynamic> incoming) =>
      windInfo = WeatherModelWind.fromJson(incoming);
}

class WeatherModelMain {
  final num temp;
  final num feelsLike;
  final num tempMin;
  final num tempMax;
  final num pressure;
  final num seaLevel;
  final num groundLevel;
  final num humidity;
  final num tempKf;

  WeatherModelMain(
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.seaLevel,
    this.groundLevel,
    this.humidity,
    this.tempKf,
  );

  static WeatherModelMain fromJson(Map<String, dynamic> incoming) {
    return WeatherModelMain(
      incoming['temp'],
      incoming['feels_like'],
      incoming['temp_min'],
      incoming['temp_max'],
      incoming['pressure'],
      incoming['sea_level'],
      incoming['grnd_level'],
      incoming['humidity'],
      incoming['temp_kf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "temp": temp,
      "feels_like": feelsLike,
      "temp_min": tempMin,
      "temp_max": tempMax,
      "pressure": pressure,
      "sea_level": seaLevel,
      "grnd_level": groundLevel,
      "humidity": humidity,
      "temp_kf": tempKf
    };
  }
}

class WeatherModelInfo {
  final int id;
  final String name;
  final String description;
  final String icon;

  WeatherModelInfo(this.id, this.name, this.description, this.icon);

  static WeatherModelInfo fromJson(Map<String, dynamic> incoming) {
    return WeatherModelInfo(incoming['id'], incoming['main'],
        incoming['description'], incoming['icon']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "main": name,
      "description": description,
      "icon": icon,
    };
  }
}

class WeatherModelClouds {
  final num all;

  WeatherModelClouds(this.all);

  static fromJson(Map<String, dynamic> incoming) {
    return WeatherModelClouds(incoming['all']);
  }

  Map<String, dynamic> toJson() {
    return {
      "all": all,
    };
  }
}

class WeatherModelWind {
  final num speed;
  final num deg;
  final num gust;

  WeatherModelWind(this.speed, this.deg, this.gust);

  static WeatherModelWind fromJson(Map<String, dynamic> incoming) {
    return WeatherModelWind(
        incoming['speed'], incoming['deg'], incoming['gust']);
  }

  Map<String, dynamic> toJson() {
    return {
      "speed": speed,
      "deg": deg,
      "gust": gust,
    };
  }
}
