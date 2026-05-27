import 'package:flutter/material.dart';

class FancyToggle extends StatefulWidget {
  final String? value; // null, "YES", "NO"
  final ValueChanged<String> onChanged;

  const FancyToggle({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _FancyToggleState createState() => _FancyToggleState();
}

class _FancyToggleState extends State<FancyToggle> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Cycle through: null → YES → NO → null ...
        String newVal;
        if (widget.value == null) {
          newVal = "Yes";
        } else if (widget.value == "Yes") {
          newVal = "No";
        } else {
          newVal = "Yes";
        }
        widget.onChanged(newVal);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: widget.value == "No"
              ? Colors.red.shade50
              : widget.value == "Yes"
              ? Colors.blue.shade50
              : Colors.grey.shade200, // default
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: widget.value == "No"
                  ? Alignment.centerRight
                  : widget.value == "Yes"
                  ? Alignment.centerLeft
                  : Alignment.center, // default
              curve: Curves.easeInOut,
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.value == "No"
                      ? Colors.red
                      : widget.value == "Yes"
                      ? Colors.blue
                      : Colors.grey, // default
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.value ?? "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}