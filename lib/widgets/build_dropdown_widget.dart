import 'package:flutter/material.dart';

Widget buildDropdownWidget({
  required String label,
  required String value,
  required List<DropdownMenuItem<String>> items,
  required ValueChanged<String> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: (value) => onChanged(value!),
    ),
  );
}
