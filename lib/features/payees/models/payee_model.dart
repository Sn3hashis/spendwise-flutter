class Payee {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? imageUrl;

  const Payee({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.imageUrl,
  });

  // Add toJson method
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'imageUrl': imageUrl,
  };

  // Add fromJson factory constructor
  factory Payee.fromJson(Map<String, dynamic> json) => Payee(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    imageUrl: json['imageUrl'] as String?,
  );

  // Add equality operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payee &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          email == other.email &&
          imageUrl == other.imageUrl;

  // Add hashCode
  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      imageUrl.hashCode;
} 