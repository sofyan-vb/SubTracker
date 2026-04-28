class Subscription {
  final String id;
  final String name;
  final double price;
  final DateTime dueDate;
  final String category;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.dueDate,
    required this.category,
  });
}