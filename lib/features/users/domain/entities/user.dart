import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String image;
  final String gender;
  final DateTime? birthDate;
  final Address? address;
  final Company? company;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    required this.gender,
    this.birthDate,
    this.address,
    this.company,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        username,
        email,
        phone,
        image,
        gender,
        birthDate,
        address,
        company,
      ];
}

class Address extends Equatable {
  final String address;
  final String city;
  final String state;
  final String stateCode;
  final String postalCode;
  final String country;

  const Address({
    required this.address,
    required this.city,
    required this.state,
    required this.stateCode,
    required this.postalCode,
    required this.country,
  });

  @override
  List<Object> get props =>
      [address, city, state, stateCode, postalCode, country];
}

class Company extends Equatable {
  final String name;
  final String department;
  final String title;

  const Company({
    required this.name,
    required this.department,
    required this.title,
  });

  @override
  List<Object> get props => [name, department, title];
}
