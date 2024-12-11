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
          filled: true,
          fillColor: Colors.grey.shade200,
          hintText: hintText ?? "",
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
