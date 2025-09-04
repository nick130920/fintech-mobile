// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: _colorFromJson(json['color'] as String),
      displayName: json['display_name'] as String,
      isActive: json['is_active'] as bool,
      isDefault: json['is_default'] as bool,
      isUserCategory: json['is_user_category'] as bool,
      sortOrder: (json['sort_order'] as num).toInt(),
      canBeDeleted: json['can_be_deleted'] as bool,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'color': _colorToJson(instance.color),
      'display_name': instance.displayName,
      'is_active': instance.isActive,
      'is_default': instance.isDefault,
      'is_user_category': instance.isUserCategory,
      'sort_order': instance.sortOrder,
      'can_be_deleted': instance.canBeDeleted,
    };
