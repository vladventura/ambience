class LocationModel {
  final int id;
  final String name;
  final String? state;
  final String country;

  LocationModel(
    this.id,
    this.name,
    this.state,
    this.country,
  );

  static LocationModel fromJson(Map<String, dynamic> incoming) {
    return LocationModel(incoming['id'], incoming['name'], incoming['state'],
        incoming['country']);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "state": state, "country": country};
  }
}
