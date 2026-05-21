import '../../domain/entities/sample_item.dart';

class SampleItemModel {
  const SampleItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.price,
  });

  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final double price;

  factory SampleItemModel.fromJson(Map<String, dynamic> json) {
    return SampleItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  SampleItem toEntity() {
    return SampleItem(
      id: id,
      title: title,
      description: description,
      thumbnail: thumbnail,
      price: price,
    );
  }
}
