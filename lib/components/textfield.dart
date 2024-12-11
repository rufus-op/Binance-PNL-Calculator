import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({
    super.key,
    required TextEditingController quantityController,
    this.hintText,
  }) : _quantityController = quantityController;

  final TextEditingController _quantityController;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: _quantityController,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? "",
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
