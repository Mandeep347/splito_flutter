// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      preferredCurrency: json['preferred_currency'] as String,
      isActive: json['is_active'] as bool,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'preferred_currency': instance.preferredCurrency,
      'is_active': instance.isActive,
      'is_email_verified': instance.isEmailVerified,
    };
