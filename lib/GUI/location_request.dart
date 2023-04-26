import 'dart:convert';

import 'package:ambience/constants.dart';
import 'package:ambience/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationRequest extends StatefulWidget {
  const LocationRequest({super.key});

  @override
  State<LocationRequest> createState() => _LocationRequest();
}

class _LocationRequest extends State<LocationRequest> {
  final GlobalKey _autocompleteKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _autocompleteController = TextEditingController();
  List<dynamic> _citiesList = [];
  bool _shouldShowState = true;
  String? _chosenCountryCode = allCountryNameToCode[0]['code'];
  String? _chosenState = allUSStates[0]['code'];

  @override
  void initState() {
    _getAsyncData();
    super.initState();
  }

  void _getAsyncData() async {
    _citiesList = await _getCitiesByCountry(_chosenCountryCode);
  }

  Text _header() {
    return const Text("Please enter your location information");
  }

  Container _countryDropdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 500,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: DropdownButton<String>(
        value: _chosenCountryCode,
        items: allCountryNameToCode
            .map<DropdownMenuItem<String>>((Map<String, String> country) {
          return DropdownMenuItem<String>(
            value: country['code'],
            child: Text(country['name']!),
          );
        }).toList(),
        onChanged: (String? newCountry) async {
          List<dynamic> response = [];
          response = await _getCitiesByCountry(newCountry);
          setState(() {
            _chosenCountryCode = newCountry;
            _citiesList = response;
            _shouldShowState = (newCountry == 'US');
          });
        },
      ),
    );
  }

  List<dynamic> _getCitiesByState(String? state) {
    return _citiesList.where((el) => el['state'] == state).toList();
  }

  Future<List<dynamic>> _getCitiesByCountry(String? country) async {
    return jsonDecode(await DefaultAssetBundle.of(context)
            .loadString('assets/city_codes/city_code_$country.json'))
        .toList();
  }

  Container _stateDropdownUS() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: DropdownButton<String>(
        value: _chosenState,
        items: allUSStates
            .map<DropdownMenuItem<String>>((Map<String, String> state) {
          return DropdownMenuItem<String>(
            value: state['code'],
            child: Text(state['name']!),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _chosenState = value;
          });
        },
      ),
    );
  }

  Container _citySearchInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 500,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: RawAutocomplete<String>(
        key: _autocompleteKey,
        focusNode: _focusNode,
        textEditingController: _autocompleteController,
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == "") {
            return const Iterable<String>.empty();
          }
          List<dynamic> cities =
              _shouldShowState ? _getCitiesByState(_chosenState) : _citiesList;
          return cities
              .where((element) => (element['name'])
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()))
              .map((e) => (e['name'] as String))
              .toList();
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Material(
            elevation: 4,
            child: ListView(
              children: options
                  .map((op) => GestureDetector(
                        onTap: () {
                          onSelected(op);
                        },
                        child: ListTile(
                          title: Text(op),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Container _fields() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          _countryDropdown(),
          const Padding(padding: EdgeInsets.only(top: 32)),
          if (_shouldShowState) _stateDropdownUS(),
          const Padding(padding: EdgeInsets.only(top: 32)),
          _citySearchInput(),
        ],
      ),
    );
  }

  void _submit() {
    String chosenName = _autocompleteController.text;

    if (chosenName.isNotEmpty) {
      Map<String, dynamic> city = _citiesList.where((element) {
        return element['name'] == chosenName &&
            (_chosenCountryCode == "US"
                ? element['state'] == _chosenState
                : true);
      }).toList()[0];
      context.read<LocationProvider>().setLocation(city);
      Navigator.of(context).pushNamed('/Home');
    }
  }

  ButtonStyle _buttonStyle({
    MaterialStatePropertyAll<Color> backgroundColor =
        const MaterialStatePropertyAll<Color>(Colors.white),
    MaterialStatePropertyAll<EdgeInsets> padding =
        const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(20)),
    MaterialStatePropertyAll<BorderSide> side =
        const MaterialStatePropertyAll<BorderSide>(
            BorderSide(color: Colors.black, width: 2)),
  }) {
    return ButtonStyle(
      backgroundColor: backgroundColor,
      padding: padding,
      side: side,
    );
  }

  Widget _cancelButton() {
    return (context.read<LocationProvider>().location != null)
        ? OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: _buttonStyle(
              side: const MaterialStatePropertyAll<BorderSide>(
                BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
            child: const Text("Cancel"),
          )
        : Container();
  }

  OutlinedButton _submitButton() {
    return OutlinedButton(
      onPressed: _submit,
      style: _buttonStyle(),
      child: const Text("Submit"),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _cancelButton(),
        const Padding(padding: EdgeInsets.all(12)),
        _submitButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _header(),
          const Padding(padding: EdgeInsets.only(top: 8)),
          _fields(),
          _buttons(),
        ],
      ),
    );
  }
}
