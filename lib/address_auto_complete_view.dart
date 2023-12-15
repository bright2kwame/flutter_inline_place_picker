import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inline_place_picker/app_utility.dart';
import 'package:inline_place_picker/place_data.dart';
import 'package:inline_place_picker/place_picker_data.dart';

class AddressAutoCompleteView extends StatefulWidget {
  final String googleApiKey;
  final String labelHint;
  final InputDecoration? inputDecoration;
  final Function(PlaceData placeData) placeSelected;
  final Function(TextEditingController controller) updateEditingController;
  const AddressAutoCompleteView({
    super.key,
    required this.labelHint,
    required this.googleApiKey,
    required this.placeSelected,
    required this.updateEditingController,
    this.inputDecoration,
  });
  @override
  State<AddressAutoCompleteView> createState() =>
      _AddressAutoCompleteViewState();
}

class _AddressAutoCompleteViewState extends State<AddressAutoCompleteView> {
  static List<PlacePickerData> _options = <PlacePickerData>[];
  static List<PlacePickerData> _lastOptions = <PlacePickerData>[];
  static String _displayStringForOption(PlacePickerData option) =>
      option.formattedAddress;
  static String _lastQuery = "";
  static String apiKey = "";
  static String baseMapApi = "https://maps.googleapis.com/maps/api/";

  @override
  void initState() {
    super.initState();
  }

//MARK: get detail place information
  static Future<PlaceData> getPlaceDetail(
      BuildContext context, PlacePickerData placePickerData) async {
    final dio = Dio();
    dio.options.baseUrl = baseMapApi;
    Response response = await dio.get(
      'place/details/json',
      queryParameters: {'place_id': placePickerData.placeId, 'key': apiKey},
    );
    var result = response.data;
    if (result != null && result is Map<String, dynamic>) {
      String status = result["status"].toString();
      if (status == "OK") {
        return _parseData(result["result"]);
      }
    }
    return PlaceData(
        formattedAddress: placePickerData.formattedAddress,
        name: placePickerData.name,
        placeId: placePickerData.placeId);
  }

//MARK: get displayable list
  static Future<List<PlacePickerData>> _startApiCall(
      String query, BuildContext context) async {
    if (query == '') {
      return List<PlacePickerData>.empty();
    }
    final dio = Dio();
    dio.options.baseUrl = baseMapApi;
    Response response = await dio.get(
      'place/textsearch/json',
      queryParameters: {'query': query, 'key': apiKey},
    );
    dynamic result = response.data;
    if (result != null && result is Map<String, dynamic>) {
      String status = result["status"].toString();
      if (status == "OK") {
        _options = (result["results"] as List)
            .map((e) => _parsePlacePickerData(e))
            .toList();
      } else {
        AppUtility.printLogMessage(result, "PICKER_ERROR");
      }
    }
    return _options;
  }

  //MARK: parse data from api
  static PlacePickerData _parsePlacePickerData(var data) {
    String name = data["name"].toString();
    String placeId = data["place_id"].toString();
    String formattedAddress = data["formatted_address"].toString();
    return PlacePickerData(
      formattedAddress: formattedAddress,
      name: name,
      placeId: placeId,
    );
  }

  //MARK: parse data from api
  static PlaceData _parseData(var data) {
    AppUtility.printLogMessage(data.toString(), "PLACE_DATA");
    String name = data["name"].toString();
    String placeId = data["place_id"].toString();
    String formattedAddress = data["formatted_address"].toString();
    double lat = data["geometry"]["location"]["lat"];
    double lon = data["geometry"]["location"]["lng"];
    String streetNumber = "";
    String streetName = "";
    String countryCode = "";
    String country = "";
    String postCode = "";
    String city = "";
    String state = "";
    String town = "";
    String locality = "";
    if (data["address_components"] != null) {
      for (var address in (data["address_components"] as List)) {
        List types = address["types"] as List;
        if (types.contains("street_number")) {
          streetNumber = address["long_name"].toString();
        }
        if (types.contains("route")) {
          streetName = address["long_name"].toString();
        }
        if (types.contains("locality")) {
          locality = address["long_name"].toString();
        }
        if (types.contains("administrative_area_level_1")) {
          state = address["long_name"].toString();
        }
        if (types.contains("administrative_area_level_2")) {
          city = address["long_name"].toString();
        }
        if (types.contains("country")) {
          country = address["long_name"].toString();
          countryCode = address["short_name"].toString();
        }
        if (types.contains("postal_code")) {
          postCode = address["long_name"].toString();
        }
        if (types.contains("postal_town")) {
          town = address["long_name"].toString();
        }
      }
    }
    return PlaceData(
        formattedAddress: formattedAddress,
        name: name,
        lon: lon,
        lat: lat,
        placeId: placeId,
        city: city,
        streetName: streetName,
        streetNumber: streetNumber,
        country: country,
        state: state,
        town: town,
        locality: locality,
        countryCode: countryCode,
        postCode: postCode);
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<PlacePickerData>(
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        widget.updateEditingController(textEditingController);
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (value) {
            _startApiCall(textEditingController.text.trim(), context);
          },
          decoration: widget.inputDecoration == null
              ? _outlinedDecoration(widget.labelHint)
              : widget.inputDecoration!,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 2.0,
            color: Colors.white,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: options.length * 64,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final PlacePickerData option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () async {
                      onSelected(option);
                      PlaceData placeData =
                          await getPlaceDetail(context, option);
                      widget.placeSelected(placeData);
                    },
                    child: ListTile(
                      title: Text(option.toString()),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      displayStringForOption: _displayStringForOption,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        _lastQuery = textEditingValue.text;
        if (_lastQuery != textEditingValue.text) {
          return _lastOptions;
        }
        final List<PlacePickerData> options =
            await _startApiCall(_lastQuery, context);
        _lastOptions = options;
        return options;
      },
    );
  }

  static EdgeInsets contentPadding = const EdgeInsets.all(12.0);

  static InputDecoration _outlinedDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      contentPadding: contentPadding,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide(color: Colors.grey),
      ),
    );
  }
}
