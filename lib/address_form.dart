import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:html' as html;

class AddressForm extends StatefulWidget {
  const AddressForm({Key? key}) : super(key: key);

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  bool _isScriptLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadScript();
  }

  void _loadScript() {
    // Create the input element for AddressNow
    final addressInput = html.InputElement()
      ..id = 'address'
      ..style.width = '100%'
      ..style.padding = '8px'
      ..style.border = '1px solid #ccc'
      ..style.borderRadius = '4px';

    // Insert the input element into the DOM
    html.document.body?.children.add(addressInput);

    // Check if script is already loaded
    if (html.document.querySelector('script[src*="addressnow"]') != null) {
      _isScriptLoaded = true;
      _initializeAddressNow();
      return;
    }

    final script = html.ScriptElement()
      ..type = 'text/javascript'
      ..src = 'http://api.addressnow.co.uk/js/addressnow-2.20.min.js?key=tx12-yy85-mb16-yu94';

    script.onLoad.listen((_) {
      setState(() {
        _isScriptLoaded = true;
        _initializeAddressNow();
      });
    });

    html.document.head!.append(script);
  }

  void _initializeAddressNow() {
    if (!_isScriptLoaded) return;

    js.context['updateFlutterControllers'] = (dynamic address) {
      if (!mounted) return;
      
      setState(() {
        _line1Controller.text = address['line1'] ?? '';
        _line2Controller.text = address['line2'] ?? '';
        _cityController.text = address['city'] ?? '';
        _postcodeController.text = address['postcode'] ?? '';
      });
    };

    js.context.callMethod('eval', ['''
      if (typeof pca !== 'undefined') {
        var fields = [{
          element: "address",
          field: "",
          mode: pca.fieldMode.SEARCH
        }];

        var options = {
          key: "tx12-yy85-mb16-yu94",
          search: {
            countries: "GBR"
          },
          setCountryByIP: false,
          suppressAutocomplete: false,
          bar: {
            visible: true,
            showCountry: false
          }
        };

        try {
          var control = new pca.Address(fields, options);

          control.listen("populate", function(address) {
            var parts = address.Label.split(',').map(function(part) {
              return part.trim();
            });
            
            var line1 = parts[0] || '';
            var line2 = parts.length > 2 ? parts.slice(1, -2).join(', ') : '';
            var city = parts.length > 1 ? parts[parts.length - 2] : '';
            var postcode = parts[parts.length - 1] || '';

            updateFlutterControllers({
              line1: line1,
              line2: line2,
              city: city,
              postcode: postcode
            });
          });
        } catch (e) {
          console.error('AddressNow initialization error:', e);
        }
      }
    ''']);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: HtmlElementView(
              viewType: 'address',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _line1Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 1',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _line2Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 2',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _postcodeController,
            decoration: const InputDecoration(
              labelText: 'Postcode',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }
} 