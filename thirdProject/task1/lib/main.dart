import 'package:flutter/material.dart';

void main() {
  runApp(const First());
}

class First extends StatelessWidget {
  const First({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

        home: Scaffold(
          appBar: AppBar(

            backgroundColor: Colors.deepOrange, // App bar background color
          ),

        body : Center(child: Text( "Taimoor (Fa22-bse-072)")),
        ),
    // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
