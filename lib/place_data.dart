import 'package:inline_place_picker/place_picker_data.dart';

class PlaceData extends PlacePickerData {
  PlaceData(
      {this.lon,
      this.lat,
      this.streetNumber,
      this.streetName,
      this.countryCode,
      this.country,
      this.city,
      this.postCode,
      this.town,
      this.locality,
      this.state,
      required super.formattedAddress,
      required super.name,
      required super.placeId});

  double? lat = 0.0;
  double? lon = 0.0;
  String? streetNumber = "";
  String? streetName = "";
  String? countryCode = "";
  String? country = "";
  String? postCode = "";
  String? city = "";
  String? state = "";
  String? town = "";
  String? locality = "";

  @override
  String toString() {
    return '$name, $formattedAddress';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PlaceData &&
        other.name == name &&
        other.formattedAddress == formattedAddress;
  }

  @override
  int get hashCode => Object.hash(formattedAddress, name);
}
