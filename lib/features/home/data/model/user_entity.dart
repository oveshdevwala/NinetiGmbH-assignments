import 'package:objectbox/objectbox.dart';
import '../../../users/domain/entities/user.dart';

@Entity()
class UserEntity {
  @Id()
  int id;

  int apiId; // Store the original API ID separately
  String firstName;
  String lastName;
  String username;
  String email;
  String phone;
  String image;
  String gender;
  String? birthDate; // Store as string for ObjectBox

  // Address fields (flattened for ObjectBox)
  String? addressStreet;
  String? addressCity;
  String? addressState;
  String? addressStateCode;
  String? addressPostalCode;
  String? addressCountry;

  // Company fields (flattened for ObjectBox)
  String? companyName;
  String? companyDepartment;
  String? companyTitle;

  // Sync related fields
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isDeleted;

  // Pagination tracking
  bool isInitialBatch; // Track if this user is from the initial 15

  UserEntity({
    this.id = 0,
    required this.apiId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    required this.gender,
    this.birthDate,
    this.addressStreet,
    this.addressCity,
    this.addressState,
    this.addressStateCode,
    this.addressPostalCode,
    this.addressCountry,
    this.companyName,
    this.companyDepartment,
    this.companyTitle,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
    this.isInitialBatch = false,
  });

  // Convert to domain entity (use apiId as the domain id)
  User toDomain() {
    return User(
      id: apiId,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phone: phone,
      image: image,
      gender: gender,
      birthDate: birthDate != null ? _parseDate(birthDate!) : null,
      address: _buildAddress(),
      company: _buildCompany(),
    );
  }

  // Convert from domain entity
  static UserEntity fromDomain(User user, {bool isInitialBatch = false}) {
    final now = DateTime.now();
    return UserEntity(
      id: 0, // Always use 0 for new ObjectBox entities
      apiId: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      email: user.email,
      phone: user.phone,
      image: user.image,
      gender: user.gender,
      birthDate: user.birthDate?.toIso8601String().split('T')[0],
      addressStreet: user.address?.address,
      addressCity: user.address?.city,
      addressState: user.address?.state,
      addressStateCode: user.address?.stateCode,
      addressPostalCode: user.address?.postalCode,
      addressCountry: user.address?.country,
      companyName: user.company?.name,
      companyDepartment: user.company?.department,
      companyTitle: user.company?.title,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
      isInitialBatch: isInitialBatch,
    );
  }

  // Convert from JSON (API response)
  static UserEntity fromJson(Map<String, dynamic> json,
      {bool isInitialBatch = false}) {
    final now = DateTime.now();
    final address = json['address'] as Map<String, dynamic>?;
    final company = json['company'] as Map<String, dynamic>?;

    return UserEntity(
      id: 0, // Always use 0 for new ObjectBox entities
      apiId: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birthDate'] as String?,
      addressStreet: address?['address'] as String?,
      addressCity: address?['city'] as String?,
      addressState: address?['state'] as String?,
      addressStateCode: address?['stateCode'] as String?,
      addressPostalCode: address?['postalCode'] as String?,
      addressCountry: address?['country'] as String?,
      companyName: company?['name'] as String?,
      companyDepartment: company?['department'] as String?,
      companyTitle: company?['title'] as String?,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
      isInitialBatch: isInitialBatch,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': apiId, // Use apiId for API requests
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'image': image,
      'gender': gender,
      'birthDate': birthDate,
      'address': _buildAddressJson(),
      'company': _buildCompanyJson(),
    };
  }

  UserEntity copyWith({
    int? id,
    int? apiId,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? image,
    String? gender,
    String? birthDate,
    String? addressStreet,
    String? addressCity,
    String? addressState,
    String? addressStateCode,
    String? addressPostalCode,
    String? addressCountry,
    String? companyName,
    String? companyDepartment,
    String? companyTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
    bool? isInitialBatch,
  }) {
    return UserEntity(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      addressStreet: addressStreet ?? this.addressStreet,
      addressCity: addressCity ?? this.addressCity,
      addressState: addressState ?? this.addressState,
      addressStateCode: addressStateCode ?? this.addressStateCode,
      addressPostalCode: addressPostalCode ?? this.addressPostalCode,
      addressCountry: addressCountry ?? this.addressCountry,
      companyName: companyName ?? this.companyName,
      companyDepartment: companyDepartment ?? this.companyDepartment,
      companyTitle: companyTitle ?? this.companyTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      isInitialBatch: isInitialBatch ?? this.isInitialBatch,
    );
  }

  // Helper methods
  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  Address? _buildAddress() {
    if (addressStreet == null && addressCity == null) return null;

    return Address(
      address: addressStreet ?? '',
      city: addressCity ?? '',
      state: addressState ?? '',
      stateCode: addressStateCode ?? '',
      postalCode: addressPostalCode ?? '',
      country: addressCountry ?? '',
    );
  }

  Company? _buildCompany() {
    if (companyName == null) return null;

    return Company(
      name: companyName!,
      department: companyDepartment ?? '',
      title: companyTitle ?? '',
    );
  }

  Map<String, dynamic>? _buildAddressJson() {
    if (addressStreet == null && addressCity == null) return null;

    return {
      'address': addressStreet ?? '',
      'city': addressCity ?? '',
      'state': addressState ?? '',
      'stateCode': addressStateCode ?? '',
      'postalCode': addressPostalCode ?? '',
      'country': addressCountry ?? '',
    };
  }

  Map<String, dynamic>? _buildCompanyJson() {
    if (companyName == null) return null;

    return {
      'name': companyName!,
      'department': companyDepartment ?? '',
      'title': companyTitle ?? '',
    };
  }
}
