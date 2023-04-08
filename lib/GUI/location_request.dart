import 'package:ambience/constants.dart';
import 'package:flutter/material.dart';

class LocationRequest extends StatefulWidget {
  const LocationRequest({super.key});

  @override
  State<LocationRequest> createState() => _LocationRequest();
}

class _LocationRequest extends State<LocationRequest> {
  final TextEditingController _cityController =
      TextEditingController(text: "Boston");
  bool _shouldShowState = true;
  String? _chosenCountryCode = allCountryNameToCode[0]['code'];
  String? _chosenState = allUSStates[0];

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
        onChanged: (String? newCountry) {
          debugPrint(newCountry);
          setState(() {
            _chosenCountryCode = newCountry;
            _shouldShowState = (newCountry == 'US') ? true : false;
          });
        },
      ),
    );
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
        items: allUSStates.map<DropdownMenuItem<String>>((String state) {
          return DropdownMenuItem<String>(
            value: state,
            child: Text(state),
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
      child: TextField(
        onChanged: null,
        controller: _cityController,
        textAlign: TextAlign.left,
        maxLength: 100,
        decoration: const InputDecoration(
          labelText: "City Name",
          labelStyle: TextStyle(fontSize: 20),
        ),
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

  void _submit() {}

  OutlinedButton _submitButton() {
    return OutlinedButton(
      onPressed: _submit,
      style: const ButtonStyle(
        padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(20)),
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
        side: MaterialStatePropertyAll<BorderSide>(
          BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: const Text("Submit"),
    );
  }

  Column _buttons() {
    return Column(
      children: [
        _submitButton(),
        const Padding(padding: EdgeInsets.all(12)),
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
