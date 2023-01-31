import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;

import '../models/MessageModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<MessageModel>? _futureMessage;
  Telephony telephony = Telephony.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: (_futureMessage == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureMessage = _futureMessage = postMessage('Wakefit', 'This is a test message');
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<MessageModel> buildFutureBuilder() {
    return FutureBuilder<MessageModel>(
      future: _futureMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return
            Row(
              children: [
                Text(snapshot.data!.address),
                Text(snapshot.data!.body),
              ],
            );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

Future<MessageModel> postMessage(String address, String body) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'address': address, 'body': body}),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return MessageModel.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to load from api.');
  }
}
