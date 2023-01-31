import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/MessageModel.dart';
import 'package:vibration/vibration.dart';

onBackgroundMessage(SmsMessage message) {
    Vibration.vibrate(duration: 500);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _messageBody = "";
  String _messageAddress = "";
  Future<MessageModel>? _futureMessage;
  Telephony telephony = Telephony.instance;

  @override
  void initState() {
    telephony.listenIncomingSms(
        onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    super.initState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _messageBody = message.body ?? "Error reading message body.";
      _messageAddress = message.address ?? "Error reading message address";
      _futureMessage = postMessage(_messageAddress, _messageBody);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Listen to Incoming SMS"),
          backgroundColor: Colors.redAccent),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 10, top: 10),
          alignment: Alignment.topLeft,
          child:
              (_futureMessage == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("$_messageAddress"),
        Text("$_messageBody"),
      ],
    );
  }

  FutureBuilder<MessageModel> buildFutureBuilder() {
    return FutureBuilder<MessageModel>(
      future: _futureMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: EdgeInsets.only(left: 20.0, top: 20),
            alignment: Alignment.topLeft,
            width: 350,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sender: " + snapshot.data!.address,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        snapshot.data!.body,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
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
