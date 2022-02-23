class MessageModel {
  String? mid;
  String? message;

  MessageModel({
    this.mid,
    this.message,
  });

  factory MessageModel.fromMap(map) {
    return MessageModel(
      mid: map['mid'],
      message: map['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mid': mid,
      'message': message,
    };
  }
}
