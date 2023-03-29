class GeolocationModel {
  final double lat;
  final double lon;

  GeolocationModel(this.lat, this.lon);

  static GeolocationModel fromJson(Map<String, dynamic> incoming) {
    return GeolocationModel(incoming['lat'], incoming['lon']);
  }

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lon": lon,
    };
  }
}
