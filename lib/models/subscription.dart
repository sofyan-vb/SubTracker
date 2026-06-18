class Subscription {
  final String id;
  final String name;
  final double price;
  final DateTime dueDate;
  final String category;
  final bool isFinished; 
  final DateTime? dateAdded;
  final bool isPaused;
  final bool isTrial;
  final int splitCount;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.dueDate,
    required this.category,
    this.isFinished = false, 
    this.dateAdded,
    this.isPaused = false,
    this.isTrial = false,
    this.splitCount = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'dueDate': dueDate.toIso8601String(),
    'category': category,
    'isFinished': isFinished, 
    'dateAdded': dateAdded?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'isPaused': isPaused,
    'isTrial': isTrial,
    'splitCount': splitCount,
  };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    dueDate: DateTime.parse(json['dueDate']),
    category: json['category'],
    isFinished: json['isFinished'] ?? false, 
    dateAdded: json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : DateTime.now(),
    isPaused: json['isPaused'] ?? false,
    isTrial: json['isTrial'] ?? false,
    splitCount: json['splitCount'] ?? 1,
  );

  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    DateTime? dueDate,
    String? category,
    bool? isFinished,
    DateTime? dateAdded,
    bool? isPaused,
    bool? isTrial,
    int? splitCount,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isFinished: isFinished ?? this.isFinished,
      dateAdded: dateAdded ?? this.dateAdded,
      isPaused: isPaused ?? this.isPaused,
      isTrial: isTrial ?? this.isTrial,
      splitCount: splitCount ?? this.splitCount,
    );
  }
}