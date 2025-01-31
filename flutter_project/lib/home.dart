import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Course on the Six Senses'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.blueGrey[200],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.blueGrey[900],
            padding: const EdgeInsets.all(20),
            child: Text(
              "this is a text box with loads and loads of text covering multiple lines with lots of sentences etc", 
              style: TextStyle(
                color: Colors.blueGrey[100],
              ),
            ),
          ),
          Container(
            color: Colors.blueGrey[800],
            padding: const EdgeInsets.all(20),
            child: Text(
              "This is going to contain a player.", 
              style: TextStyle(
                color: Colors.blueGrey[100],
              ),
            ),
          ),
          Container(
            color: Colors.blueGrey[800],
            padding: const EdgeInsets.all(20),
            child: Text(
              "And this is going to contain a transcript.", 
              style: TextStyle(
                color: Colors.blueGrey[100],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

