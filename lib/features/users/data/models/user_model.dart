// ignore_for_file: overridden_fields

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import '../../../../core/utils/typedef.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends User {
  @JsonKey(name: 'address', fromJson: _addressFromJson, toJson: _addressToJson)
  final AddressModel? addressModel;

  @JsonKey(name: 'company', fromJson: _companyFromJson, toJson: _companyToJson)
  final CompanyModel? companyModel;

  @JsonKey(name: 'birthDate', fromJson: _dateFromJson, toJson: _dateToJson)
  @override
  final DateTime? birthDate;

  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.username,
    required super.email,
    required super.phone,
    required super.image,
    required super.gender,
    this.birthDate,
    this.addressModel,
    this.companyModel,
  }) : super(
          birthDate: birthDate,
          address: addressModel,
          company: companyModel,
        );

  factory UserModel.fromJson(DataMap json) => _$UserModelFromJson(json);

  DataMap toJson() => _$UserModelToJson(this);

  static AddressModel? _addressFromJson(DataMap? json) =>
      json == null ? null : AddressModel.fromJson(json);

  static DataMap? _addressToJson(AddressModel? address) => address?.toJson();

  static CompanyModel? _companyFromJson(DataMap? json) =>
      json == null ? null : CompanyModel.fromJson(json);

  static DataMap? _companyToJson(CompanyModel? company) => company?.toJson();

  static DateTime? _dateFromJson(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      // Handle the API format like "1996-5-30" by parsing and reformatting
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }

      // Fallback to standard parsing if the format is different
      return DateTime.parse(dateString);
    } catch (e) {
      // If all parsing attempts fail, return null
      return null;
    }
  }

  static String? _dateToJson(DateTime? date) {
    return date?.toIso8601String().split('T')[0]; // Return date only, not time
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? image,
    String? gender,
    DateTime? birthDate,
    AddressModel? address,
    CompanyModel? company,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      addressModel: address ?? addressModel,
      companyModel: company ?? companyModel,
    );
  }
}

@JsonSerializable()
class AddressModel extends Address {
  const AddressModel({
    required super.address,
    required super.city,
    required super.state,
    required super.stateCode,
    required super.postalCode,
    required super.country,
  });

  factory AddressModel.fromJson(DataMap json) => _$AddressModelFromJson(json);

  DataMap toJson() => _$AddressModelToJson(this);
}

@JsonSerializable()
class CompanyModel extends Company {
  const CompanyModel({
    required super.name,
    required super.department,
    required super.title,
  });

  factory CompanyModel.fromJson(DataMap json) => _$CompanyModelFromJson(json);

  DataMap toJson() => _$CompanyModelToJson(this);
}
