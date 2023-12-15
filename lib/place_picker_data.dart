class PlacePickerData {
  PlacePickerData({
    required this.formattedAddress,
    required this.name,
    required this.placeId,
  });

  final String formattedAddress;
  final String name;
  final String placeId;

  @override
  String toString() {
    return '$name, $formattedAddress';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PlacePickerData &&
        other.name == name &&
        other.formattedAddress == formattedAddress;
  }

  @override
  int get hashCode => Object.hash(formattedAddress, name);
}
