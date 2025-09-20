import 'package:flutter/material.dart';

class CheckOutScreen extends StatelessWidget {
  final double total;
  const CheckOutScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'الاجمالي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,

          ),
        ),
        backgroundColor: Color.fromRGBO(242, 247, 253, 1),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${total.toStringAsFixed(2)} SAR',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,

                fontSize: 25,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
