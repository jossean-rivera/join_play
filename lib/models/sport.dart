// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Sport {
  String? name;
  String? image;
  Sport({
    this.name,
    this.image,
  });

  Sport copyWith({
    String? name,
    String? image,
  }) {
    return Sport(
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
    };
  }

  factory Sport.fromMap(Map<String, dynamic> map) {
    return Sport(
      name: map['name'] != null ? map['name'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sport.fromJson(String source) => Sport.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Sport(name: $name, image: $image)';

  @override
  bool operator ==(covariant Sport other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.image == image;
  }

  @override
  int get hashCode => name.hashCode ^ image.hashCode;
}
