import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vunapay_demo/services/firestore.dart';

import 'home.dart';

class NumberPadBottomSheet extends StatefulWidget {
  final int amountOwed;

  const NumberPadBottomSheet({super.key, required this.amountOwed});

  @override
  _NumberPadBottomSheetState createState() => _NumberPadBottomSheetState();
}

class _NumberPadBottomSheetState extends State<NumberPadBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);
  }

  void _appendNumber(String number) {
    setState(() {
      if (_controller.text.isEmpty) {
        _controller.text += number;
      } else {
        final int parsedNumber = int.parse(_controller.text);
        if (_controller.text.isNotEmpty &&
            (_controller.text.length < widget.amountOwed.toString().length) &&
            parsedNumber < widget.amountOwed) {
          _controller.text += number;
        }
      }
    });
  }

  void _deleteLast() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _controller.text = _controller.text.substring(
          0,
          _controller.text.length - 1,
        );
      }
    });
  }

  _showToast(bool success, String message) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: success ? const Color.fromRGBO(73, 189, 119, 1.0) : const Color.fromRGBO(168, 44, 44, 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(success) Icon(Icons.check, color: Colors.white,) else Icon(Icons.error, color: Colors.white),
          SizedBox(
            width: 12.0,
          ),
          Text(message, style: TextStyle(fontFamily: "Poppins", color: Colors.white),),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.65,
      // Adjust height as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter Amount",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          Text(
            _controller.text.isNotEmpty
                ? int.parse(_controller.text) > widget.amountOwed
                    ? "Amount should be less than ${widget.amountOwed}"
                    : "Amount Owed: KES ${widget.amountOwed}"
                : "Amount Owed: KES ${widget.amountOwed}",
            style: const TextStyle(fontSize: 13, fontFamily: "Poppins"),
          ),
          Text(
            "Interest (3%): KES ${_controller.text.isNotEmpty ? (int.parse(_controller.text) * 0.03).floor() : "0"}",
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Poppins",
              color: Color.fromRGBO(168, 44, 44, 1.0),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontFamily: "Poppins",
              color: _controller.text.isNotEmpty
                  ? int.parse(_controller.text) > widget.amountOwed
                      ? const Color.fromRGBO(168, 44, 44, 1.0)
                      : Colors.black
                  : Colors.black,
            ),
            readOnly: true,
            // Prevent manual typing
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          const Spacer(),
          _buildNumberPad(),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity, // Stretches the button
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _controller.text.isNotEmpty
                    ? int.parse(_controller.text) > widget.amountOwed
                        ? const Color.fromRGBO(168, 44, 44, 1.0)
                        : const Color.fromRGBO(73, 189, 119, 1.0)
                    : const Color.fromRGBO(73, 189, 119, 1.0),
                // Button color
                foregroundColor: Colors.white,
                // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  if (int.parse(_controller.text) <= widget.amountOwed) {
                    final int requestedAmount = int.parse(_controller.text);
                    final int interest =
                        (int.parse(_controller.text) * 0.03).floor();

                    firestoreService.addTransaction({
                      'note': "Harvest payment",
                      'type': "receive",
                      'amount': requestedAmount,
                    });

                    firestoreService.addTransaction({
                      'note': "Interest payment",
                      'type': "send",
                      'amount': interest,
                    });

                    firestoreService.processPaymentRequest(
                        requestedAmount, interest, (successful, message) {
                      if (successful) {
                        _showToast(successful, message);
                        Navigator.pop(context);
                      } else {
                        _showToast(successful, message);
                      }
                    });
                  }else{
                     _showToast(false, "Amount should be less than ${widget.amountOwed}");
                  }
                }else{
                  _showToast(false, "Amount should not be empty");
                }
              },
              child: const Text(
                "Place request",
                style: TextStyle(fontFamily: "Poppins"),
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildRow(["1", "2", "3"]),
        _buildRow(["4", "5", "6"]),
        _buildRow(["7", "8", "9"]),
        _buildRow([".", "0", "⌫"]),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return _buildButton(number);
      }).toList(),
    );
  }

  Widget _buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 80,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            if (text == "⌫") {
              _deleteLast();
            } else {
              _appendNumber(text);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ),
    );
  }
}
