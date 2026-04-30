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

  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'dueDate': dueDate.toIso8601String(),
    'category': category,
  };


  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    dueDate: DateTime.parse(json['dueDate']),
    category: json['category'],
  );
}