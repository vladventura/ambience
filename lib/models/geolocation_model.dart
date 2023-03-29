class GeolocationModel {
  final double lat;
  final double lon;

  GeolocationModel(this.lat, this.lon);

  late String cityName = "";
  late num countryCode = 0; 

  static GeolocationModel fromJson(Map<String, dynamic> incoming) {
    return GeolocationModel(incoming['lat'], incoming['lon']);
  }

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lon": lon,
      "cityName": cityName,
      "countryCode": countryCode,
    };
  }
}
