import 'dart:convert';

class Product {
  String id;
  String name;
  List<String>images; // Thay đổi kiểu dữ liệu của trường "images" thành List<String>
  int price;
  bool special;
  String description;
  String category;
  int percent;
  int sl;

  Product(
      {required this.id,
      required this.name,
      required this.images,
      required this.price,
      required this.special,
      required this.description,
      required this.category,
      required this.sl,
      required this.percent});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'images': images,
      'price': price,
      'special': special,
      'description': description,
      'category': category,
      'percent': percent,
      'sl' :sl
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] as String,
      name: map['name'] as String,
      images: List<String>.from(map['images']), // Chuyển đổi thành List<String>
      price: map['price'] as int,
      sl:map['sl'] as int,
      special: map['special'] as bool,
      description: map['description'] as String,
      category: map['category'] as String,
      percent: map['percent'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);
}
