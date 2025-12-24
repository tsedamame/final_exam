class ProductComment {
  final String id;
  final String name;
  final String message;
  final int timestamp;
  final String userId;

  ProductComment({
    required this.id,
    required this.name,
    required this.message,
    required this.timestamp,
    required this.userId,
  });

  factory ProductComment.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return ProductComment(
      id: id,
      name: (data['name'] as String?) ?? 'Anonymous',
      message: (data['text'] as String?) ?? '',
      timestamp: (data['timestamp'] as num?)?.toInt() ?? 0,
      userId: (data['userId'] as String?) ?? '',
    );
  }
}
