class LocationResponse{
  final String address;
  final String locality;
  final String city;
  final String latitude;
  final String longitude;
  final String zipcode;

  LocationResponse.fromJson(json)
    : address = json['address'],
        locality = json['locality'],
        city = json['city'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        zipcode = json['zipcode'];


}