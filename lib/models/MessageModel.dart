class MessageModel {
  final String address;
  final String body;

  const MessageModel({required this.address, required this.body});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      address: json['address'],
      body: json['body'],
    );
  }
}