import 'package:flutter/material.dart';
import 'dart:js' as js;


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

  @override
  void initState() {
    super.initState();
    _initializeAddressNow();
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      window.pca = window.pca || {};
      window.pca.on = window.pca.on || function(){};
      
      // Initialize AddressNow
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
        setCountryByIP: false
      };

      var control = new pca.Address(fields, options);

      control.listen("populate", function(address) {
        var parts = address.Label.split(',').map(function(part) {
          return part.trim();
        });
        
        var line1 = parts[0] || '';
        var line2 = parts.length > 2 ? parts.slice(1, -2).join(', ') : '';
        var city = parts.length > 1 ? parts[parts.length - 2] : '';
        var postcode = parts[parts.length - 1] || '';

        document.getElementById('line1').value = line1;
        document.getElementById('line2').value = line2;
        document.getElementById('city').value = city;
        document.getElementById('postcode').value = postcode;

        // Update Flutter controllers
        if (window.flutterWebViewController) {
          window.flutterWebViewController.postMessage(JSON.stringify({
            type: 'updateFields',
            data: {
              line1: line1,
              line2: line2, 
              city: city,
              postcode: postcode
            }
          }));
        }
      });
    ''']);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Address',
              hintText: 'Enter postcode or address',
              border: OutlineInputBorder(),
            ),
          ).id('address'),
          const SizedBox(height: 16),
          TextField(
            controller: _line1Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 1',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ).id('line1'),
          const SizedBox(height: 16),
          TextField(
            controller: _line2Controller,
            decoration: const InputDecoration(
              labelText: 'Address Line 2',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ).id('line2'),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ).id('city'),
          const SizedBox(height: 16),
          TextField(
            controller: _postcodeController,
            decoration: const InputDecoration(
              labelText: 'Postcode',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ).id('postcode'),
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

extension on TextField {
  TextField id(String id) {
    return TextField(
      controller: controller,
      decoration: decoration,
      readOnly: readOnly,
      key: ValueKey(id),
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
    );
  }
} 